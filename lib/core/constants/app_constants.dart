class AppConstants {
  AppConstants._();

  static const String appName = 'ScanGo';
  static const double taxRate = 0.03; // 3% tax

  // Environment Configurable API Base URL
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5001/api',
  );

  static const bool useMockServices = bool.fromEnvironment(
    'USE_MOCK_SERVICES',
    defaultValue: false,
  );

  static String _apiBaseUrl = _envBaseUrl;
  static String get apiBaseUrl => _apiBaseUrl;
  static set apiBaseUrl(String url) {
    _apiBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Auth Endpoints
  static String get registerEndpoint => '$apiBaseUrl/auth/register';
  static String get loginEndpoint => '$apiBaseUrl/auth/login';
  static String get faceEnrollEndpoint => '$apiBaseUrl/auth/face/enroll';
  static String get faceVerifyEndpoint => '$apiBaseUrl/auth/face/verify';

  // Shopping Session & Cart Endpoints
  static String get sessionEndpoint => '$apiBaseUrl/cart/session';
  static String get cartPairEndpoint => '$apiBaseUrl/cart/pair';
  static String get currentCartEndpoint => '$apiBaseUrl/cart/current';

  // Product Catalog IDs
  static const String doritosId = 'prod_doritos';
  static const String tunaId = 'prod_tuna';
  static const String honeyId = 'prod_honey';
}
