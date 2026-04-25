import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDisplayName(String userId) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(profileRepositoryProvider).updateDisplayName(userId, name);
    ref.invalidate(profileProvider);
    setState(() {
      _saving = false;
      _editing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre actualizado'),
          backgroundColor: AppColors.statusApproved,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar sesión',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: Text('¿Seguro que quieres cerrar sesión?',
            style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.manrope(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cerrar sesión',
                style:
                    GoogleFonts.manrope(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Mi Perfil',
            style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface)),
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          final initial = profile?.displayInitial ?? '?';
          final displayName = profile?.displayName ?? '';
          final email = profile?.email ?? '';

          if (_editing && _nameController.text.isEmpty) {
            _nameController.text = displayName;
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 16),
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Display name
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nombre',
                            style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline)),
                        if (!_editing)
                          GestureDetector(
                            onTap: () {
                              _nameController.text = displayName;
                              setState(() => _editing = true);
                            },
                            child: Text('Editar',
                                style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        AppColors.primaryContainer)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_editing)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              autofocus: true,
                              style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  color: AppColors.onSurface),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Tu nombre',
                                hintStyle: GoogleFonts.manrope(
                                    color: AppColors.outline),
                                isCollapsed: true,
                              ),
                            ),
                          ),
                          if (_saving)
                            const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                          else ...[
                            TextButton(
                              onPressed: () => setState(
                                  () => _editing = false),
                              child: Text('Cancelar',
                                  style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      color: AppColors.outline)),
                            ),
                            TextButton(
                              onPressed: () => _saveDisplayName(
                                  profile?.id ?? ''),
                              child: Text('Guardar',
                                  style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ],
                      )
                    else
                      Text(
                        displayName.isNotEmpty
                            ? displayName
                            : 'Sin nombre',
                        style: GoogleFonts.manrope(
                            fontSize: 15,
                            color: displayName.isNotEmpty
                                ? AppColors.onSurface
                                : AppColors.outline),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Email
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Correo electrónico',
                        style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.outline)),
                    const SizedBox(height: 6),
                    Text(email,
                        style: GoogleFonts.manrope(
                            fontSize: 15,
                            color: AppColors.onSurface)),
                  ],
                ),
              ),
              if (profile?.isAdmin == true) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Cuenta de Administrador',
                          style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              // Logout
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side:
                        const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon:
                      const Icon(Icons.logout, size: 18),
                  label: Text('Cerrar sesión',
                      style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
