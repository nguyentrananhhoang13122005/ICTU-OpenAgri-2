import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/api_models.dart';

class FarmMapWidget extends StatefulWidget {
  final List<FarmLocationDTO> locations;

  const FarmMapWidget({super.key, required this.locations});

  @override
  State<FarmMapWidget> createState() => _FarmMapWidgetState();
}

class _FarmMapWidgetState extends State<FarmMapWidget> {
  final MapController _mapController = MapController();
  int _currentIndex = -1; // -1 means no specific farm selected

  void _focusFarm(int index) {
    if (widget.locations.isEmpty) return;
    setState(() {
      _currentIndex = index;
    });
    final farm = widget.locations[index];
    if (farm.coordinates.isNotEmpty) {
      _mapController.move(farm.coordinates.first, 16.0); // Zoom in to farm
    }
  }

  void _nextFarm() {
    if (widget.locations.isEmpty) return;
    final nextIndex = (_currentIndex + 1) % widget.locations.length;
    _focusFarm(nextIndex);
  }

  void _prevFarm() {
    if (widget.locations.isEmpty) return;
    final prevIndex =
        (_currentIndex - 1 + widget.locations.length) % widget.locations.length;
    _focusFarm(prevIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(10.020905, 105.776513), // Can Tho default
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              // Esri World Imagery (Satellite)
              urlTemplate:
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.ictu.openagri',
            ),
            PolygonLayer(
              polygons: widget.locations.asMap().entries.map((entry) {
                final index = entry.key;
                final farm = entry.value;
                final isSelected = index == _currentIndex;

                return Polygon(
                  points: farm.coordinates,
                  color: isSelected
                      ? const Color(0xFF0BDA50).withValues(alpha: 0.4)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  borderColor: isSelected
                      ? const Color(0xFF0BDA50)
                      : const Color(0xFF3B82F6),
                  borderStrokeWidth: isSelected ? 3 : 2,
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: widget.locations.asMap().entries.expand((entry) {
                final index = entry.key;
                final farm = entry.value;
                if (farm.coordinates.isEmpty) return <Marker>[];

                final isSelected = index == _currentIndex;

                return [
                  Marker(
                    point: farm.coordinates.first,
                    width: isSelected ? 50 : 30,
                    height: isSelected ? 50 : 30,
                    child: GestureDetector(
                      onTap: () => _focusFarm(index),
                      child: Icon(
                        Icons.location_on,
                        color: isSelected
                            ? Colors.yellow
                            : const Color(0xFFEF4444),
                        size: isSelected ? 50 : 30,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              }).toList(),
            ),
          ],
        ),
        // Controls Overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.locations.isNotEmpty ? _prevFarm : null,
                  icon: const Icon(Icons.arrow_back_ios),
                  tooltip: 'Vùng trồng trước',
                  color: const Color(0xFF111813),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentIndex >= 0
                            ? widget.locations[_currentIndex].name
                            : 'Chọn vùng trồng',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF111813),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_currentIndex >= 0 &&
                          widget.locations[_currentIndex].cropType != null)
                        Text(
                          widget.locations[_currentIndex].cropType!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF608a6e),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.locations.isNotEmpty ? _nextFarm : null,
                  icon: const Icon(Icons.arrow_forward_ios),
                  tooltip: 'Vùng trồng tiếp theo',
                  color: const Color(0xFF111813),
                ),
              ],
            ),
          ),
        ),
        // Title Overlay
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.satellite_alt, size: 16, color: Color(0xFF608a6e)),
                SizedBox(width: 8),
                Text(
                  'Bản Đồ Vệ Tinh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF111813),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
