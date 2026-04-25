import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class _Service {
  final String id;
  final String label;
  final IconData icon;
  final String iconName;

  const _Service(this.id, this.label, this.icon, this.iconName);
}

const _services = [
  _Service('reparacion', 'Reparación', Icons.construction, 'construction'),
  _Service('biologico', 'Control Biológico', Icons.biotech, 'biotech'),
  _Service('mantenimiento', 'Mantenimiento', Icons.build, 'build'),
  _Service('cotizacion', 'Cotización General', Icons.request_quote, 'request_quote'),
];

class ServiceGrid extends StatelessWidget {
  final String? selectedId;
  final void Function(String id, String label, String iconName) onSelected;

  const ServiceGrid({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: _services.map((s) {
        final active = selectedId == s.id;
        return GestureDetector(
          onTap: () => onSelected(s.id, s.label, s.iconName),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: active ? 20 : 3,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    s.icon,
                    size: 22,
                    color: active ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.label,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
