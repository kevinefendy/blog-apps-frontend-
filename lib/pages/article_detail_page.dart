import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'addPost.dart';

/// Detail artikel. Nama kelas sengaja mengikuti pemakaian di homePage.
/// Menampilkan detail + tombol edit & hapus (PUT & DELETE).
class ArticlDetailPage extends StatefulWidget {
  final Map article;

  const ArticlDetailPage({super.key, required this.article});

  @override
  State<ArticlDetailPage> createState() => _ArticlDetailPageState();
}

class _ArticlDetailPageState extends State<ArticlDetailPage> {
  late Map _article;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _article = Map.from(widget.article);
  }

  Future<void> _goEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostPage(article: _article),
      ),
    );
    // true = berhasil edit di halaman form → tutup detail + refresh Home
    if (result == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus artikel?'),
        content: const Text('Artikel yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _deleting = true);
    try {
      final id = int.parse(_article['id'].toString());
      await ApiService.deletePost(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel berhasil dihapus!')),
      );
      Navigator.pop(context, true); // refresh Home
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (_article['title'] ?? 'Tanpa Judul').toString();
    final content = (_article['content'] ?? '-').toString();
    final image = _article['imageUrl']?.toString() ??
        _article['image_url']?.toString() ??
        '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _goEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Hapus',
            onPressed: _deleting ? null : _confirmDelete,
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 60,
        color: Colors.grey,
      ),
    );
  }
}
