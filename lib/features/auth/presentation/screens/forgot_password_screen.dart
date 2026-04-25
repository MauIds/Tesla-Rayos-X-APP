import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_notifier.dart';
import '../../domain/auth_state.dart' as domain;

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSend() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    ref.read(authNotifierProvider.notifier).resetPasswordForEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<domain.AuthState>(authNotifierProvider, (prev, state) {
      if (state is domain.AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error),
        );
      }
      if (prev is domain.AuthLoading && state is domain.AuthUnauthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Te enviamos un enlace de recuperación a tu correo'),
            backgroundColor: AppColors.statusApproved,
          ),
        );
        context.pop();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is domain.AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Recuperar\ncontraseña',
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Te enviaremos un enlace para restablecer tu contraseña.',
              style: GoogleFonts.manrope(
                  fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Text('Correo electrónico',
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline,
                      size: 20, color: AppColors.outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.manrope(
                          fontSize: 15, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'nombre@empresa.com',
                        hintStyle: GoogleFonts.manrope(
                            fontSize: 15, color: AppColors.outline),
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D004BCA),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: TextButton(
                  onPressed: isLoading ? null : _onSend,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Enviar enlace',
                          style: GoogleFonts.manrope(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
