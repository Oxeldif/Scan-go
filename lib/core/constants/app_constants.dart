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

  // Socket.io Server Base URL (strips trailing /api)
  static String get socketUrl {
    if (_apiBaseUrl.endsWith('/api')) {
      return _apiBaseUrl.substring(0, _apiBaseUrl.length - 4);
    }
    return _apiBaseUrl;
  }

  // Auth Endpoints
  static String get registerEndpoint => '$apiBaseUrl/auth/register';
  static String get loginEndpoint => '$apiBaseUrl/auth/login';
  static String get getMeEndpoint => '$apiBaseUrl/auth/me';
  static String get faceEnrollEndpoint => '$apiBaseUrl/auth/face/enroll';
  static String get faceVerifyEndpoint => '$apiBaseUrl/cart/verify-face';

  // Cart & Shopping Session Endpoints
  static String get pairCartEndpoint => '$apiBaseUrl/cart/pair';
  static String get activeCartEndpoint => '$apiBaseUrl/cart/active';
  static String get verifyFaceEndpoint => '$apiBaseUrl/cart/verify-face';
  static String get addCartItemEndpoint => '$apiBaseUrl/cart/items';
  static String get removeCartItemEndpoint => '$apiBaseUrl/cart/items';
  static String get unpairCartEndpoint => '$apiBaseUrl/cart/unpair';

  // AI Detection Webhook (for demo / simulator panel)
  static String get aiDetectionEndpoint => '$apiBaseUrl/ai/detection';

  // Orders & Checkout Endpoints
  static String get checkoutEndpoint => '$apiBaseUrl/orders/checkout';
  static String get orderHistoryEndpoint => '$apiBaseUrl/orders/history';
  static String get orderReceiptEndpoint => '$apiBaseUrl/orders/receipt';

  // Products Endpoints
  static String get productsEndpoint => '$apiBaseUrl/products';

  // Default Cart Code
  static const String defaultCartCode = 'CART_01';
}
