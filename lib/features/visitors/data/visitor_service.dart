import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/visitor.dart';

class VisitorService {
  VisitorService._();

  static final VisitorService instance = VisitorService._();

  SupabaseClient get _supabase => Supabase.instance.client;

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError('User must be authenticated.');
    }

    return user.id;
  }

  Stream<List<Visitor>> watchVisitors() {
    return _supabase
        .from('visitors')
        .stream(primaryKey: ['id'])
        .eq('created_by', _userId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows.map(Visitor.fromMap).toList(),
    );
  }

  Future<Visitor> checkInVisitor({
    required String fullName,
    required String phone,
    required String purpose,
    String? email,
    String? company,
    Uint8List? photoBytes,
  }) async {
    final now = DateTime.now();

    String? visitorId;

    try {
      final insertedData = await _supabase
          .from('visitors')
          .insert({
        'created_by': _userId,
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'email': _nullableText(email),
        'company': _nullableText(company),
        'purpose': purpose.trim(),
        'status': 'checked_in',
        'visit_date': _dateOnly(now),
        'check_in_at': now.toUtc().toIso8601String(),
      })
          .select()
          .single();

      visitorId = insertedData['id'] as String;

      if (photoBytes == null) {
        return Visitor.fromMap(insertedData);
      }

      final storagePath = '$_userId/$visitorId/profile.jpg';

      await _supabase.storage
          .from('visitor-photos')
          .uploadBinary(
        storagePath,
        photoBytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: false,
        ),
      );

      await _supabase
          .from('visitors')
          .update({'photo_url': storagePath})
          .eq('id', visitorId)
          .eq('created_by', _userId);

      final updatedData = await _supabase
          .from('visitors')
          .select()
          .eq('id', visitorId)
          .single();

      return Visitor.fromMap(updatedData);
    } catch (_) {
      // Photo upload fail hone par half-created check-in
      // ko clean karo.
      if (visitorId != null) {
        try {
          await _supabase
              .from('visitors')
              .delete()
              .eq('id', visitorId)
              .eq('created_by', _userId);
        } catch (_) {
          // Original error ko hi rethrow karenge.
        }
      }

      rethrow;
    }
  }

  /// Private bucket ke liye temporary signed URL.
  /// DB mein sirf storage *path* save hota hai, URL nahi.
  Future<String?> createVisitorPhotoUrl(
      String? photoPath,
      ) async {
    if (photoPath == null || photoPath.isEmpty) {
      return null;
    }

    try {
      return await _supabase.storage
          .from('visitor-photos')
          .createSignedUrl(
        photoPath,
        60 * 60, // 1 hour
      );
    } on StorageException {
      return null;
    }
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}