import 'package:flutter/foundation.dart';
import 'package:pulsenow_flutter/enms/sort_type.dart';
import 'package:pulsenow_flutter/services/websocket_service.dart';
import '../services/api_service.dart';
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

  List<MarketData> get marketData => _filteredMarketData;
  List<MarketData> get allMarketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  SortType get sortType => _sortType;
  bool get sortAscending => _sortAscending;

  final WebSocketService _webSocketService = WebSocketService();

  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    _webSocketService.disconnect();
    notifyListeners();

    try {
      _marketData = await _apiService.getMarketData();
      _applyFiltersAndSort();
      _isLoading = false;
      notifyListeners();
      _webSocketService.connect();
      _webSocketService.stream?.listen((marketData) {
        final index = _marketData.indexWhere((data) => data.symbol == marketData.symbol);
        if (index != -1) {
          _marketData[index] = marketData;
        }
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
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
