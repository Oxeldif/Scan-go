import '../../core/constants/app_constants.dart';
import '../../models/shopping_session.dart';
import '../../models/user.dart';
import '../api_client.dart';

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final ShoppingSession? activeSession;
  final String? errorMessage;

  const AuthResult({
    required this.isSuccess,
    this.user,
    this.token,
    this.activeSession,
    this.errorMessage,
  });

  factory AuthResult.success(User user, String token, {ShoppingSession? activeSession}) =>
      AuthResult(
        isSuccess: true,
        user: user,
        token: token,
        activeSession: activeSession,
      );

  factory AuthResult.failure(String message) => AuthResult(
        isSuccess: false,
        errorMessage: message,
      );
}

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppConstants.registerEndpoint,
      body: {
        'name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;

      final userData = payload['user'] is Map ? payload['user'] as Map : payload;
      final token = payload['token']?.toString() ?? '';

      final user = User.fromJson(Map<String, dynamic>.from(userData));

      return AuthResult.success(user, token);
    } else {
      return AuthResult.failure(
        response.errorMessage ?? 'Registration failed. Please try again.',
      );
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppConstants.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;

      final userData = payload['user'] is Map ? payload['user'] as Map : payload;
      final token = payload['token']?.toString() ?? '';

      final user = User.fromJson(Map<String, dynamic>.from(userData));

      ShoppingSession? activeSession;
      if (payload['activeCart'] is Map) {
        try {
          activeSession = ShoppingSession.fromJson(
            Map<String, dynamic>.from(payload['activeCart'] as Map),
          );
        } catch (_) {}
      }

      return AuthResult.success(user, token, activeSession: activeSession);
    } else {
      return AuthResult.failure(
        response.errorMessage ?? 'Invalid email or password.',
      );
    }
  }

  Future<ShoppingSession?> pairCart({
    String? cartCode,
    bool faceVerified = false,
  }) async {
    final response = await _apiClient.post(
      AppConstants.pairCartEndpoint,
      body: {
        'cartCode': cartCode ?? AppConstants.defaultCartCode,
        'faceVerified': faceVerified,
      },
    );

    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;
      return ShoppingSession.fromJson(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  Future<ShoppingSession?> verifyCartFace() async {
    final response = await _apiClient.post(AppConstants.verifyFaceEndpoint);
    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;
      return ShoppingSession.fromJson(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  Future<ShoppingSession?> getActiveCart() async {
    final response = await _apiClient.get(AppConstants.activeCartEndpoint);
    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      if (rootData['data'] is Map) {
        return ShoppingSession.fromJson(Map<String, dynamic>.from(rootData['data'] as Map));
      }
    }
    return null;
  }
}
