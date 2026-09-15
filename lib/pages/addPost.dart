import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/blog_models.dart';
import '../services/api_service.dart';

class AddPostPage extends StatefulWidget {
  final Map? article;

  const AddPostPage({super.key, this.article});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _picker = ImagePicker();

  List<Category> _categories = [];
  int? _selectedCategoryId;
  XFile? _pickedImage;
  Uint8List? _previewBytes; // preview aman mobile + web

  bool _loadingCat = true;
  bool _saving = false;
  String? _catError;

  bool get isEdit => widget.article != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final a = widget.article!;
      _titleCtrl.text = (a['title'] ?? '').toString();
      _contentCtrl.text = (a['content'] ?? '').toString();
      final rawCat = a['categoryId'] ?? a['category_id'];
      _selectedCategoryId =
          rawCat == null ? null : int.tryParse(rawCat.toString());
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCat = true;
      _catError = null;
    });
    try {
      final cats = await ApiService.fetchCategories();
      setState(() {
        _categories = cats;
        _loadingCat = false;
        if (_selectedCategoryId != null &&
            !cats.any((c) => c.id == _selectedCategoryId)) {
          _selectedCategoryId = null;
        }
      });
    } catch (e) {
      setState(() {
        _loadingCat = false;
        _catError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() {
      _pickedImage = img;
      _previewBytes = bytes;
    });
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
      _previewBytes = null;
    });
  }

  String get _oldImageUrl =>
      (widget.article?['imageUrl']?.toString() ??
          widget.article?['image_url']?.toString() ??
          '');

  Future<void> _submit() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori dulu ya!')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      if (isEdit) {
        final id = int.parse(widget.article!['id'].toString());
        await ApiService.updatePost(
          id: id,
          categoryId: _selectedCategoryId!,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          image: _pickedImage, // null = gambar tidak diganti
        );
      } else {
        await ApiService.createPost(
          categoryId: _selectedCategoryId!,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          image: _pickedImage, // null = tanpa gambar, tetap boleh
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Artikel berhasil diedit!'
              : 'Artikel berhasil ditambah!'),
        ),
      );
      Navigator.pop(context, true); // kasih tahu Home untuk refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Artikel' : 'Tambah Artikel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- KATEGORI ----------
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_loadingCat)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_catError != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _catError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadCategories,
                      child: const Text('Muat ulang'),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  hint: const Text('Pilih kategori'),
                  items: _categories
                      .map((c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedCategoryId = v),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // ---------- JUDUL ----------
              const Text(
                'Judul',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Contoh: Belajar Flutter Itu Menyenangkan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Judul wajib diisi'
                        : null,
              ),
              const SizedBox(height: 16),

              // ---------- ISI ----------
              const Text(
                'Isi Artikel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: 'Tulis isi artikel di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Isi artikel wajib diisi'
                        : null,
              ),
              const SizedBox(height: 16),

              // ---------- GAMBAR (OPSIONAL) ----------
              const Text(
                'Gambar (opsional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _saving ? null : _pickImage,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade100,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _saving ? null : _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(_pickedImage == null
                        ? 'Pilih dari galeri'
                        : 'Ganti gambar'),
                  ),
                  if (_pickedImage != null)
                    TextButton.icon(
                      onPressed: _saving ? null : _clearImage,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Hapus'),
                    ),
                ],
              ),
              if (isEdit &&
                  _pickedImage == null &&
                  _oldImageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Gambar lama tetap dipakai kalau tidak pilih yang baru.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ---------- TOMBOL SIMPAN ----------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(
                    _saving
                        ? 'Menyimpan...'
                        : (isEdit ? 'Simpan Perubahan' : 'Tambah Artikel'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    // 1. gambar baru yang baru dipilih
    if (_previewBytes != null) {
      return Image.memory(
        _previewBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    // 2. mode edit: tampilkan gambar lama dari server
    if (isEdit && _oldImageUrl.isNotEmpty) {
      return Image.network(
        _oldImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _emptyImage(),
      );
    }
    return _emptyImage();
  }

  Widget _emptyImage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 44, color: Colors.grey),
          SizedBox(height: 6),
          Text(
            'Ketuk untuk pilih gambar (boleh kosong)',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
