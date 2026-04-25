import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class TimeSlots extends StatelessWidget {
  final String? selectedTime;
  final ValueChanged<String> onSelected;

  const TimeSlots({
    super.key,
    required this.selectedTime,
    required this.onSelected,
  });

  static const _slots = ['09:00 AM', '10:30 AM', '01:00 PM', '03:30 PM'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HORARIOS DISPONIBLES',
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3.2,
          children: _slots.map((t) {
            final active = selectedTime == t;
            return GestureDetector(
              onTap: () => onSelected(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: active
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Text(
                  t,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
