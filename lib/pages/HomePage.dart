import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'article_detail_page.dart';
import 'addPost.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List articles = [];
  bool isLoading = true;
  String? errorMsg;

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/posts'),
          )
          .timeout(const Duration(seconds: 5));

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

          const SizedBox(height: 28),

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

          // Grid Artikel
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final article = articles[index];

              return ArticleCard(
                article: article,

                // Beri tahu Home kalau artikel berhasil diubah
                onArticleUpdated: getPosts,
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

        // Kalau artikel berhasil diedit
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