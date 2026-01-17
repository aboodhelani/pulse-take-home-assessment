import 'package:flutter/foundation.dart';
import 'package:pulsenow_flutter/enms/sort_type.dart';
import 'package:pulsenow_flutter/services/websocket_service.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../models/market_data_model.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MarketData> _marketData = [];
  List<MarketData> _filteredMarketData = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  SortType _sortType = SortType.none;
  bool _sortAscending = true;
  bool _isFromCache = false;
  DateTime? _cacheTimestamp;

  List<MarketData> get marketData => _filteredMarketData;
  List<MarketData> get allMarketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  SortType get sortType => _sortType;
  bool get sortAscending => _sortAscending;
  bool get isFromCache => _isFromCache;
  DateTime? get cacheTimestamp => _cacheTimestamp;

  final WebSocketService _webSocketService = WebSocketService();

  /// Initialize provider and load cached data
  Future<void> initialize() async {
    // Load cached data first for instant display
    final cachedData = await CacheService.loadMarketData();
    if (cachedData != null && cachedData.isNotEmpty) {
      _marketData = cachedData;
      _cacheTimestamp = await CacheService.getCacheTimestamp();
      _isFromCache = true;
      _applyFiltersAndSort();
      notifyListeners();
    }
  }

  Future<void> loadMarketData({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    _isFromCache = false;
    _webSocketService.disconnect();
    notifyListeners();

    try {
      _marketData = await _apiService.getMarketData();
      // Save to cache after successful API call
      await CacheService.saveMarketData(_marketData);
      _cacheTimestamp = await CacheService.getCacheTimestamp();
      _applyFiltersAndSort();
      _isLoading = false;
      notifyListeners();

      _webSocketService.connect();
      _webSocketService.stream?.listen((marketData) {
        final index = _marketData.indexWhere((data) => data.symbol == marketData.symbol);
        if (index != -1) {
          _marketData[index] = marketData;
          // Save updated data to cache when WebSocket updates
          CacheService.saveMarketData(_marketData);
        }
        _applyFiltersAndSort();
        notifyListeners();
      });
    } catch (e) {
      // If API call fails, try to load from cache if not already loaded
      if (_marketData.isEmpty) {
        final cachedData = await CacheService.loadMarketData();
        if (cachedData != null && cachedData.isNotEmpty) {
          _marketData = cachedData;
          _cacheTimestamp = await CacheService.getCacheTimestamp();
          _isFromCache = true;
          _applyFiltersAndSort();
        } else {
          _error = e.toString();
        }
      } else {
        // We have cached data, mark it as such
        _isFromCache = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortType(SortType sortType) {
    // If clicking the same sort type, toggle ascending/descending
    if (_sortType == sortType) {
      _sortAscending = !_sortAscending;
    } else {
      _sortType = sortType;
      _sortAscending = true;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _sortType = SortType.none;
    _sortAscending = true;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    // Apply search filter
    _filteredMarketData = _marketData.where((data) {
      if (_searchQuery.isEmpty) return true;
      final symbol = (data.symbol ?? '').toLowerCase();
      return symbol.contains(_searchQuery.toLowerCase());
    }).toList();

    // Apply sorting
    if (_sortType != SortType.none) {
      _filteredMarketData.sort((a, b) {
        int comparison = 0;
        switch (_sortType) {
          case SortType.symbol:
            final symbolA = (a.symbol ?? '').toLowerCase();
            final symbolB = (b.symbol ?? '').toLowerCase();
            comparison = symbolA.compareTo(symbolB);
            break;
          case SortType.price:
            final priceA = a.price ?? 0;
            final priceB = b.price ?? 0;
            comparison = priceA.compareTo(priceB);
            break;
          case SortType.change:
            final changeA = a.change24h ?? 0;
            final changeB = b.change24h ?? 0;
            comparison = changeA.compareTo(changeB);
            break;
          case SortType.none:
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }
  }
}
