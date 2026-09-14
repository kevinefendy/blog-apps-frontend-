class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '-',
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

class Post {
  final int id;
  final int categoryId;
  final String title;
  final String content;
  final String? imageUrl;
  final String status;
  final String? categoryName; // diisi dari join lokal categories
  final DateTime? createdAt;

  const Post({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.status,
    this.categoryName,
    this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: _toInt(json['id']),
      categoryId: _toInt(json['categoryId'] ?? json['category_id']),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: _toDate(json['createdAt'] ?? json['created_at']),
    );
  }

  Post copyWith({String? categoryName}) {
    return Post(
      id: id,
      categoryId: categoryId,
      title: title,
      content: content,
      imageUrl: imageUrl,
      status: status,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v == null) return 0;
    return int.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  String get tanggal {
    if (createdAt == null) return '-';
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final d = createdAt!.toLocal();
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  String get excerpt {
    final t = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length <= 90) return t;
    return '${t.substring(0, 90)}...';
  }
}
