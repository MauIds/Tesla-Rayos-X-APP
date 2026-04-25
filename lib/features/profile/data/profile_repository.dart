import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/profile_model.dart';
import '../../auth/presentation/providers/auth_notifier.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

final profileProvider = FutureProvider.autoDispose<ProfileModel?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return null;
  return ref.read(profileRepositoryProvider).fetchProfile(userId);
});

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<ProfileModel?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<void> updateDisplayName(String userId, String name) async {
    await _client
        .from('profiles')
        .update({'display_name': name})
        .eq('id', userId);
  }
}
