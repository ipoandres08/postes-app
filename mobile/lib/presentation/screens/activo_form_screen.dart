import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/activo_request.dart';
import '../providers/activo_provider.dart';

class ActivoFormScreen extends ConsumerStatefulWidget {
  const ActivoFormScreen({super.key});

  @override
  ConsumerState<ActivoFormScreen> createState() => _ActivoFormScreenState();
}

class _ActivoFormScreenState extends ConsumerState<ActivoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  
  String _tipoSeleccionado = 'Poste';
  double? _latitudActual;
  double? _longitudActual;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion(); // Captura GPS en caliente al abrir
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Servicios de ubicación deshabilitados.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permiso denegado.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudActual = position.latitude;
        _longitudActual = position.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la ubicación GPS.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _latitudActual != null) {
      // Nota: El 'creadoPorId' debería venir del JWT decodificado o del estado de Auth.
      // Usaremos 1 temporalmente asumiendo que el admin/tecnico principal tiene ese ID en la BD.
      final request = CreateActivoRequest(
        tipoActivo: _tipoSeleccionado,
        titulo: _tituloController.text.trim(),
        descripcionUbicacion: _descripcionController.text.trim(),
        direccionAnalitica: _direccionController.text.trim(),
        latitud: _latitudActual!,
        longitud: _longitudActual!,
        creadoPorId: 1, 
      );

      ref.read(activoFormProvider.notifier).crearActivo(request);
    } else if (_latitudActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esperando coordenadas GPS...'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(activoFormProvider);

    ref.listen<ActivoFormState>(activoFormProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activo creado con éxito'), backgroundColor: Color(0xFF00C389)),
        );
        ref.invalidate(activosListProvider);
        Navigator.of(context).pop(); // Volver al mapa
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Registrar Activo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Fondo decorativo
          Positioned(top: -50, right: -50, child: _buildGlow(const Color(0xFF00875A))),
          Positioned(bottom: -50, left: -50, child: _buildGlow(const Color(0xFF00C389))),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta de Coordenadas GPS
                    _buildGpsCard(),
                    const SizedBox(height: 24),

                    // Selector de Tipo de Activo
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Poste', label: Text('Poste'), icon: Icon(Icons.electric_bolt)),
                        ButtonSegment(value: 'Medidor', label: Text('Medidor'), icon: Icon(Icons.speed)),
                      ],
                      selected: {_tipoSeleccionado},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() => _tipoSeleccionado = newSelection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        foregroundColor: const Color(0xFFBDCAC0),
                        selectedForegroundColor: Colors.white,
                        selectedBackgroundColor: const Color(0xFF00875A),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campos de texto
                    _buildTextField(_tituloController, 'Título (Ej. Poste H-104)', Icons.title),
                    const SizedBox(height: 16),
                    _buildTextField(_direccionController, 'Dirección Analítica', Icons.map),
                    const SizedBox(height: 16),
                    _buildTextField(_descripcionController, 'Descripción de Ubicación', Icons.description, maxLines: 3),
                    const SizedBox(height: 32),

                    // Botón de Guardado
                    ElevatedButton(
                      onPressed: formState.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C389),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: formState.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Registrar en Sistema', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171F33).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00875A).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: _isLocating 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF71DBA6)))
                  : const Icon(Icons.gps_fixed, color: Color(0xFF71DBA6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ubicación Actual', style: TextStyle(color: Color(0xFFBDCAC0), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      _latitudActual != null 
                        ? '${_latitudActual!.toStringAsFixed(5)}, ${_longitudActual!.toStringAsFixed(5)}' 
                        : 'Calculando coordenadas...',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white54),
                onPressed: _obtenerUbicacion,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: const Color(0xFFBDCAC0)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00875A))),
      ),
      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 200, height: 200,
      decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
    ).blurred(100);
  }
}

// Reutilizamos la extensión blur del login
extension BlurExtension on Widget {
  Widget blurred(double sigma) => ImageFilterWidget(sigmaX: sigma, sigmaY: sigma, child: this);
}
class ImageFilterWidget extends StatelessWidget {
  final double sigmaX, sigmaY; final Widget child;
  const ImageFilterWidget({super.key, required this.sigmaX, required this.sigmaY, required this.child});
  @override
  Widget build(BuildContext context) => ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY), child: child));
}