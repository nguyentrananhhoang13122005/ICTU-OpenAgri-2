import 'package:flutter/material.dart';
import '../models/admin_user.dart';
import '../models/api_models.dart';
import '../services/admin_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  // State
  List<AdminUser> _users = [];
  AdminUserStats? _stats;
  bool _isLoading = false;
  bool _isLoadingStats = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalPages = 0;
  int _total = 0;

  // Search
  String _searchQuery = '';

  // Getters
  List<AdminUser> get users => _users;
  AdminUserStats? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingStats => _isLoadingStats;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _totalPages;
  int get total => _total;
  String get searchQuery => _searchQuery;

  /// Load users with pagination and search
  Future<void> loadUsers({int? page, String? search}) async {
    _isLoading = true;
    _errorMessage = null;

    if (page != null) {
      _currentPage = page;
    }

    if (search != null) {
      _searchQuery = search;
      _currentPage = 1; // Reset to first page on new search
    }

    notifyListeners();

    try {
      final response = await _adminService.getUsers(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      _users = response.users;
      _total = response.total;
      _totalPages = response.totalPages;
      _currentPage = response.page;
      _pageSize = response.pageSize;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách người dùng: ${e.toString()}';
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user statistics
  Future<void> loadStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _stats = await _adminService.getUserStats();
    } catch (e) {
      _errorMessage = 'Không thể tải thống kê: ${e.toString()}';
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      await _adminService.deleteUser(userId);

      // Reload users after deletion
      await loadUsers();
      await loadStats(); // Update stats

      return true;
    } catch (e) {
      _errorMessage = 'Không thể xóa người dùng: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update user status
  Future<bool> updateUserStatus(int userId, bool isActive) async {
    try {
      await _adminService.updateUserStatus(userId, isActive);

      // Reload users after status update
      await loadUsers();
      await loadStats(); // Update stats

      return true;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật trạng thái: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Go to next page
  void nextPage() {
    if (_currentPage < _totalPages) {
      loadUsers(page: _currentPage + 1);
    }
  }

  /// Go to previous page
  void previousPage() {
    if (_currentPage > 1) {
      loadUsers(page: _currentPage - 1);
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      loadUsers(page: page);
    }
  }

  /// Search users
  void searchUsers(String query) {
    loadUsers(search: query);
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    loadUsers(search: '');
  }

  /// Refresh data
  Future<void> refresh() async {
    await Future.wait([
      loadUsers(),
      loadStats(),
      loadFarms(refresh: true),
      loadCropStats(),
      loadFarmLocations(),
    ]);
  }

  // --- Farms Logic ---
  List<AdminFarmAreaResponseDTO> _farms = [];
  bool _isLoadingFarms = false;
  int _farmsPage = 1;
  bool _hasMoreFarms = true;

  // Stats & Map
  List<CropDistributionDTO> _cropStats = [];
  List<FarmLocationDTO> _farmLocations = [];
  bool _isLoadingCropStats = false;
  bool _isLoadingFarmLocations = false;

  List<AdminFarmAreaResponseDTO> get farms => _farms;
  bool get isLoadingFarms => _isLoadingFarms;
  bool get hasMoreFarms => _hasMoreFarms;
  List<CropDistributionDTO> get cropStats => _cropStats;
  List<FarmLocationDTO> get farmLocations => _farmLocations;
  bool get isLoadingCropStats => _isLoadingCropStats;
  bool get isLoadingFarmLocations => _isLoadingFarmLocations;

  Future<void> loadFarms({bool refresh = false}) async {
    if (refresh) {
      _farmsPage = 1;
      _farms = [];
      _hasMoreFarms = true;
    }

    if (!_hasMoreFarms) return;

    _isLoadingFarms = true;
    notifyListeners();

    try {
      final newFarms = await _adminService.getAllFarms(
        page: _farmsPage,
        pageSize: 10,
      );

      if (newFarms.isEmpty) {
        _hasMoreFarms = false;
      } else {
        _farms.addAll(newFarms);
        _farmsPage++;
      }
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách vùng trồng: ${e.toString()}';
    } finally {
      _isLoadingFarms = false;
      notifyListeners();
    }
  }

  Future<void> loadCropStats() async {
    _isLoadingCropStats = true;
    notifyListeners();
    try {
      _cropStats = await _adminService.getCropDistribution();
    } catch (e) {
      debugPrint('Error loading crop stats: $e');
    } finally {
      _isLoadingCropStats = false;
      notifyListeners();
    }
  }

  Future<void> loadFarmLocations() async {
    _isLoadingFarmLocations = true;
    notifyListeners();
    try {
      _farmLocations = await _adminService.getFarmLocations();
    } catch (e) {
      debugPrint('Error loading farm locations: $e');
    } finally {
      _isLoadingFarmLocations = false;
      notifyListeners();
    }
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _adminService.setAuthToken(token);
  }
}
