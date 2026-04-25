import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/solicitudes_repository.dart';
import '../widgets/solicitud_card.dart';

class MisSolicitudesScreen extends ConsumerWidget {
  const MisSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(solicitudesStreamProvider);

    return stream.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (solicitudes) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                '${solicitudes.length} solicitud${solicitudes.length != 1 ? 'es' : ''} registrada${solicitudes.length != 1 ? 's' : ''}',
                style: GoogleFonts.manrope(
                    fontSize: 13, color: AppColors.outline),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: solicitudes.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(solicitudesStreamProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: solicitudes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            SolicitudCard(solicitud: solicitudes[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surfaceLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox,
                size: 36, color: AppColors.outlineVariant),
          ),
          const SizedBox(height: 12),
          Text('No hay solicitudes aún',
              style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline)),
          const SizedBox(height: 6),
          Text('Crea una nueva cita desde\nla pestaña "Nueva Cita"',
              style: GoogleFonts.manrope(
                  fontSize: 13, color: AppColors.outlineVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
