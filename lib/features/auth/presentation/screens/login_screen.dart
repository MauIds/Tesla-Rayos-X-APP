import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/routing/app_routes.dart';
import '../providers/auth_notifier.dart';
import '../../domain/auth_state.dart' as domain;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    final pass = _passController.text;
    if (email.isEmpty || pass.isEmpty) return;
    ref.read(authNotifierProvider.notifier).signInWithEmail(email, pass);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<domain.AuthState>(authNotifierProvider, (_, state) {
      if (state is domain.AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is domain.AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.bolt, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bienvenido de\nnuevo',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tesla Rayos X & Control Biológico',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Form card
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email
                  Text('Correo electrónico',
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _emailController,
                    hint: 'nombre@empresa.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  // Password header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Contraseña',
                          style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface)),
                      GestureDetector(
                        onTap: () =>
                            context.push(AppRoutes.forgotPassword),
                        child: Text('¿Olvidaste tu contraseña?',
                            style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryContainer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _passController,
                    hint: '••••••',
                    icon: Icons.lock_outline,
                    obscure: !_showPass,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _showPass = !_showPass),
                      child: Icon(
                        _showPass
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryContainer
                          ],
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
                        onPressed: isLoading ? null : _onLogin,
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
                            : Text('Iniciar sesión',
                                style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(color: AppColors.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('O ACCEDE CON',
                            style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                                letterSpacing: 1.5)),
                      ),
                      const Expanded(
                          child: Divider(color: AppColors.outlineVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // SSO only (Google desactivado por ahora)
                  _SocialButton(
                    icon: Icons.grid_view,
                    label: 'SSO — Próximamente',
                    onTap: null,
                  ),
                  const SizedBox(height: 24),
                  // Sign up link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.signup),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant),
                          children: [
                            const TextSpan(text: '¿No tienes cuenta? '),
                            TextSpan(
                              text: 'Regístrate',
                              style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryContainer),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: GoogleFonts.manrope(
                  fontSize: 15, color: AppColors.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.manrope(
                    fontSize: 15, color: AppColors.outline),
                isCollapsed: true,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}
