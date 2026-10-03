import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/blog_models.dart';
import '../services/api_service.dart';
import 'article_detail_page.dart';
import 'addPost.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List articles = [];
  List<Category> categories = [];
  int? selectedCategoryId; 
  bool isLoading = true;
  String? errorMsg;

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final uri = selectedCategoryId == null
          ? Uri.parse('${ApiConfig.baseUrl}/posts')
          : Uri.parse(  
              '${ApiConfig.baseUrl}/posts?categoryId=$selectedCategoryId');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          articles = jsonDecode(response.body)['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'Server jawab ${response.statusCode}. Coba lagi ya.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg =
            'HP/ emulator tidak bisa nyambung ke backend.\nCek backend jalan di port 5000.';
      });

      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getPosts();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final cats = await ApiService.fetchCategories();
      setState(() => categories = cats);
    } catch (e) {
      debugPrint('Kategori gagal dimuat: $e');
    }
  }

  void pickCategory(int? id) {
    setState(() => selectedCategoryId = id);
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Buka form tambah, refresh kalau berhasil simpan
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPostPage(),
            ),
          );
          if (result == true) getPosts();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
      onRefresh: getPosts,
      child: errorMsg != null
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 120),
                const Icon(Icons.cloud_off_outlined,
                    size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    errorMsg!,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: getPosts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ),
              ],
            )
          : articles.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                SizedBox(height: 120),
                Icon(Icons.article_outlined,
                    size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'Belum ada artikel.\nKetuk + untuk menambah.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          // Greeting
          const Text(
            'Hi! Good day!',
            style: TextStyle(
              fontFamily: 'Comic Relief',
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Temukan dan baca artikel menarik hari ini.',
            style: TextStyle(
              fontFamily: 'Comic Relief',
              fontSize: 15,
              color: Color.fromARGB(255, 157, 98, 40),
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips kategori
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: selectedCategoryId == null,
                    onSelected: (_) => pickCategory(null),
                  ),
                ),
                ...categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: selectedCategoryId == c.id,
                      onSelected: (_) => pickCategory(c.id),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Header Recent Articles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Articles',
                style: TextStyle(
                  fontFamily: 'Comic Relief',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${articles.length} artikel',
                style: const TextStyle(
                  fontFamily: 'Comic Relief',
                  fontSize: 13,
                  color: Color.fromARGB(255, 157, 98, 40),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Responsive Artikel pakai LayoutBuilder (kayak contoh kamu)
          // Mobile (<600)  : 1 gambar gede ke bawah (list vertikal)
          // Tablet (600-1100): 2 gambar sedang (grid 2 kolom)
          // Desktop (>1100) : gambar gede 4 kolom
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              if (maxWidth < 600) {
                // MOBILE: 1 kolom, gambar besar full-width ke bawah
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: ArticleMobileBigCard(
                        article: articles[index],
                        onArticleUpdated: getPosts,
                      ),
                    );
                  },
                );
              }

              // Tentukan kolom + rasio buat tablet & desktop
              final bool isTablet = maxWidth < 1100;
              final int crossAxisCount = isTablet ? 2 : 4;
              final double childAspectRatio = isTablet ? 0.75 : 0.72;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return ArticleCard(
                    article: article,
                    // Beri tahu Home kalau artikel berhasil diubah
                    onArticleUpdated: getPosts,
                  );
                },
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Map article;
  final VoidCallback? onArticleUpdated;

  const ArticleCard({
    super.key,
    required this.article,
    this.onArticleUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final String title = article['title'] ?? 'Tanpa Judul';
    final dynamic image = article['imageUrl'];

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlDetailPage(
              article: article,
            ),
          ),
        );

        if (result == true) {
          onArticleUpdated?.call();
        }
      },

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: image != null &&
                      image.toString().isNotEmpty
                  ? Image.network(
                      image.toString(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
          ),

          const SizedBox(height: 8),

          // TITLE
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              top: 6,
              right: 10,
            ),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Comic Relief',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 45,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// MOBILE: 1 gambar gede full-width ke bawah (list vertikal)
class ArticleMobileBigCard extends StatelessWidget {
  final Map article;
  final VoidCallback? onArticleUpdated;

  const ArticleMobileBigCard({
    super.key,
    required this.article,
    this.onArticleUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final String title = article['title'] ?? 'Tanpa Judul';
    final String content =
        (article['content'] ?? '').toString().replaceAll(RegExp(r'\s+'), ' ');
    final dynamic image = article['imageUrl'] ?? article['image_url'];

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlDetailPage(article: article),
          ),
        );
        if (result == true) onArticleUpdated?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar gede 16:9 full-width
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: image != null && image.toString().isNotEmpty
                  ? Image.network(
                      image.toString(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              size: 55, color: Colors.grey),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            size: 55, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Comic Relief',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                content.length <= 120
                    ? content
                    : '${content.substring(0, 120)}...',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 

