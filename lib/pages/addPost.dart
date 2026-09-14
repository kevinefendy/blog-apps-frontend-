import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import '../services/api_service.dart';

/// Halaman Tambah / Edit artikel.
/// POST /api/v1/posts & PUT /api/v1/posts/:id.
/// Form: kategori + judul + isi saja (tanpa gambar).
/// Kalau [article] null = mode tambah, kalau diisi = mode edit.
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

  List<Category> _categories = [];
  int? _selectedCategoryId;

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
        // kalau kategori lama tidak ada di list, biarkan null biar user pilih ulang
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
        );
      } else {
        await ApiService.createPost(
          categoryId: _selectedCategoryId!,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
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
}
