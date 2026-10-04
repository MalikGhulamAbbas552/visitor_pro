import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_service.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
  TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);

    try {
      final response =
      await AuthService.instance.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Email confirmation ON
      if (response.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created. Please verify your email before logging in.',
            ),
          ),
        );

        context.go(AppRoutes.login);
        return;
      }

      // Email confirmation OFF
      context.go(AppRoutes.dashboard);
    } on AuthException catch (error) {
      if (!mounted) return;

      _showError(error.message);
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.filledTonal(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Icon(
                  Icons.badge_rounded,
                  color: AppColors.primary,
                  size: 55,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Create your VisitorPro account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 35),

                AuthTextField(
                  controller: _nameController,
                  hintText: 'Full name',
                  prefixIcon:
                  Icons.person_outline_rounded,
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 3) {
                      return 'Enter your full name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  prefixIcon:
                  Icons.email_outlined,
                  keyboardType:
                  TextInputType.emailAddress,
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Enter your email';
                    }

                    final validEmail = RegExp(
                      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                    ).hasMatch(email);

                    if (!validEmail) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon:
                  Icons.lock_outline_rounded,
                  obscureText: _hidePassword,
                  textInputAction:
                  TextInputAction.next,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidePassword =
                        !_hidePassword;
                      });
                    },
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.length < 8) {
                      return 'Use at least 8 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                AuthTextField(
                  controller:
                  _confirmPasswordController,
                  hintText: 'Confirm password',
                  prefixIcon:
                  Icons.lock_outline_rounded,
                  obscureText:
                  _hideConfirmPassword,
                  textInputAction:
                  TextInputAction.done,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hideConfirmPassword =
                        !_hideConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value !=
                        _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) {
                    _register();
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed:
                    _loading ? null : _register,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox.square(
                      dimension: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color:
                        AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go(
                          AppRoutes.login,
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}