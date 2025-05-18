class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.35:8000',
  );

  static String get enhanceVideo => '$baseUrl/enhance-video/';
  static String get restoreImage => '$baseUrl/restore';
}
