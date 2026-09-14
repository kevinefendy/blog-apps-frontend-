import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/blog_models.dart';

/// Service REST API Blog.
/// Backend:
///  GET    /api/v1/posts?categoryId=1
///  POST   /api/v1/posts            (multipart: categoryId, title, content, image?)
///  PUT    /api/v1/posts/:id        (multipart, field sama)
///  DELETE /api/v1/posts/:id
///  GET    /api/v1/categories
class ApiService {
  static const _timeout = Duration(seconds: 4);

  /// Cari base URL yang hidup (coba berurutan, timeout pendek).
  /// Hasilnya di-cache di [ApiConfig.baseUrl] biar request
  /// berikutnya langsung ke yang benar tanpa muter lama.
  static Future<String> _base() async {
    // base yang lagi dipakai masih hidup? pakai langsung.
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/posts'))
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) return ApiConfig.baseUrl;
    } catch (_) {
      // lanjut coba kandidat lain
    }

    for (final c in ApiConfig.candidates) {
      if (c == ApiConfig.baseUrl) continue;
      try {
        final res =
            await http.get(Uri.parse('$c/posts')).timeout(_timeout);
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = c;
          return c;
        }
      } catch (_) {
        // coba berikutnya
      }
    }
    // semua gagal → balikin base awal, request asli yang akan
    // melempar error yang jelas (bukan muter tanpa henti).
    return ApiConfig.baseUrl;
  }

  static Future<http.Response> _get(String path) async {
    final base = await _base();
    return http.get(Uri.parse('$base$path')).timeout(_timeout);
  }

  static Future<List<Category>> fetchCategories() async {
    final res = await _get('/categories');

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
    final path = categoryId == null
        ? '/posts'
        : '/posts?categoryId=$categoryId';

    final res = await _get(path);

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

  /// POST /posts — field: categoryId, title, content, image (opsional).
  /// 201 = sukses, 400 = validasi gagal, 500 = server error.
  static Future<void> createPost({
    required int categoryId,
    required String title,
    required String content,
    XFile? image,
  }) async {
    final base = await _base();
    final req = http.MultipartRequest('POST', Uri.parse('$base/posts'));
    req.fields['categoryId'] = categoryId.toString();
    req.fields['title'] = title;
    req.fields['content'] = content;

    if (image != null) {
      req.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamed = await req.send().timeout(const Duration(seconds: 20));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 201) return;

    String msg = 'Gagal menambah artikel (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['message'] != null) msg = body['message'].toString();
    } catch (_) {}
    throw Exception(msg);
  }

  /// PUT /posts/:id — field sama seperti create.
  static Future<void> updatePost({
    required int id,
    required int categoryId,
    required String title,
    required String content,
    XFile? image,
  }) async {
    final base = await _base();
    final req =
        http.MultipartRequest('PUT', Uri.parse('$base/posts/$id'));
    req.fields['categoryId'] = categoryId.toString();
    req.fields['title'] = title;
    req.fields['content'] = content;

    if (image != null) {
      req.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamed = await req.send().timeout(const Duration(seconds: 20));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) return;

    String msg = 'Gagal mengedit artikel (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['message'] != null) msg = body['message'].toString();
    } catch (_) {}
    throw Exception(msg);
  }

  /// DELETE /posts/:id (soft delete di backend).
  static Future<void> deletePost(int id) async {
    final base = await _base();
    final res = await http
        .delete(Uri.parse('$base/posts/$id'))
        .timeout(_timeout);

    if (res.statusCode == 200) return;

    String msg = 'Gagal menghapus artikel (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['message'] != null) msg = body['message'].toString();
    } catch (_) {}
    throw Exception(msg);
  }
}
