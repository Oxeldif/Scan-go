import '../../core/constants/app_constants.dart';
import '../../models/shopping_session.dart';
import '../../models/user.dart';
import '../api_client.dart';

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final String? errorMessage;

  const AuthResult({
    required this.isSuccess,
    this.user,
    this.token,
    this.errorMessage,
  });

  factory AuthResult.success(User user, String token) => AuthResult(
        isSuccess: true,
        user: user,
        token: token,
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
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    if (response.isSuccess && response.data is Map) {
      final data = response.data as Map;
      final userId = data['userId']?.toString() ?? data['id']?.toString() ?? '';
      final token = data['token']?.toString() ?? '';

      final user = User(
        id: userId,
        fullName: data['fullName']?.toString() ?? fullName,
        email: data['email']?.toString() ?? email,
        phone: data['phone']?.toString() ?? phone,
      );

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
      final data = response.data as Map;
      final userId = data['userId']?.toString() ?? data['id']?.toString() ?? '';
      final token = data['token']?.toString() ?? '';

      final user = User(
        id: userId,
        fullName: data['fullName']?.toString() ?? data['name']?.toString() ?? 'ScanGo Customer',
        email: data['email']?.toString() ?? email,
        phone: data['phone']?.toString() ?? '',
      );

      return AuthResult.success(user, token);
    } else {
      return AuthResult.failure(
        response.errorMessage ?? 'Invalid email or password.',
      );
    }
  }

  Future<ShoppingSession?> createShoppingSession({
    required String userId,
    String? cartCode,
  }) async {
    final response = await _apiClient.post(
      AppConstants.sessionEndpoint,
      body: {
        'userId': userId,
        'cartCode': cartCode ?? 'cart_default',
      },
    );

    if (response.isSuccess && response.data is Map) {
      return ShoppingSession.fromJson(Map<String, dynamic>.from(response.data as Map));
    }
    // Return a valid local session if backend session creation is in-progress
    return ShoppingSession(
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      cartId: cartCode ?? 'cart_default',
      userId: userId,
      createdAt: DateTime.now(),
    );
  }
}
