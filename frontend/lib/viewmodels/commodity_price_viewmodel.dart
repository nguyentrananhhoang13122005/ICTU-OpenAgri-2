import 'package:flutter/foundation.dart';
import '../models/commodity_price.dart';
import '../services/commodity_price_service.dart';

class CommodityPriceViewModel extends ChangeNotifier {
  final CommodityPriceService _service = CommodityPriceService();

  List<CommodityPrice> _commodities = [];
  CommodityPriceDetail? _selectedCommodity;
  bool _isLoading = false;
  String? _error;
  List<String> _categories = [];
  String? _selectedCategory;

  List<CommodityPrice> get commodities => _commodities;
  CommodityPriceDetail? get selectedCommodity => _selectedCommodity;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;

  Future<void> loadCommodities({
    String? category,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data for testing UI without backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      _commodities = [
        CommodityPrice(
          id: '1',
          name: 'Lúa Gạo',
          nameEn: 'Rice',
          unit: 'kg',
          category: 'grains',
          currentPrice: 7500000,
          priceChangePercent24h: 2.5,
          minPrice: 7200000,
          maxPrice: 7800000,
          prices: [
            PricePoint(date: '2024-01-01', price: 7300000, market: 'Chợ An Giang'),
            PricePoint(date: '2024-01-02', price: 7500000, market: 'Chợ An Giang'),
          ],
        ),
        CommodityPrice(
          id: '2',
          name: 'Cà Phê Robusta',
          nameEn: 'Robusta Coffee',
          unit: 'kg',
          category: 'coffee',
          currentPrice: 95000,
          priceChangePercent24h: -1.2,
          minPrice: 92000,
          maxPrice: 98000,
          prices: [
            PricePoint(date: '2024-01-01', price: 96000, market: 'Chợ Đắk Lắk'),
            PricePoint(date: '2024-01-02', price: 95000, market: 'Chợ Đắk Lắk'),
          ],
        ),
        CommodityPrice(
          id: '3',
          name: 'Tiêu Đen',
          nameEn: 'Black Pepper',
          unit: 'kg',
          category: 'spices',
          currentPrice: 145000,
          priceChangePercent24h: 3.8,
          minPrice: 140000,
          maxPrice: 150000,
          prices: [
            PricePoint(date: '2024-01-01', price: 142000, market: 'Chợ Đồng Nai'),
            PricePoint(date: '2024-01-02', price: 145000, market: 'Chợ Đồng Nai'),
          ],
        ),
      ];
      _error = null;
    } catch (e) {
      _error = e.toString();
      _commodities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCommodityDetail(String commodityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data for testing UI without backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate 30 days of mock data
      final now = DateTime.now();
      final List<PricePoint> priceHistory = [];
      final List<ChartDataPoint> chartData = [];
      
      double currentPrice = 7000000; // Starting price
      
      // Use a simple pseudo-random generator based on time to get different results each reload
      int seed = DateTime.now().millisecondsSinceEpoch;
      double random() {
        seed = (seed * 1664525 + 1013904223) % 4294967296;
        return seed / 4294967296.0;
      }

      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        
        // Volatility logic:
        // 1. Random direction change (up or down)
        // 2. Large daily fluctuation (up to 5%)
        
        double changePercent = (random() * 0.10) - 0.05; // -5% to +5%
        
        // Add some momentum/trend that changes every few days
        if (i % 7 < 3) {
           changePercent += 0.02; // Up trend for 3 days
        } else if (i % 5 < 2) {
           changePercent -= 0.03; // Down trend for 2 days
        }

        if (i < 29) {
          currentPrice = currentPrice * (1 + changePercent);
        }

        // Ensure price doesn't go negative or too low
        if (currentPrice < 100000) currentPrice = 100000;

        priceHistory.add(PricePoint(
          date: dateStr,
          price: currentPrice,
          market: 'Chợ An Giang',
        ));

        chartData.add(ChartDataPoint(
          date: dateStr,
          price: currentPrice,
          open: currentPrice * (1 - (random() * 0.02)),
          high: currentPrice * (1 + (random() * 0.03)),
          low: currentPrice * (1 - (random() * 0.03)),
          close: currentPrice,
        ));
      }

      _selectedCommodity = CommodityPriceDetail(
        commodity: CommodityPrice(
          id: commodityId,
          name: 'Lúa Gạo',
          nameEn: 'Rice',
          unit: 'kg',
          category: 'grains',
          currentPrice: currentPrice,
          priceChangePercent24h: 2.5,
          minPrice: currentPrice * 0.95,
          maxPrice: currentPrice * 1.05,
          prices: priceHistory,
        ),
        priceHistory: priceHistory,
        chartData: chartData,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedCommodity = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      // Mock data for testing UI without backend
      await Future.delayed(const Duration(milliseconds: 300));
      
      _categories = ['grains', 'coffee', 'spices', 'vegetables', 'fruits'];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCommodity = null;
    notifyListeners();
  }
}

