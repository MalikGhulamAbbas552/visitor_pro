import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../data/visitor_service.dart';
import '../domain/visitor.dart';
import 'widgets/visitor_avatar.dart';

enum VisitorFilter {
  all,
  waiting,
  checkedIn,
  checkedOut,
  expected,
}

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({
    super.key,
  });

  @override
  State<VisitorsScreen> createState() =>
      _VisitorsScreenState();
}

class _VisitorsScreenState
    extends State<VisitorsScreen> {
  final _searchController =
  TextEditingController();

  late final Stream<List<Visitor>>
  _visitorsStream;

  VisitorFilter _selectedFilter =
      VisitorFilter.all;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _visitorsStream =
        VisitorService.instance.watchVisitors();

    _searchController.addListener(
      _onSearchChanged,
    );
  }

  void _onSearchChanged() {
    final query =
    _searchController.text
        .trim()
        .toLowerCase();

    if (query == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _searchController
        .removeListener(_onSearchChanged);

    _searchController.dispose();

    super.dispose();
  }

  List<Visitor> _filterVisitors(
      List<Visitor> visitors,
      ) {
    return visitors.where((visitor) {
      final matchesSearch =
          _searchQuery.isEmpty ||
              visitor.fullName
                  .toLowerCase()
                  .contains(_searchQuery) ||
              (visitor.company ?? '')
                  .toLowerCase()
                  .contains(_searchQuery) ||
              (visitor.phone ?? '')
                  .toLowerCase()
                  .contains(_searchQuery) ||
              (visitor.email ?? '')
                  .toLowerCase()
                  .contains(_searchQuery);

      final matchesStatus =
      switch (_selectedFilter) {
        VisitorFilter.all => true,

        VisitorFilter.waiting =>
        visitor.status == 'waiting',

        VisitorFilter.checkedIn =>
        visitor.status == 'checked_in',

        VisitorFilter.checkedOut =>
        visitor.status == 'checked_out',

        VisitorFilter.expected =>
        visitor.status ==
            'pre_registered',
      };

      return matchesSearch &&
          matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        backgroundColor:
        AppColors.background,
        surfaceTintColor:
        Colors.transparent,
        title: const Text(
          'All Visitors',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),

      body: StreamBuilder<List<Visitor>>(
        stream: _visitorsStream,

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message:
              'Unable to load visitors.',
              onRetry: () {
                setState(() {
                  _visitorsStream =
                      VisitorService.instance
                          .watchVisitors();
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final allVisitors =
          snapshot.data!;

          final visitors =
          _filterVisitors(
            allVisitors,
          );

          return Column(
            children: [
              _SearchSection(
                controller:
                _searchController,
                totalVisitors:
                allVisitors.length,
              ),

              _FilterSection(
                selected:
                _selectedFilter,
                visitors:
                allVisitors,
                onChanged: (filter) {
                  setState(() {
                    _selectedFilter =
                        filter;
                  });
                },
              ),

              const SizedBox(height: 8),

              Expanded(
                child: AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds: 250,
                  ),
                  child: visitors.isEmpty
                      ? _EmptyState(
                    key: ValueKey(
                      'empty-'
                          '$_selectedFilter-'
                          '$_searchQuery',
                    ),
                    hasSearch:
                    _searchQuery
                        .isNotEmpty,
                    onClear: () {
                      _searchController
                          .clear();

                      setState(() {
                        _selectedFilter =
                            VisitorFilter
                                .all;
                      });
                    },
                  )
                      : _VisitorsList(
                    key: ValueKey(
                      'list-'
                          '$_selectedFilter-'
                          '$_searchQuery',
                    ),
                    visitors:
                    visitors,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
class _SearchSection
    extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.totalVisitors,
  });

  final TextEditingController controller;
  final int totalVisitors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        12,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            textInputAction:
            TextInputAction.search,
            decoration: InputDecoration(
              hintText:
              'Search visitors...',
              prefixIcon: const Icon(
                Icons.search_rounded,
              ),
              suffixIcon:
              ValueListenableBuilder<
                  TextEditingValue>(
                valueListenable:
                controller,
                builder: (
                    context,
                    value,
                    _,
                    ) {
                  if (value.text.isEmpty) {
                    return const SizedBox
                        .shrink();
                  }

                  return IconButton(
                    tooltip:
                    'Clear search',
                    onPressed:
                    controller.clear,
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  );
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(17),
                borderSide:
                BorderSide.none,
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(17),
                borderSide:
                BorderSide(
                  color: AppColors
                      .primary
                      .withValues(
                    alpha: .07,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '$totalVisitors total visitors',
            style: const TextStyle(
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
class _FilterSection
    extends StatelessWidget {
  const _FilterSection({
    required this.selected,
    required this.visitors,
    required this.onChanged,
  });

  final VisitorFilter selected;
  final List<Visitor> visitors;
  final ValueChanged<VisitorFilter>
  onChanged;

  int _count(
      VisitorFilter filter,
      ) {
    return switch (filter) {
      VisitorFilter.all =>
      visitors.length,

      VisitorFilter.waiting =>
      visitors
          .where(
            (visitor) =>
        visitor.status ==
            'waiting',
      )
          .length,

      VisitorFilter.checkedIn =>
      visitors
          .where(
            (visitor) =>
        visitor.status ==
            'checked_in',
      )
          .length,

      VisitorFilter.checkedOut =>
      visitors
          .where(
            (visitor) =>
        visitor.status ==
            'checked_out',
      )
          .length,

      VisitorFilter.expected =>
      visitors
          .where(
            (visitor) =>
        visitor.status ==
            'pre_registered',
      )
          .length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        children: [
          _FilterChip(
            title: 'All',
            count:
            _count(
              VisitorFilter.all,
            ),
            selected:
            selected ==
                VisitorFilter.all,
            onTap: () => onChanged(
              VisitorFilter.all,
            ),
          ),

          _FilterChip(
            title: 'Waiting',
            count:
            _count(
              VisitorFilter.waiting,
            ),
            selected:
            selected ==
                VisitorFilter.waiting,
            onTap: () => onChanged(
              VisitorFilter.waiting,
            ),
          ),

          _FilterChip(
            title: 'Checked In',
            count:
            _count(
              VisitorFilter.checkedIn,
            ),
            selected:
            selected ==
                VisitorFilter.checkedIn,
            onTap: () => onChanged(
              VisitorFilter.checkedIn,
            ),
          ),

          _FilterChip(
            title: 'Checked Out',
            count:
            _count(
              VisitorFilter.checkedOut,
            ),
            selected:
            selected ==
                VisitorFilter.checkedOut,
            onTap: () => onChanged(
              VisitorFilter.checkedOut,
            ),
          ),

          _FilterChip(
            title: 'Expected',
            count:
            _count(
              VisitorFilter.expected,
            ),
            selected:
            selected ==
                VisitorFilter.expected,
            onTap: () => onChanged(
              VisitorFilter.expected,
            ),
          ),
        ],
      ),
    );
  }
}
class _FilterChip
    extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(
        right: 8,
      ),
      child: Material(
        color: selected
            ? AppColors.primary
            : Colors.white,
        borderRadius:
        BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(30),
          child: AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 200,
            ),
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius
                  .circular(30),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.primary
                    .withValues(
                  alpha: .10,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppColors
                        .textPrimary,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration:
                  BoxDecoration(
                    color: selected
                        ? Colors.white
                        .withValues(
                      alpha: .20,
                    )
                        : AppColors
                        .lightBlue,
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors
                          .primary,
                      fontSize: 9,
                      fontWeight:
                      FontWeight
                          .w700,
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
class _VisitorsList
    extends StatelessWidget {
  const _VisitorsList({
    super.key,
    required this.visitors,
  });

  final List<Visitor> visitors;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics:
      const BouncingScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        110,
      ),
      itemCount: visitors.length,
      itemBuilder: (
          context,
          index,
          ) {
        return _VisitorCard(
          visitor:
          visitors[index],
          index: index,
        );
      },
    );
  }
}
class _VisitorCard
    extends StatelessWidget {
  const _VisitorCard({
    required this.visitor,
    required this.index,
  });

  final Visitor visitor;
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
        300 +
            ((index.clamp(0, 5)) * 70),
      ),
      curve: Curves.easeOutCubic,
      builder: (
          context,
          value,
          child,
          ) {
        return Opacity(
          opacity: value,
          child:
          Transform.translate(
            offset: Offset(
              0,
              16 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: Padding(
        padding:
        const EdgeInsets.only(
          bottom: 12,
        ),
        child: Material(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
          child: InkWell(
            borderRadius:
            BorderRadius.circular(20),
            onTap: () {
              // Step 9:
              // Visitor Detail route
            },
            child: Padding(
              padding:
              const EdgeInsets.all(
                15,
              ),
              child: Row(
                children: [
                  VisitorAvatar(
                    name:
                    visitor.fullName,
                    photoPath:
                    visitor.photoUrl,
                    radius: 27,
                  ),

                  const SizedBox(
                    width: 13,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                visitor
                                    .fullName,
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                const TextStyle(
                                  fontSize:
                                  14,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                  color:
                                  AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            _VisitorStatus(
                              status:
                              visitor
                                  .status,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        if ((visitor.company ??
                            '')
                            .isNotEmpty)
                          _InfoRow(
                            icon: Icons
                                .business_outlined,
                            value: visitor
                                .company!,
                          ),

                        if ((visitor.company ??
                            '')
                            .isNotEmpty)
                          const SizedBox(
                            height: 4,
                          ),

                        _InfoRow(
                          icon: Icons
                              .phone_outlined,
                          value:
                          visitor.phone ??
                              'No phone',
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .schedule_rounded,
                              size: 13,
                              color: AppColors
                                  .textSecondary,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              _visitTime(
                                visitor,
                              ),
                              style:
                              const TextStyle(
                                fontSize:
                                10,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons
                                  .chevron_right_rounded,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _visitTime(
      Visitor visitor,
      ) {
    final date =
        visitor.checkInAt ??
            visitor.createdAt;

    final local =
    date.toLocal();

    final hour =
    local.hour == 0
        ? 12
        : local.hour > 12
        ? local.hour - 12
        : local.hour;

    final minute =
    local.minute
        .toString()
        .padLeft(2, '0');

    final period =
    local.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }
}
class _VisitorStatus
    extends StatelessWidget {
  const _VisitorStatus({
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
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .10,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }
}
class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color:
          AppColors.textSecondary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors
                  .textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
class _EmptyState
    extends StatelessWidget {
  const _EmptyState({
    super.key,
    required this.hasSearch,
    required this.onClear,
  });

  final bool hasSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding:
        const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration:
              const BoxDecoration(
                color:
                AppColors.lightBlue,
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons
                    .search_off_rounded
                    : Icons
                    .groups_2_outlined,
                size: 45,
                color:
                AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              hasSearch
                  ? 'No visitors found'
                  : 'No visitors here',
              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
                color: AppColors
                    .textPrimary,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              hasSearch
                  ? 'Try another name, phone, email or company.'
                  : 'Visitors matching this status will appear here.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors
                    .textSecondary,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Clear Filters',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
                  .cloud_off_rounded,
              size: 55,
              color:
              AppColors.error,
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              message,
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(
              height: 18,
            ),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}