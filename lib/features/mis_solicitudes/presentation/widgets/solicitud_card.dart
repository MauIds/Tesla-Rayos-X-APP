import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../nueva_cita/domain/request_model.dart';
import '../../../nueva_cita/data/requests_repository.dart';
import 'solicitud_detail_sheet.dart';

class SolicitudCard extends ConsumerWidget {
  final RequestModel solicitud;

  const SolicitudCard({super.key, required this.solicitud});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(solicitud.estado);

    return Dismissible(
      key: Key(solicitud.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Eliminar solicitud',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
            content: Text(
                '¿Estás seguro de que quieres eliminar esta solicitud?',
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
      },
      onDismissed: (_) async {
        await ref
            .read(requestsRepositoryProvider)
            .deleteRequest(solicitud.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child:
            const Icon(Icons.delete_outline, color: AppColors.error, size: 28),
      ),
      child: GestureDetector(
        onTap: () => showSolicitudDetail(context, ref, solicitud),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_serviceIcon(solicitud.servicioIcon),
                        size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(solicitud.servicio,
                            style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface)),
                        const SizedBox(height: 2),
                        Text(solicitud.nombreCliente,
                            style: GoogleFonts.manrope(
                                fontSize: 12, color: AppColors.outline)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: AppColors.outline),
                  const SizedBox(width: 4),
                  Text(_formatFecha(solicitud.fecha),
                      style: GoogleFonts.manrope(
                          fontSize: 12, color: AppColors.onSurfaceVariant)),
                  if (solicitud.hora != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(solicitud.hora!,
                        style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant)),
                  ],
                ],
              ),
              if (solicitud.descripcion != null &&
                  solicitud.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    solicitud.descripcion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
