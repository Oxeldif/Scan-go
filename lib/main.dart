import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/api_client.dart';
import 'services/auth/auth_api_service.dart';
import 'services/api_face_recognition_service.dart';
import 'services/face_recognition_service.dart';
import 'services/mock_computer_vision_service.dart';
import 'services/mock_face_recognition_service.dart';
import 'services/mock_payment_service.dart';
import 'services/token_storage_service.dart';
import 'state/auth_provider.dart';
import 'state/cart_provider.dart';
import 'state/payment_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Core Storage & API Services
  final tokenStorage = TokenStorageService();
  final apiClient = ApiClient(tokenStorage: tokenStorage);
  final authApiService = AuthApiService(apiClient: apiClient);

  // Service Singletons (Supports Environment-based Mock/Production Mode)
  final cvService = MockComputerVisionService();
  final FaceRecognitionService faceService = AppConstants.useMockServices
      ? MockFaceRecognitionService()
      : ApiFaceRecognitionService(tokenStorage: tokenStorage);
  final paymentService = MockPaymentService();

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorageService>.value(value: tokenStorage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthApiService>.value(value: authApiService),
        Provider<MockComputerVisionService>.value(value: cvService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            faceService: faceService,
            authApiService: authApiService,
            tokenStorage: tokenStorage,
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(cvService)),
        ChangeNotifierProvider(create: (_) => PaymentProvider(paymentService)),
      ],
      child: const ScanGoApp(),
    ),
  );
}

class ScanGoApp extends StatelessWidget {
  const ScanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppColors.primaryGreen,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
