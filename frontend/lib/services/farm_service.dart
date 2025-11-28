import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class FarmService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<List<FarmAreaResponseDTO>> getMyFarms() async {
    try {
      final token = await _authService.getToken();
      final response = await _apiService.client.get(
        '/farms/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return (response.data as List)
          .map((e) => FarmAreaResponseDTO.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load farms: $e');
    }
  }

  Future<FarmAreaResponseDTO> createFarm(FarmAreaCreateDTO farmData) async {
    try {
      final token = await _authService.getToken();
      final response = await _apiService.client.post(
        '/farms/',
        data: farmData.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return FarmAreaResponseDTO.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create farm: $e');
    }
  }
}
