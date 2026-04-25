import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../nueva_cita/domain/request_model.dart';
import '../../data/admin_repository.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Todas', 'Pendientes', 'Aprobadas', 'Rechazadas'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RequestModel> _filter(List<RequestModel> all, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return all.where((r) => r.estado == 'Pendiente').toList();
      case 2:
        return all.where((r) => r.estado == 'Aprobado').toList();
      case 3:
        return all.where((r) => r.estado == 'Rechazado').toList();
      default:
        return all;
    }
  }

  Future<void> _updateStatus(String id, String estado) async {
    await ref.read(adminRepositoryProvider).updateRequestStatus(id, estado);
    if (mounted) {
      final label = estado == 'Aprobado' ? 'aprobada' : 'rechazada';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud $label'),
          backgroundColor: estado == 'Aprobado'
              ? AppColors.statusApproved
              : AppColors.statusRejected,
        ),
      );
    }
  }

  static String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat("d MMM y", 'es').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allRequestsStreamProvider);

    return Column(
      children: [
        // Tab bar
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                GoogleFonts.manrope(fontSize: 13),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
            onTap: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: allAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (all) {
              final filtered =
                  _filter(all, _tabController.index);
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox,
                          size: 48, color: AppColors.outlineVariant),
                      const SizedBox(height: 12),
                      Text('Sin solicitudes',
                          style: GoogleFonts.manrope(
                              fontSize: 15,
                              color: AppColors.outline)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(allRequestsStreamProvider),
                child: ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _AdminCard(
                    solicitud: filtered[i],
                    onApprove: () =>
                        _updateStatus(filtered[i].id, 'Aprobado'),
                    onReject: () =>
                        _updateStatus(filtered[i].id, 'Rechazado'),
                    formatFecha: _formatFecha,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  final RequestModel solicitud;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String Function(String) formatFecha;

  const _AdminCard({
    required this.solicitud,
    required this.onApprove,
    required this.onReject,
    required this.formatFecha,
  });

  static Color _statusColor(String estado) {
    switch (estado) {
      case 'Aprobado':
        return AppColors.statusApproved;
      case 'Rechazado':
        return AppColors.statusRejected;
      default:
        return AppColors.statusPending;
    }
  }

  static IconData _serviceIcon(String iconName) {
    switch (iconName) {
      case 'construction':
        return Icons.construction;
      case 'biotech':
        return Icons.biotech;
      case 'build':
        return Icons.build;
      case 'request_quote':
        return Icons.request_quote;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(solicitud.estado);
    final isPending = solicitud.estado == 'Pendiente';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_serviceIcon(solicitud.servicioIcon),
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(solicitud.servicio,
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface)),
                    Text(solicitud.nombreCliente,
                        style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.outline)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(solicitud.estado,
                    style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 13, color: AppColors.outline),
              const SizedBox(width: 4),
              Text(formatFecha(solicitud.fecha),
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant)),
              if (solicitud.hora != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.schedule,
                    size: 13, color: AppColors.outline),
                const SizedBox(width: 4),
                Text(solicitud.hora!,
                    style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant)),
              ],
              if (solicitud.telefono != null &&
                  solicitud.telefono!.isNotEmpty) ...[
                const SizedBox(width: 12),
                const Icon(Icons.phone_outlined,
                    size: 13, color: AppColors.outline),
                const SizedBox(width: 4),
                Text(solicitud.telefono!,
                    style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant)),
              ],
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusRejected,
                        side: const BorderSide(
                            color: AppColors.statusRejected),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.close, size: 14),
                      label: Text('Rechazar',
                          style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusApproved,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.check, size: 14),
                      label: Text('Aprobar',
                          style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
