import 'package:flutter/foundation.dart';
import '../models/shopping_session.dart';
import '../models/user.dart';
import '../services/auth/auth_api_service.dart';
import '../services/face_recognition_service.dart';
import '../services/socket/socket_cart_service.dart';
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
  final SocketCartService? _socketCartService;

  AuthProvider({
    required this.faceService,
    AuthApiService? authApiService,
    TokenStorageService? tokenStorage,
    SocketCartService? socketCartService,
  })  : _authApiService = authApiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _socketCartService = socketCartService;

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
      if (_token != null && _token!.isNotEmpty) {
        await _tokenStorage.saveToken(_token!);
      }
      if (_currentUser != null) {
        await _tokenStorage.saveUserId(_currentUser!.id.toString());
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
      if (_token != null && _token!.isNotEmpty) {
        await _tokenStorage.saveToken(_token!);
      }
      if (_currentUser != null) {
        await _tokenStorage.saveUserId(_currentUser!.id.toString());
      }

      // Pair or load active cart session
      if (result.activeSession != null) {
        _currentSession = result.activeSession;
      } else {
        await pairCartSession();
      }

      _connectSocket();

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
    _status = AuthStatus.enrollingFace;
    _errorMessage = null;
    notifyListeners();

    final userId = _currentUser?.id?.toString() ?? await _tokenStorage.getUserId() ?? '1';

    final result = await faceService.enrollFace(
      userId: userId,
      imagePath: imagePath,
      imageBytes: imageBytes,
    );

    if (result.isSuccess) {
      _status = AuthStatus.faceEnrolled;
      // Pair cart with face verified
      await pairCartSession(faceVerified: true);
      _connectSocket();
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

    if (result.isSuccess) {
      final verifiedUserId = result.userId ?? _currentUser?.id?.toString() ?? '1';
      _currentUser ??= User(
        id: verifiedUserId,
        name: 'ScanGo Customer',
        email: '',
      );

      // Pair cart session with backend
      await pairCartSession(cartCode: cartCode, faceVerified: true);
      _connectSocket();

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

  Future<bool> pairCartSession({String? cartCode, bool faceVerified = false}) async {
    try {
      final session = await _authApiService.pairCart(
        cartCode: cartCode,
        faceVerified: faceVerified,
      );
      if (session != null) {
        _currentSession = session;
        if (session.sessionId != null) {
          await _tokenStorage.saveSessionId(session.sessionId.toString());
        }
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Graceful fallback for offline demo session
    _currentSession = ShoppingSession(
      sessionId: 'sess_local_01',
      cartCode: cartCode ?? 'CART_01',
      userId: _currentUser?.id ?? '1',
      faceVerified: faceVerified,
      createdAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  void _connectSocket() {
    final socket = _socketCartService;
    final user = _currentUser;
    if (socket != null && user != null) {
      socket.connect(
        userId: user.id,
        cartCode: _currentSession?.cartCode ?? 'CART_01',
      );
    }
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
    _socketCartService?.disconnect();
    await _tokenStorage.clearAll();
    notifyListeners();
  }
}
