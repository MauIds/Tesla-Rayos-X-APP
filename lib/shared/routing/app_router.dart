import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/nueva_cita/presentation/screens/nueva_cita_screen.dart';
import '../../features/mis_solicitudes/presentation/screens/mis_solicitudes_screen.dart';
import '../../features/mis_solicitudes/data/solicitudes_repository.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/admin/data/admin_repository.dart';
import 'app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      // Still initializing — wait, don't redirect yet
      if (authState is AuthInitial || authState is AuthLoading) return null;

      final isAuth = authState is AuthAuthenticated;
      final onAuthScreen = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isAuth && !onAuthScreen) return AppRoutes.login;
      if (isAuth && onAuthScreen) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const _HomeShell()),
      GoRoute(
          path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
    ],
  );

  // Refresh router on every auth state change without rebuilding GoRouter
  ref.listen(authNotifierProvider, (_, __) => router.refresh());

  return router;
});

class _HomeShell extends ConsumerStatefulWidget {
  const _HomeShell();

  @override
  ConsumerState<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<_HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(solicitudesStreamProvider);
    final badge = solicitudesAsync.valueOrNull?.length ?? 0;

    final profileAsync = ref.watch(profileProvider);
    final isAdmin = profileAsync.valueOrNull?.isAdmin ?? false;

    // Pending admin count badge
    final allAsync = isAdmin ? ref.watch(allRequestsStreamProvider) : null;
    final pendingCount = allAsync?.valueOrNull
            ?.where((r) => r.estado == 'Pendiente')
            .length ??
        0;

    final authState = ref.watch(authNotifierProvider);
    final email = authState is AuthAuthenticated
        ? (authState.user.email ?? '')
        : '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    final titles = ['Nueva Solicitud', 'Mis Solicitudes', if (isAdmin) 'Admin'];
    final safeTab = _tab.clamp(0, titles.length - 1);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titles[safeTab],
                    style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initial,
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: safeTab,
                children: [
                  const NuevaCitaScreen(),
                  const MisSolicitudesScreen(),
                  if (isAdmin) const AdminScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomTabBar(
        activeIndex: safeTab,
        badge: badge,
        isAdmin: isAdmin,
        pendingCount: pendingCount,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  final int activeIndex;
  final int badge;
  final bool isAdmin;
  final int pendingCount;
  final ValueChanged<int> onTap;

  const _BottomTabBar({
    required this.activeIndex,
    required this.badge,
    required this.isAdmin,
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD9FFFFFF),
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            _TabItem(
              icon: Icons.add_circle,
              label: 'Nueva Cita',
              active: activeIndex == 0,
              onTap: () => onTap(0),
            ),
            _TabItem(
              icon: Icons.list_alt,
              label: 'Mis Solicitudes',
              active: activeIndex == 1,
              badge: badge,
              onTap: () => onTap(1),
            ),
            if (isAdmin)
              _TabItem(
                icon: Icons.admin_panel_settings,
                label: 'Admin',
                active: activeIndex == 2,
                badge: pendingCount,
                onTap: () => onTap(2),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.outline;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 26, color: color),
                  if (badge > 0)
                    Positioned(
                      top: -4,
                      right: -10,
                      child: Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$badge',
                          style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
