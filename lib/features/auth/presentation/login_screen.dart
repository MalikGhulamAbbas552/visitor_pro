import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/auth_service.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response =
      await AuthService.instance.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.session != null) {
        context.go(AppRoutes.dashboard);
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to login. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              24,
              28,
              24,
              30,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filledTonal(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideX(begin: -0.2),

                  const SizedBox(height: 30),

                  _buildLogo()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                    begin: const Offset(.8, .8),
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(
                    delay: 150.ms,
                    duration: 500.ms,
                  )
                      .slideY(begin: .2),

                  const SizedBox(height: 8),

                  const Text(
                    'Login to access your VisitorPro account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(
                    delay: 250.ms,
                  ),

                  const SizedBox(height: 38),

                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    onFieldSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                  )
                      .animate()
                      .fadeIn(delay: 350.ms)
                      .slideX(begin: -.08),

                  const SizedBox(height: 16),

                  Focus(
                    focusNode: _passwordFocusNode,
                    child: AuthTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) {
                        _login();
                      },
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
                          });
                        },
                        icon: AnimatedSwitcher(
                          duration:
                          const Duration(milliseconds: 200),
                          transitionBuilder:
                              (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            key: ValueKey(_obscurePassword),
                            color:
                            AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 450.ms)
                      .slideX(begin: .08),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Forgot Password screen later.
                      },
                      child: const Text(
                        'Forgot password?',
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms),

                  const SizedBox(height: 12),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? Container(
                      key: const ValueKey('loading'),
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child:
                      const SizedBox.square(
                        dimension: 23,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : PrimaryButton(
                      key: const ValueKey('button'),
                      text: 'Login',
                      icon:
                      Icons.arrow_forward_rounded,
                      onPressed: _login,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 550.ms)
                      .slideY(begin: .15),

                  const SizedBox(height: 30),

                  _buildDivider()
                      .animate()
                      .fadeIn(delay: 650.ms),

                  const SizedBox(height: 24),

                  _buildGoogleButton()
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: .15),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.register);
                        },
                        child:  Text(
                          'Register',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Hero(
        tag: 'visitor-pro-logo',
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient:  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      Color(0xFF38A8FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: .25,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                'VisitorPro',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFFE3EAF3),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFFE3EAF3),
          ),
        ),
      ],
    );
  }

}
Widget _buildGoogleButton() {
  return SizedBox(
    height: 56,
    child: OutlinedButton(
      onPressed: () {
        // Day 3: Google Sign-In with Supabase OAuth
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(
          color: Color(0xFFE1E9F3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.google,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}
