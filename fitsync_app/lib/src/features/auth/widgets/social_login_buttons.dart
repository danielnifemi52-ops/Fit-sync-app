import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/auth_service.dart';

class SocialLoginButtons extends ConsumerStatefulWidget {
  final Function(String?) onError;

  const SocialLoginButtons({super.key, required this.onError});

  @override
  ConsumerState<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends ConsumerState<SocialLoginButtons> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // Navigation is handled by AuthWrapper
    } catch (e) {
      widget.onError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /*
  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithApple();
      // Navigation is handled by AuthWrapper
    } catch (e) {
      widget.onError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Column(
      children: [
        // Google Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.white.withOpacity(0.1),
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                  height: 20,
                  width: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.login, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Apple Button hidden for now due to build issues
        /*
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleAppleSignIn,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.black.withOpacity(0.6),
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, size: 22, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Continue with Apple',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        */
      ],
    );
  }
}
