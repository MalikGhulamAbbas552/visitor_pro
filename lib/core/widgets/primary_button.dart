import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  const PrimaryButton({super.key, required this.text, required this.onPressed, this.icon});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTap: widget.onPressed,
      child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                Color(0xFF2196FF),
              ],
          ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8)
              ),
            ],
        ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 20,
                ),
              ]
            ],
          ),
      ),
      ),
    );
  }
}
