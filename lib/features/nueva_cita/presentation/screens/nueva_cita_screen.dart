import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/requests_repository.dart';
import '../widgets/service_grid.dart';
import '../widgets/date_strip.dart';
import '../widgets/time_slots.dart';

class NuevaCitaScreen extends ConsumerStatefulWidget {
  const NuevaCitaScreen({super.key});

  @override
  ConsumerState<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends ConsumerState<NuevaCitaScreen> {
  String? _selectedServiceId;
  String? _selectedServiceLabel;
  String? _selectedServiceIcon;
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  String? _selectedFecha;
  String? _selectedHora;
  final _descripcionController = TextEditingController();
  final Map<String, bool> _errors = {};
  bool _success = false;
  bool _loading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  bool _validate() {
    final e = <String, bool>{};
    if (_selectedServiceId == null) e['servicio'] = true;
    if (_nombreController.text.trim().isEmpty) e['nombre'] = true;
    if (_selectedFecha == null) e['fecha'] = true;
    if (_descripcionController.text.trim().isEmpty) e['descripcion'] = true;
    setState(() => _errors.addAll(e));
    return e.isEmpty;
  }

  Future<void> _submit() async {
    setState(() => _errors.clear());
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(requestsRepositoryProvider).createRequest(
            servicio: _selectedServiceLabel!,
            servicioIcon: _selectedServiceIcon!,
            nombreCliente: _nombreController.text.trim(),
            fecha: _selectedFecha!,
            hora: _selectedHora,
            descripcion: _descripcionController.text.trim(),
            telefono: _telefonoController.text.trim().isEmpty
                ? null
                : _telefonoController.text.trim(),
          );
      setState(() => _success = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _success = false;
          _loading = false;
          _selectedServiceId = null;
          _selectedServiceLabel = null;
          _selectedServiceIcon = null;
          _nombreController.clear();
          _telefonoController.clear();
          _selectedFecha = null;
          _selectedHora = null;
          _descripcionController.clear();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccess();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service type grid
          _sectionLabel('Tipo de Servicio',
              hasError: _errors['servicio'] == true),
          const SizedBox(height: 10),
          ServiceGrid(
            selectedId: _selectedServiceId,
            onSelected: (id, label, icon) => setState(() {
              _selectedServiceId = id;
              _selectedServiceLabel = label;
              _selectedServiceIcon = icon;
              _errors.remove('servicio');
            }),
          ),
          const SizedBox(height: 28),
          // Client name
          _sectionLabel('Nombre del cliente',
              hasError: _errors['nombre'] == true),
          const SizedBox(height: 8),
          _textInput(
            controller: _nombreController,
            hint: 'Nombre completo',
            hasError: _errors['nombre'] == true,
            onChanged: (_) => setState(() => _errors.remove('nombre')),
          ),
          const SizedBox(height: 20),
          // Phone (optional)
          _sectionLabel('Teléfono de contacto'),
          const SizedBox(height: 8),
          _textInput(
            controller: _telefonoController,
            hint: 'Número de teléfono (opcional)',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          // Date
          _sectionLabel('Fecha deseada',
              hasError: _errors['fecha'] == true),
          const SizedBox(height: 10),
          DateStrip(
            selectedDate: _selectedFecha,
            onSelected: (date) => setState(() {
              _selectedFecha = date;
              _errors.remove('fecha');
            }),
          ),
          const SizedBox(height: 14),
          TimeSlots(
            selectedTime: _selectedHora,
            onSelected: (t) => setState(() => _selectedHora = t),
          ),
          const SizedBox(height: 20),
          // Description
          _sectionLabel('Descripción del problema',
              hasError: _errors['descripcion'] == true),
          const SizedBox(height: 8),
          _textArea(
            controller: _descripcionController,
            hint: 'Describe brevemente el problema o requerimiento...',
            hasError: _errors['descripcion'] == true,
            onChanged: (_) =>
                setState(() => _errors.remove('descripcion')),
          ),
          const SizedBox(height: 28),
          // Submit button
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
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D004BCA),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: TextButton.icon(
                onPressed: _loading ? null : _submit,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, size: 18),
                label: Text('Enviar Solicitud',
                    style: GoogleFonts.manrope(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle,
                size: 48, color: AppColors.statusApproved),
          ),
          const SizedBox(height: 16),
          Text('¡Solicitud Enviada!',
              style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface)),
          const SizedBox(height: 8),
          Text('Tu cita ha sido registrada exitosamente.',
              style: GoogleFonts.manrope(
                  fontSize: 14, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {bool hasError = false}) {
    return Row(
      children: [
        Text(text,
            style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant)),
        if (hasError) ...[
          const SizedBox(width: 4),
          Text('*',
              style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error)),
        ],
      ],
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    required String hint,
    bool hasError = false,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: hasError ? Border.all(color: AppColors.error, width: 2) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: GoogleFonts.manrope(fontSize: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle:
              GoogleFonts.manrope(fontSize: 14, color: AppColors.outline),
        ),
      ),
    );
  }

  Widget _textArea({
    required TextEditingController controller,
    required String hint,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: hasError ? Border.all(color: AppColors.error, width: 2) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 3,
        style: GoogleFonts.manrope(fontSize: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle:
              GoogleFonts.manrope(fontSize: 14, color: AppColors.outline),
        ),
      ),
    );
  }
}
