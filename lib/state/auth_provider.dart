import 'package:flutter/foundation.dart';
import '../models/shopping_session.dart';
import '../models/user.dart';
import '../services/auth/auth_api_service.dart';
import '../services/face_recognition_service.dart';
import '../services/token_storage_service.dart';

enum AuthStatus {
  initial,
  registering,
  registered,
  loggingIn,
  enrollingFace,
  faceEnrolled,
  verifyingFace,
  authenticated,
  failed,
}

class AuthProvider extends ChangeNotifier {
  final FaceRecognitionService faceService;
  final AuthApiService _authApiService;
  final TokenStorageService _tokenStorage;

  AuthProvider({
    required this.faceService,
    AuthApiService? authApiService,
    TokenStorageService? tokenStorage,
  })  : _authApiService = authApiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _token;
  String? get token => _token;

  ShoppingSession? _currentSession;
  ShoppingSession? get currentSession => _currentSession;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isVerified => _status == AuthStatus.authenticated || _status == AuthStatus.faceEnrolled;
  bool get isScanning => _status == AuthStatus.verifyingFace || _status == AuthStatus.enrollingFace;
  bool get isLoading =>
      _status == AuthStatus.registering ||
      _status == AuthStatus.loggingIn ||
      _status == AuthStatus.enrollingFace ||
      _status == AuthStatus.verifyingFace;

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _status = AuthStatus.registering;
    _errorMessage = null;
    notifyListeners();

    final result = await _authApiService.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      _currentUser = result.user;
      _token = result.token;
      if (_token != null) {
        await _tokenStorage.saveToken(_token!);
      }
      if (_currentUser != null) {
        await _tokenStorage.saveUserId(_currentUser!.id);
      }
      _status = AuthStatus.registered;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.failed;
      _errorMessage = result.errorMessage ?? 'Registration failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loggingIn;
    _errorMessage = null;
    notifyListeners();

    final result = await _authApiService.login(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      _currentUser = result.user;
      _token = result.token;
      if (_token != null) {
        await _tokenStorage.saveToken(_token!);
      }
      if (_currentUser != null) {
        await _tokenStorage.saveUserId(_currentUser!.id);
      }
      // Create shopping session
      await startShoppingSession();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.failed;
      _errorMessage = result.errorMessage ?? 'Login failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> enrollFace({
    required String imagePath,
    Uint8List? imageBytes,
  }) async {
    final userId = _currentUser?.id ?? await _tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      _status = AuthStatus.failed;
      _errorMessage = 'User not found. Please register or login first.';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.enrollingFace;
    _errorMessage = null;
    notifyListeners();

    final result = await faceService.enrollFace(
      userId: userId,
      imagePath: imagePath,
      imageBytes: imageBytes,
    );

    if (result.isSuccess) {
      _status = AuthStatus.faceEnrolled;
      await startShoppingSession();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.failed;
      _errorMessage = result.errorMessage ?? 'Face enrollment failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyFace({
    required String imagePath,
    Uint8List? imageBytes,
    String? cartCode,
  }) async {
    _status = AuthStatus.verifyingFace;
    _errorMessage = null;
    notifyListeners();

    final result = await faceService.verifyFace(
      imagePath: imagePath,
      imageBytes: imageBytes,
      cartCode: cartCode,
    );

    if (result.isSuccess && result.userId != null) {
      final userId = result.userId!;
      _token = result.token;
      if (_token != null) {
        await _tokenStorage.saveToken(_token!);
      }
      await _tokenStorage.saveUserId(userId);

      _currentUser = User(
        id: userId,
        fullName: 'ScanGo Customer',
        email: '',
        phone: '',
      );

      // Create / retrieve shopping session for identified customer
      await startShoppingSession(cartCode: cartCode);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.failed;
      _errorMessage = result.errorMessage ?? 'Face not recognized.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> startShoppingSession({String? cartCode}) async {
    final userId = _currentUser?.id ?? await _tokenStorage.getUserId() ?? 'user_anonymous';
    final session = await _authApiService.createShoppingSession(
      userId: userId,
      cartCode: cartCode,
    );
    _currentSession = session;
    if (session != null) {
      await _tokenStorage.saveSessionId(session.sessionId);
    }
    notifyListeners();
    return session != null;
  }

  void reset() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _currentSession = null;
    _status = AuthStatus.initial;
    _errorMessage = null;
    await _tokenStorage.clearAll();
    notifyListeners();
  }
}
