import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../nueva_cita/domain/request_model.dart';
import '../../auth/presentation/providers/auth_notifier.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
});

final allRequestsStreamProvider = StreamProvider.autoDispose<List<RequestModel>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client
      .from('requests')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.map(RequestModel.fromJson).toList());
});

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<void> updateRequestStatus(String id, String estado) async {
    await _client
        .from('requests')
        .update({'estado': estado})
        .eq('id', id);
  }
}
