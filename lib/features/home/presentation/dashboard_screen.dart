import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../auth/data/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(
      BuildContext context,
      ) async {
    await AuthService.instance.logout();

    if (!context.mounted) return;

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final user =
        AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VisitorPro'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_rounded,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Authentication Successful',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
            ),
          ],
        ),
      ),
    );
  }
}