import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06,
                  ),
                ),
            ),
          ),
          Positioned(
            bottom: 130,
              left: -100,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.04),
                ),
              ),
          ),
          SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  _buildLogo()
                      .animate()
                      .fadeIn(
                    duration: 700.ms,
                  )
                      .scale(
                    begin: const Offset(.7, .7),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 45),


              // Main illustration
              Expanded(
                child: Center(
                  child: _buildIllustration()
                      .animate()
                      .fadeIn(
                    delay: 300.ms,
                    duration: 700.ms,
                  )
                      .slideY(
                    begin: .15,
                    end: 0,
                    curve: Curves.easeOut,
                  ),
                ),
              ), const SizedBox(height: 45),
                  const Text(
                    'Secure Visits, \nEasy Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(
                    delay: 500.ms,
                    duration: 600.ms,
                  ).slideY(
                    begin: .25,
                    end: 0,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Register, check in, and manage visitors\n'
                        'easily, safely and securely.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),

                  ).animate()
                      .fadeIn(
                    delay: 650.ms,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _indicator(true),
                      _indicator(false),
                      _indicator(false),
                    ],
                  ).animate()
                      .fadeIn(
                    delay: 800.ms,
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: 'Get Started',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: (){},
                  ).animate()
                      .fadeIn(
                    delay: 900.ms,
                  )
                      .slideY(
                    begin: .3,
                    end: 0,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Login screen comes next
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ).animate()
                      .fadeIn(
                    delay: 1000.ms,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                const Color(0xFF34A5FF),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .25),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.badge_rounded,
            color: Colors.white,
            size: 27,
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
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightBlue,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .08),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 25,
            child: Container(
              width: 210,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 55,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 55,
              ),
            )
                .animate(
              onPlay: (controller) => controller.repeat(
                reverse: true,
              ),
            )
                .moveY(
              begin: -5,
              end: 5,
              duration: 1800.ms,
              curve: Curves.easeInOut,
            ),
          ),

          Positioned(
            right: 30,
            top: 60,
            child: _floatingIcon(
              Icons.qr_code_scanner_rounded,
            ).animate(
              onPlay: (controller) => controller.repeat(
                reverse: true,
              ),
            )
                .moveY(
              begin: -8,
              end: 8,
              duration: 2200.ms,
            ),
          ),

          Positioned(
            left: 25,
            top: 100,
            child: _floatingIcon(
              Icons.verified_user_rounded,
            )
                .animate(
              onPlay: (controller) => controller.repeat(
                reverse: true,
              ),
            )
                .moveY(
              begin: 7,
              end: -7,
              duration: 2000.ms,
            ),
          ),

          const Positioned(
            bottom: 52,
            child: Text(
              'Smart Visitor Management',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 23,
      ),
    );
  }

  Widget _indicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
