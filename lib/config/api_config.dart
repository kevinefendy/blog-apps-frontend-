class ApiConfig {
  static const List<String> candidates = [
    'http://localhost:5000/api/v1',
    'http://127.0.0.1:5000/api/v1',
    'http://10.0.2.2:5000/api/v1',
  ];

  static String baseUrl = candidates[0];
}
