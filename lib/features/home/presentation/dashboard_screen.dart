import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/data/auth_service.dart';
import '../../visitors/data/visitor_service.dart';
import '../../visitors/domain/visitor.dart';
import '../domain/dashboard_stats.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  late final Stream<List<Visitor>>
  _visitorStream;

  @override
  void initState() {
    super.initState();

    _visitorStream =
        VisitorService.instance.watchVisitors();
  }

  String get _userName {
    final user =
        AuthService.instance.currentUser;

    final metadata =
        user?.userMetadata;

    final name =
    metadata?['full_name'] as String?;

    if (name != null &&
        name.trim().isNotEmpty) {
      return name.split(' ').first;
    }

    return 'User';
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();

    if (!mounted) return;

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Visitor>>(
          stream: _visitorStream,

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _DashboardError(
                onLogout: _logout,
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _DashboardLoading();
            }

            final visitors =
                snapshot.data ?? [];

            final stats =
            DashboardStats.fromVisitors(
              visitors,
            );

            return CustomScrollView(
              physics:
              const BouncingScrollPhysics(),

              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    userName: _userName,
                    onLogout: _logout,
                  ),
                ),

                SliverPadding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    110,
                  ),

                  sliver: SliverList.list(
                    children: [
                      _TodayVisitorsCard(
                        stats: stats,
                      ),

                      const SizedBox(height: 28),

                      const _SectionTitle(
                        title: 'Quick Actions',
                      ),

                      const SizedBox(height: 15),

                      const _QuickActions(),

                      const SizedBox(height: 30),

                      _RecentVisitorsSection(
                        visitors:
                        stats.recentVisitors,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar:
      const _DashboardNavigation(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.userName,
    required this.onLogout,
  });

  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient:
              LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xFF37A5FF),
                ],
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName 👋',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Welcome back to VisitorPro',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton.filledTonal(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Badge(
              smallSize: 7,
              child: Icon(
                Icons.notifications_none_rounded,
              ),
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                onLogout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                    ),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _TodayVisitorsCard
    extends StatelessWidget {
  const _TodayVisitorsCard({
    required this.stats,
  });

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: .94,
        end: 1,
      ),
      duration:
      const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (
          context,
          scale,
          child,
          ) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        padding:
        const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient:
           LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF2297FF),
            ],
          ),
          borderRadius:
          BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary
                  .withValues(alpha: .25),
              blurRadius: 25,
              offset:
              const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Today's Visitors",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            TweenAnimationBuilder<int>(
              tween: IntTween(
                begin: 0,
                end: stats.totalToday,
              ),
              duration:
              const Duration(
                milliseconds: 700,
              ),
              builder:
                  (context, value, _) {
                return Text(
                  '$value',
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1,
                    fontWeight:
                    FontWeight.w800,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Text(
              '${stats.waiting} waiting  •  '
                  '${stats.checkedIn} checked in',
              style: TextStyle(
                color: Colors.white
                    .withValues(alpha: .85),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    value:
                    stats.checkedIn,
                    label: 'Checked In',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    value:
                    stats.checkedOut,
                    label: 'Checked Out',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    value:
                    stats.preRegistered,
                    label: 'Expected',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: .14),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: .8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
class _QuickActions
    extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        title: 'Check In',
        icon:
        Icons.login_rounded,
        onTap: () {
          context.push(
            AppRoutes.checkIn,
          );
        },
      ),
      _QuickActionData(
        title: 'Pre-Register',
        icon:
        Icons.person_add_alt_1_rounded,
        onTap: () {
          context.push(
            AppRoutes.preRegister,
          );
        },
      ),
      _QuickActionData(
        title: 'Scan QR',
        icon:
        Icons.qr_code_scanner_rounded,
        onTap: () {
          context.push(
            AppRoutes.scanQr,
          );
        },
      ),
      _QuickActionData(
        title: 'All Visitors',
        icon:
        Icons.groups_2_rounded,
        onTap: () {
          context.push(
            AppRoutes.visitors,
          );
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final action =
        actions[index];

        return _QuickActionCard(
          action: action,
          index: index,
        );
      },
    );
  }
}
class _QuickActionCard
    extends StatelessWidget {
  const _QuickActionCard({
    required this.action,
    required this.index,
  });

  final _QuickActionData action;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds:
        400 + (index * 100),
      ),
      curve: Curves.easeOutCubic,
      builder: (
          context,
          value,
          child,
          ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              20 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(20),
          onTap: action.onTap,
          child: Container(
            padding:
            const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary
                    .withValues(
                  alpha: .07,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration:
                  BoxDecoration(
                    color: AppColors
                        .lightBlue,
                    borderRadius:
                    BorderRadius
                        .circular(14),
                  ),
                  child: Icon(
                    action.icon,
                    color:
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action.title,
                    style:
                    const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                      color: AppColors
                          .textPrimary,
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

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}
class _RecentVisitorsSection
    extends StatelessWidget {
  const _RecentVisitorsSection({
    required this.visitors,
  });

  final List<Visitor> visitors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionTitle(
                title:
                'Recent Visitors',
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(
                  AppRoutes.visitors,
                );
              },
              child:
              const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (visitors.isEmpty)
          const _EmptyVisitors()
        else
          ...List.generate(
            visitors.length,
                (index) =>
                _VisitorTile(
                  visitor:
                  visitors[index],
                  index: index,
                ),
          ),
      ],
    );
  }
}
class _VisitorTile
    extends StatelessWidget {
  const _VisitorTile({
    required this.visitor,
    required this.index,
  });

  final Visitor visitor;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween:
      Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds:
        350 + index * 80,
      ),
      builder:
          (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              15 * (1 - value),
              0,
            ),
            child: child,
          ),
        );
      },
      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 11,
        ),
        padding:
        const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor:
              AppColors.lightBlue,
              child: Text(
                _initials(
                  visitor.fullName,
                ),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    visitor.fullName,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    visitor.company ??
                        visitor.purpose ??
                        'Visitor',
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      fontSize: 11,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            _StatusChip(
              status:
              visitor.status,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'));

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(0, 1)
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}
class _StatusChip
    extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final (
    String label,
    Color color,
    ) = switch (status) {
      'checked_in' => (
      'Checked In',
      AppColors.success,
      ),

      'checked_out' => (
      'Checked Out',
      AppColors.textSecondary,
      ),

      'pre_registered' => (
      'Expected',
      Colors.purple,
      ),

      'cancelled' => (
      'Cancelled',
      AppColors.error,
      ),

      _ => (
      'Waiting',
      AppColors.warning,
      ),
    };

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(alpha: .10),
        borderRadius:
        BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }
}
class _EmptyVisitors
    extends StatelessWidget {
  const _EmptyVisitors();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 45,
            color:
            AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'No visitors today',
            style: TextStyle(
              fontWeight:
              FontWeight.w600,
              color:
              AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'New visitors will appear here.',
            style: TextStyle(
              fontSize: 11,
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardLoading
    extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child:
      CircularProgressIndicator(),
    );
  }
}

class _DashboardError
    extends StatelessWidget {
  const _DashboardError({
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onLogout,
              child:
              const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight:
        FontWeight.w700,
        color:
        AppColors.textPrimary,
      ),
    );
  }
}
class _DashboardNavigation
    extends StatelessWidget {
  const _DashboardNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(
          icon:
          Icon(Icons.home_outlined),
          selectedIcon:
          Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon:
          Icon(Icons.people_outline),
          selectedIcon:
          Icon(Icons.people),
          label: 'Visitors',
        ),
        NavigationDestination(
          icon: Icon(
            Icons
                .qr_code_scanner_rounded,
          ),
          label: 'Scan',
        ),
        NavigationDestination(
          icon: Icon(
            Icons
                .notifications_none_rounded,
          ),
          selectedIcon: Icon(
            Icons.notifications_rounded,
          ),
          label: 'Alerts',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline_rounded,
          ),
          selectedIcon: Icon(
            Icons.person_rounded,
          ),
          label: 'Profile',
        ),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            break;

          case 1:
            context.push(
              AppRoutes.visitors,
            );
            break;

          case 2:
            context.push(
              AppRoutes.scanQr,
            );
            break;

          case 3:
          // Notifications screen
            break;

          case 4:
          // Profile screen
            break;
        }
      },
    );
  }
}