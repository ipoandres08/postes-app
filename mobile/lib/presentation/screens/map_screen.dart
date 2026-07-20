import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/presentation/providers/activo_provider.dart';
import 'package:mobile/presentation/screens/activo_form_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int _currentIndex = 0; // 0: Map, 1: Assets, 2: Profile
  
  // Coordenadas de ejemplo (Centro del mapa)
  final LatLng _initialCenter = const LatLng(-17.3895, -66.1568);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1326), // surface-dim[cite: 3]
      extendBody: true, // Permite que el mapa fluya debajo de la barra de navegación
      
      body: Stack(
        children: [
          // 1. Capa Base: El Mapa Interactivo
          _buildMap(),

          // 2. Capa Superior: Top App Bar & Search[cite: 3]
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeaderAndSearch(),
          ),

          // 3. Capa Inferior: Bottom Sheet de Activos Cercanos[cite: 3]
          _buildDraggableBottomSheet(),
        ],
      ),
      
      // 4. Floating Action Button para agregar nuevos activos[cite: 3]
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // 5. Custom Bottom Navigation Bar[cite: 3]
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- COMPONENTES UI ---

  Widget _buildMap() {
    final activosAsyncValue = ref.watch(activosListProvider);

    return FlutterMap(
      options: MapOptions(
        initialCenter: _initialCenter,
        initialZoom: 15.0,
      ),
      children: [
        // Usamos un mapa base oscuro gratuito (CartoDB Dark Matter) para igualar el diseño
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'com.assethub.app',
        ),
        MarkerLayer(
          markers: [
            // Marcador de ejemplo: Poste
            Marker(
              point: const LatLng(-17.3880, -66.1550),
              width: 60,
              height: 60,
              child: _buildMapMarker(Icons.electric_bolt, const Color(0xFF00875A), 'PL-8821'), //[cite: 3]
            ),
            // Marcador de ejemplo: Medidor
            Marker(
              point: const LatLng(-17.3910, -66.1580),
              width: 60,
              height: 60,
              child: _buildMapMarker(Icons.speed, const Color(0xFF00C389), 'MT-1049'), //[cite: 3]
            ),
          ],
        ),
        activosAsyncValue.when(
          data: (activos) {
            return MarkerLayer(
              markers: activos.map((activo) {
                // Definir color e icono según el tipo
                final esPoste = activo.tipoActivo.toLowerCase() == 'poste';
                final color = esPoste ? const Color(0xFF00875A) : const Color(0xFF00C389);
                final icono = esPoste ? Icons.electric_bolt : Icons.speed;

                return Marker(
                  point: LatLng(activo.latitud, activo.longitud),
                  width: 60,
                  height: 60,
                  child: _buildMapMarker(icono, color, activo.titulo),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF71DBA6))),
          error: (error, stack) => const Center(child: Text('Error al cargar activos')),
        ),
      ],
    );
  }

  Widget _buildMapMarker(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF171F33).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _buildHeaderAndSearch() {
    return Column(
      children: [
        // Top App Bar
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 20, right: 20, bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1326).withOpacity(0.8),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF71DBA6)),
                      SizedBox(width: 8),
                      Text(
                        'AssetHub', //[cite: 3]
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF71DBA6)),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    backgroundImage: const NetworkImage('https://i.pravatar.cc/100'), // Avatar Placeholder
                  ),
                ],
              ),
            ),
          ),
        ),
        // Floating Search Bar[cite: 3]
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF171F33).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_searching, color: Color(0xFFBDCAC0)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar ID de activo o ubicación...', //[cite: 3]
                          hintStyle: TextStyle(color: const Color(0xFFBDCAC0).withOpacity(0.5)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00875A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90.0), // Elevar por encima del bottom nav
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ActivoFormScreen()),
          );
        },
        backgroundColor: const Color(0xFF00875A), //[cite: 3]
        elevation: 8,
        child: const Icon(Icons.add_location_alt, color: Colors.white, size: 28), //[cite: 3]
      ),
    );
  }

  Widget _buildDraggableBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.1, // Solo muestra la pestaña superior al inicio
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF222A3D).withOpacity(0.95), // surface-container-high[cite: 3]
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Título
                  const Text(
                    'Activos Cercanos', //[cite: 3]
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF71DBA6)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2 activos encontrados en tu área',
                    style: TextStyle(color: Color(0xFFBDCAC0), fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  
                  // Lista de activos de prueba[cite: 3]
                  _buildAssetListItem('Poste H-104', 'Estructural', Icons.foundation, const Color(0xFF00875A)),
                  const SizedBox(height: 12),
                  _buildAssetListItem('Medidor Principal', 'Monitoreo', Icons.speed, const Color(0xFF00C389)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssetListItem(String title, String type, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3449),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(type.toUpperCase(), style: const TextStyle(color: Color(0xFFBDCAC0), fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white30),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171F33).withOpacity(0.9),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF71DBA6),
            unselectedItemColor: const Color(0xFFBDCAC0),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'), //[cite: 3]
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Activos'), //[cite: 3]
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'), //[cite: 3]
            ],
          ),
        ),
      ),
    );
  }
}