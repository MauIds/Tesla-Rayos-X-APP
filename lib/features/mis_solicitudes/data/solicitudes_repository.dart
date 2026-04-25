import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../nueva_cita/domain/request_model.dart';
import '../../auth/presentation/providers/auth_notifier.dart';
import '../../auth/domain/auth_state.dart' as domain;

final solicitudesStreamProvider = StreamProvider.autoDispose<List<RequestModel>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is! domain.AuthAuthenticated) return Stream.value([]);
  final client = ref.watch(supabaseClientProvider);
  return client
      .from('requests')
      .stream(primaryKey: ['id'])
      .eq('user_id', authState.user.id)
      .order('created_at', ascending: false)
      .map((data) => data.map(RequestModel.fromJson).toList());
});
