import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_notifier.dart';
import '../../domain/auth_state.dart' as domain;

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _showPass = false;
  bool _showConfirm = false;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onSignup() {
    setState(() => _localError = null);
    final email = _emailController.text.trim();
    final pass = _passController.text;
    final confirm = _confirmPassController.text;

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _localError = 'Todos los campos son obligatorios');
      return;
    }
    if (pass.length < 6) {
      setState(
          () => _localError = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (pass != confirm) {
      setState(() => _localError = 'Las contraseñas no coinciden');
      return;
    }

    ref.read(authNotifierProvider.notifier).signUpWithEmail(email, pass);
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
          SnackBar(
            content: Text('Revisa tu correo para confirmar tu cuenta'),
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
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Crear cuenta',
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
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Correo electrónico'),
                const SizedBox(height: 8),
                _field(
                  controller: _emailController,
                  hint: 'nombre@empresa.com',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _label('Contraseña'),
                const SizedBox(height: 8),
                _field(
                  controller: _passController,
                  hint: '••••••',
                  icon: Icons.lock_outline,
                  obscure: !_showPass,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _showPass = !_showPass),
                    child: Icon(
                      _showPass ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColors.outline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _label('Confirmar contraseña'),
                const SizedBox(height: 8),
                _field(
                  controller: _confirmPassController,
                  hint: '••••••',
                  icon: Icons.lock_outline,
                  obscure: !_showConfirm,
                  suffix: GestureDetector(
                    onTap: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    child: Icon(
                      _showConfirm ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColors.outline,
                    ),
                  ),
                ),
                if (_localError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _localError!,
                    style: GoogleFonts.manrope(
                        fontSize: 13, color: AppColors.error),
                  ),
                ],
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
                      onPressed: isLoading ? null : _onSignup,
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
                          : Text('Crear cuenta',
                              style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant),
                        children: [
                          const TextSpan(text: '¿Ya tienes cuenta? '),
                          TextSpan(
                            text: 'Inicia sesión',
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
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
          if (suffix != null) suffix,
        ],
      ),
    );
  }
}
