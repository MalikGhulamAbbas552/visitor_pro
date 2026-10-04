import '../../visitors/domain/visitor.dart';

class DashboardStats {
  const DashboardStats({
    required this.totalToday,
    required this.waiting,
    required this.checkedIn,
    required this.checkedOut,
    required this.preRegistered,
    required this.recentVisitors,
  });

  final int totalToday;
  final int waiting;
  final int checkedIn;
  final int checkedOut;
  final int preRegistered;

  final List<Visitor> recentVisitors;

  factory DashboardStats.fromVisitors(
      List<Visitor> visitors,
      ) {
    final now = DateTime.now();

    bool isToday(DateTime date) {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }

    final todayVisitors = visitors
        .where(
          (visitor) =>
          isToday(visitor.visitDate),
    )
        .toList();

    return DashboardStats(
      totalToday: todayVisitors.length,

      waiting: todayVisitors
          .where(
            (visitor) =>
        visitor.status == 'waiting',
      )
          .length,

      checkedIn: todayVisitors
          .where(
            (visitor) =>
        visitor.status == 'checked_in',
      )
          .length,

      checkedOut: todayVisitors
          .where(
            (visitor) =>
        visitor.status == 'checked_out',
      )
          .length,

      preRegistered: todayVisitors
          .where(
            (visitor) =>
        visitor.status ==
            'pre_registered',
      )
          .length,

      recentVisitors:
      todayVisitors.take(5).toList(),
    );
  }
}