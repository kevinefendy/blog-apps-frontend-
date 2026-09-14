import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/blog_models.dart';

/// Service REST API Blog.
/// Backend:
///  GET /api/v1/posts?categoryId=1
///  GET /api/v1/categories
class ApiService {
  static String get _base => ApiConfig.baseUrl;

  static Future<List<Category>> fetchCategories() async {
    final res = await http
        .get(Uri.parse('$_base/categories'))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat kategori (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (body['data'] as List? ?? []);
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Post>> fetchPosts({int? categoryId}) async {
    final uri = categoryId == null
        ? Uri.parse('$_base/posts')
        : Uri.parse('$_base/posts?categoryId=$categoryId');

    final res =
        await http.get(uri).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat artikel (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (body['data'] as List? ?? []);
    return data
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil posts + gabungkan nama kategori secara lokal
  /// (karena API posts belum join kategori).
  static Future<({List<Post> posts, List<Category> categories})>
      fetchHome({int? categoryId}) async {
    final results = await Future.wait([
      fetchPosts(categoryId: categoryId),
      fetchCategories(),
    ]);
    final posts = results[0] as List<Post>;
    final categories = results[1] as List<Category>;

    final map = {for (final c in categories) c.id: c.name};
    final joined =
        posts.map((p) => p.copyWith(categoryName: map[p.categoryId] ?? 'Umum')).toList();

    // terbaru dulu
    joined.sort((a, b) {
      final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });

    return (posts: joined, categories: categories);
  }
}
