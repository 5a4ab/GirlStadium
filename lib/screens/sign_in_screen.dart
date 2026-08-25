import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import 'sign_up_screen.dart';

// Email/password + Google sign-in for returning users. Reached from
// Intro's "Get Started" button. On success, pops back to AuthGate (the
// first route), which then shows NavigationScreen automatically.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  bool get _isBusy => _isEmailLoading || _isGoogleLoading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    return null;
  }

  Future<void> _submitEmailSignIn() async {
    if (_isBusy) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEmailLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = authErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _submitGoogleSignIn() async {
    if (_isBusy) return;

    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        setState(() => _errorMessage = 'Google sign-in failed. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = authErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthBrandMark(),
                const SizedBox(height: 24),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: AppColors.textWarm,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 28),
                if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submitEmailSignIn(),
                ),
                const SizedBox(height: 22),
                AuthPrimaryButton(
                  label: 'Sign In',
                  isLoading: _isEmailLoading,
                  onPressed: _isBusy ? null : _submitEmailSignIn,
                ),
                const SizedBox(height: 20),
                const AuthDivider(),
                const SizedBox(height: 20),
                AuthGoogleButton(
                  isLoading: _isGoogleLoading,
                  onPressed: _isBusy ? null : _submitGoogleSignIn,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _isBusy
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Create account',
                            style: TextStyle(
                              color: AppColors.accentPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
