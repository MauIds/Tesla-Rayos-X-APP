import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../nueva_cita/domain/request_model.dart';
import '../../../nueva_cita/data/requests_repository.dart';

void showSolicitudDetail(
    BuildContext context, WidgetRef ref, RequestModel solicitud) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SolicitudDetailSheet(solicitud: solicitud, ref: ref),
  );
}

class _SolicitudDetailSheet extends StatelessWidget {
  final RequestModel solicitud;
  final WidgetRef ref;

  const _SolicitudDetailSheet(
      {required this.solicitud, required this.ref});

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

  static String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat("d 'de' MMMM 'de' y", 'es').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar solicitud',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: Text(
            '¿Estás seguro de que quieres eliminar esta solicitud? Esta acción no se puede deshacer.',
            style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.manrope(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: GoogleFonts.manrope(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref
          .read(requestsRepositoryProvider)
          .deleteRequest(solicitud.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(solicitud.estado);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                            _serviceIcon(solicitud.servicioIcon),
                            size: 28,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(solicitud.servicio,
                                style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(solicitud.estado,
                                  style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _row(Icons.person_outline, 'Cliente',
                      solicitud.nombreCliente),
                  _row(Icons.calendar_today,
                      'Fecha', _formatFecha(solicitud.fecha)),
                  if (solicitud.hora != null)
                    _row(Icons.schedule, 'Horario', solicitud.hora!),
                  if (solicitud.telefono != null &&
                      solicitud.telefono!.isNotEmpty)
                    _row(Icons.phone_outlined, 'Teléfono',
                        solicitud.telefono!),
                  if (solicitud.descripcion != null &&
                      solicitud.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Descripción',
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(solicitud.descripcion!,
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: AppColors.onSurface,
                            height: 1.6)),
                  ],
                  const SizedBox(height: 32),
                  // Eliminar button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _delete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text('Eliminar solicitud',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.outline,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Cerrar',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600)),
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

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.outline),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColors.outline,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}
