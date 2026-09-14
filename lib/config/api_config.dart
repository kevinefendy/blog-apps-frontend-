// Daftar base URL yang dicoba berurutan.
// - Windows / Chrome : localhost bisa
// - Emulator Android : 10.0.2.2 yang bisa
// - HP fisik : ganti IP di bawah dengan IP laptop (satu WiFi)
class ApiConfig {
  static const List<String> candidates = [
    'http://localhost:5000/api/v1',
    'http://127.0.0.1:5000/api/v1',
    'http://10.0.2.2:5000/api/v1',
    // 'http://192.168.1.x:5000/api/v1', // HP fisik: buka komentar + isi IP laptop
  ];

  /// Base yang sedang dipakai. Otomatis diganti ke yang berhasil
  /// oleh ApiService (auto-detect), jadi tidak perlu edit manual.
  static String baseUrl = candidates[0];
}
