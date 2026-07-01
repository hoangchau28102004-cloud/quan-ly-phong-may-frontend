import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Return a friendly error instead of letting the underlying assertion crash.
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception(
        'Supabase chưa được khởi tạo. Thiết lập SUPABASE_URL và SUPABASE_ANON_KEY trong .env, hoặc khởi tạo Supabase trước khi gọi SupabaseService.',
      );
    }
  }

  static bool get isInitialized {
    try {
      // Accessing Supabase.instance will throw if not initialized
      final _ = Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetch(
    String table, {
    String? select,
    String? orderBy,
    bool descending = false,
  }) async {
    if (!isInitialized) {
      throw Exception(
        'Supabase chưa được khởi tạo. Không thể fetch bảng $table.',
      );
    }
    final selectStr = select ?? '*';
    dynamic query = client.from(table).select(selectStr);
    if (orderBy != null && orderBy.isNotEmpty) {
      query = query.order(orderBy, ascending: !descending);
    }
    final res = await (query as dynamic).execute();
    final data = (res as dynamic).data;
    final error = (res as dynamic).error;
    if (error != null) {
      final message = (error as dynamic).message ?? error.toString();
      throw Exception(message);
    }
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  static Future<dynamic> insert(String table, Map<String, dynamic> data) async {
    if (!isInitialized) {
      throw Exception(
        'Supabase chưa được khởi tạo. Không thể insert vào $table.',
      );
    }
    final res = await (client.from(table) as dynamic).insert([data]).execute();
    final error = (res as dynamic).error;
    if (error != null) {
      throw Exception((error as dynamic).message ?? error.toString());
    }
    return (res as dynamic).data;
  }

  static Future<dynamic> update(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    if (!isInitialized) {
      throw Exception('Supabase chưa được khởi tạo. Không thể update $table.');
    }
    final res = await (client.from(table) as dynamic)
        .update(data)
        .eq(column, value)
        .execute();
    final error = (res as dynamic).error;
    if (error != null) {
      throw Exception((error as dynamic).message ?? error.toString());
    }
    return (res as dynamic).data;
  }

  static Future<dynamic> delete(
    String table,
    String column,
    dynamic value,
  ) async {
    if (!isInitialized) {
      throw Exception('Supabase chưa được khởi tạo. Không thể delete $table.');
    }
    final res = await (client.from(table) as dynamic)
        .delete()
        .eq(column, value)
        .execute();
    final error = (res as dynamic).error;
    if (error != null) {
      throw Exception((error as dynamic).message ?? error.toString());
    }
    return (res as dynamic).data;
  }
}
