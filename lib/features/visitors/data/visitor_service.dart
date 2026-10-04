import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/visitor.dart';

class VisitorService {
  VisitorService._();

  static final VisitorService instance =
  VisitorService._();

  SupabaseClient get _supabase =>
      Supabase.instance.client;

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError(
        'User must be authenticated.',
      );
    }

    return user.id;
  }

  Stream<List<Visitor>> watchVisitors() {
    return _supabase
        .from('visitors')
        .stream(primaryKey: ['id'])
        .eq('created_by', _userId)
        .order(
      'created_at',
      ascending: false,
    )
        .map(
          (rows) => rows
          .map(Visitor.fromMap)
          .toList(),
    );
  }
}