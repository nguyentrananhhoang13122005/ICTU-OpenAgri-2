import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/crop_field.dart';
import '../widgets/app_navigation_bar.dart';

class FieldMapScreen extends StatefulWidget {
  const FieldMapScreen({super.key});

  @override
  State<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends State<FieldMapScreen> {
  final MapController _mapController = MapController();
  List<CropField> fields = [];
  CropField? selectedField;
  List<LatLng> newFieldPoints = [];
  bool isDrawingMode = false;

  @override
  void initState() {
    super.initState();
    fields = CropField.getMockFields();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: const AppNavigationBar(currentIndex: 1),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFieldDialog,
        backgroundColor: const Color(0xFF0BDA50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm Vùng Trồng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý Vùng trồng',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111813),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${fields.length} vùng đang quản lý',
            style: const TextStyle(fontSize: 16, color: Color(0xFF608a6e)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                // LEFT LIST
                SizedBox(width: 340, child: _buildFieldList()),
                const SizedBox(width: 24),
                // RIGHT MAP
                Expanded(child: _buildMapSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // MAP SECTION
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: _buildMapSection(),
        ),
        // FIELD LIST
        Expanded(child: _buildFieldList()),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(10.033333, 105.783333),
                initialZoom: 14.0,
                onTap: (_, __) => setState(() => selectedField = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.agritech.app',
                ),
                PolygonLayer(
                  polygons: fields.map((field) {
                    final isSelected = selectedField?.id == field.id;
                    return Polygon(
                      points: field.polygonPoints,
                      color: _getCropColor(
                        field.cropType,
                      ).withValues(alpha: 0.4),
                      borderColor: isSelected
                          ? Colors.white
                          : _getCropColor(field.cropType),
                      borderStrokeWidth: isSelected ? 3 : 2,
                    );
                  }).toList(),
                ),
                MarkerLayer(
                  markers: fields.map((field) {
                    return Marker(
                      point: field.center,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedField = field);
                          _mapController.move(field.center, 16);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getCropColor(field.cropType),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCropIcon(field.cropType),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  _buildMapButton(Icons.add, () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildMapButton(Icons.remove, () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildFieldList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danh sách Vùng trồng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${fields.length} vùng đang quản lý',
                  style: const TextStyle(color: Color(0xFF608a6e)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: fields.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final field = fields[index];
                final isSelected = selectedField?.id == field.id;
                return InkWell(
                  onTap: () {
                    setState(() => selectedField = field);
                    _mapController.move(field.center, 16);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF0FDF4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0BDA50)
                            : const Color(0xFFE5E7EB),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getCropColor(
                              field.cropType,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCropIcon(field.cropType),
                            color: _getCropColor(field.cropType),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${field.area} ha • ${field.cropType}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF0BDA50),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFieldDialog() {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    String cropType = 'Lúa';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Vùng Trồng Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên vùng trồng *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.terrain),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: cropType,
                decoration: const InputDecoration(
                  labelText: 'Loại cây trồng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.agriculture),
                ),
                items: const [
                  DropdownMenuItem(value: 'Lúa', child: Text('Lúa')),
                  DropdownMenuItem(
                    value: 'Cây ăn trái',
                    child: Text('Cây ăn trái'),
                  ),
                  DropdownMenuItem(value: 'Rau màu', child: Text('Rau màu')),
                ],
                onChanged: (v) => cropType = v ?? 'Lúa',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: 'Diện tích (ha)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.square_foot),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên vùng trồng!'),
                  ),
                );
                return;
              }

              // Create new field with random location near existing fields
              final newField = CropField(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                cropType: cropType,
                area: double.tryParse(areaController.text) ?? 1.0,
                ndviValue: 0.5,
                trendDirection: 'stable',
                lastUpdated: DateTime.now(),
                ndviHistory: NDVIDataPoint.getMockData(),
                imageUrl: '',
                center: LatLng(
                  10.033333 + (fields.length * 0.001),
                  105.783333 + (fields.length * 0.001),
                ),
                polygonPoints: [
                  LatLng(
                    10.033333 + (fields.length * 0.001),
                    105.783333 + (fields.length * 0.001),
                  ),
                  LatLng(
                    10.034333 + (fields.length * 0.001),
                    105.783333 + (fields.length * 0.001),
                  ),
                  LatLng(
                    10.034333 + (fields.length * 0.001),
                    105.784333 + (fields.length * 0.001),
                  ),
                  LatLng(
                    10.033333 + (fields.length * 0.001),
                    105.784333 + (fields.length * 0.001),
                  ),
                ],
              );

              setState(() {
                fields.add(newField);
                selectedField = newField;
              });

              _mapController.move(newField.center, 16);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã thêm vùng trồng mới!'),
                  backgroundColor: Color(0xFF0BDA50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0BDA50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Color _getCropColor(String type) {
    if (type == 'Lúa') return const Color(0xFF10B981);
    if (type == 'Cây ăn trái') return const Color(0xFFF59E0B);
    return const Color(0xFF8B5CF6);
  }

  IconData _getCropIcon(String type) {
    if (type == 'Lúa') return Icons.grass;
    if (type == 'Cây ăn trái') return Icons.agriculture;
    return Icons.spa;
  }
}
