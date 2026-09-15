import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import '../services/api_service.dart';
import 'homePage.dart';

class CategoryBlogPage extends StatefulWidget {
  const CategoryBlogPage({super.key});

  @override
  State<CategoryBlogPage> createState() => _CategoryBlogPageState();
}

class _CategoryBlogPageState extends State<CategoryBlogPage> {
  List<Category> _categories = [];
  Map<int, int> _counts = {}; // categoryId -> jumlah artikel
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.fetchCategories(),
        ApiService.fetchPosts(),
      ]);
      final cats = results[0] as List<Category>;
      final posts = results[1] as List<Post>;

      final counts = <int, int>{};
      for (final p in posts) {
        counts[p.categoryId] = (counts[p.categoryId] ?? 0) + 1;
      }

      setState(() {
        _categories = cats;
        _counts = counts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _showForm({Category? category}) async {
    final editId = category?.id;
    final isEdit = editId != null;
    final ctrl = TextEditingController(text: category?.name ?? '');
    var saving = false;
    String? formError;

    Future<void> submit(StateSetter setDlg, BuildContext ctx) async {
      final name = ctrl.text.trim();
      if (name.isEmpty) {
        setDlg(() => formError = 'Nama kategori wajib diisi');
        return;
      }
      setDlg(() {
        saving = true;
        formError = null;
      });
      try {
        if (isEdit) {
          await ApiService.updateCategory(id: editId, name: name);
        } else {
          await ApiService.createCategory(name);
        }
        if (ctx.mounted) Navigator.pop(ctx, true);
      } catch (e) {
        setDlg(() {
          saving = false;
          formError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama kategori',
                  hintText: 'cth: Teknologi',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => submit(setDlg, ctx),
              ),
              if (formError != null) ...[
                const SizedBox(height: 8),
                Text(formError!,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: saving ? null : () => submit(setDlg, ctx),
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEdit
                ? 'Kategori berhasil diedit'
                : 'Kategori berhasil ditambah')),
      );
      _load();
    }
  }

  Future<void> _confirmDelete(Category c) async {
    final count = _counts[c.id] ?? 0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text(count > 0
            ? 'Kategori "${c.name}" dipakai $count artikel. Tetap hapus?'
            : 'Hapus kategori "${c.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiService.deleteCategory(c.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil dihapus')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 100),
                      const Icon(Icons.cloud_off_outlined,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ),
                    ],
                  )
                : _categories.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(20),
                        children: const [
                          SizedBox(height: 100),
                          Icon(Icons.folder_outlined,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 12),
                          Center(child: Text('Belum ada kategori.')),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final c = _categories[i];
                          final n = _counts[c.id] ?? 0;
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  c.name.isNotEmpty
                                      ? c.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text('$n artikel'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') {
                                    _showForm(category: c);
                                  } else if (v == 'delete') {
                                    _confirmDelete(c);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline,
                                            size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Hapus',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CategoryPostsPage(
                                      categoryId: c.id,
                                      categoryName: c.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

/// Daftar artikel dalam satu kategori.
/// GET /api/v1/posts?categoryId=:id
class CategoryPostsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPostsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostsPage> createState() => _CategoryPostsPageState();
}

class _CategoryPostsPageState extends State<CategoryPostsPage> {
  List _articles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // ApiService.fetchPosts balikin List<Post>, ubah ke Map
      // biar bisa pakai ulang ArticleCard milik Home.
      final posts = await ApiService.fetchPosts(
        categoryId: widget.categoryId,
      );
      setState(() {
        _articles = posts
            .map((p) => {
                  'id': p.id,
                  'title': p.title,
                  'content': p.content,
                  'categoryId': p.categoryId,
                  'imageUrl': p.imageUrl,
                })
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 100),
                      const Icon(Icons.cloud_off_outlined,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ),
                    ],
                  )
                : _articles.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          const SizedBox(height: 100),
                          const Icon(Icons.article_outlined,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Belum ada artikel di kategori "${widget.categoryName}".',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _articles.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, i) => ArticleCard(
                          article: _articles[i],
                          onArticleUpdated: _load,
                        ),
                      ),
      ),
    );
  }
}
