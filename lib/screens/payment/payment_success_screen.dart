import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../state/auth_provider.dart';
import '../../state/cart_provider.dart';
import '../../state/payment_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scango_logo.dart';
import '../../widgets/step_progress_bar.dart';
import '../welcome/welcome_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  void _returnToHome(BuildContext context) {
    // Clear state & navigate home
    Provider.of<CartProvider>(context, listen: false).clearCart();
    Provider.of<AuthProvider>(context, listen: false).reset();
    Provider.of<PaymentProvider>(context, listen: false).reset();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ScanGoLogo(height: 38, isDarkBackground: false),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // All 3 Steps completed indicator
              const StepProgressBar(currentStep: 3),
              const Spacer(),

              // Light Cream/Pink Rounded Card Container from screenshot
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successCardBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Green Circle Check Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outlined,
                        size: 56,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Payment Successful',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Payment completed. Tap "Next" to view your receipt details and your exit pass code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Successful Green Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successBadgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.successBadgeText,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Successful',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successBadgeText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Next Button at bottom
              PrimaryButton(
                label: 'Next',
                backgroundColor: AppColors.primaryGreenDark,
                onPressed: () => _returnToHome(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
