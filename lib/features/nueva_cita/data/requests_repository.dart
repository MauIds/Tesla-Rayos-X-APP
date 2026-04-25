import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/request_model.dart';
import '../../auth/presentation/providers/auth_notifier.dart';

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  return RequestsRepository(ref.watch(supabaseClientProvider));
});

class RequestsRepository {
  final SupabaseClient _client;

  RequestsRepository(this._client);

  Future<RequestModel> createRequest({
    required String servicio,
    required String servicioIcon,
    required String nombreCliente,
    required String fecha,
    String? hora,
    String? descripcion,
    String? telefono,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('requests')
        .insert({
          'user_id': userId,
          'servicio': servicio,
          'servicio_icon': servicioIcon,
          'nombre_cliente': nombreCliente,
          'fecha': fecha,
          'hora': hora,
          'descripcion': descripcion,
          'telefono': telefono,
          'estado': 'Pendiente',
        })
        .select()
        .single();
    return RequestModel.fromJson(data);
  }

  Future<void> deleteRequest(String id) async {
    await _client.from('requests').delete().eq('id', id);
  }
}
