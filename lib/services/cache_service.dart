import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/market_data_model.dart';

class CacheService {
  static const String _boxName = 'market_data_cache';
  static const String _dataKey = 'market_data';
  static const String _timestampKey = 'timestamp';
  static const Duration _cacheExpiration = Duration(hours: 24);

  static Box? _box;
  static bool _initialized = false;

  /// Initialize Hive box for cache
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox(_boxName);
      } else {
        _box = Hive.box(_boxName);
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing cache service: $e');
      _initialized = false;
    }
  }

  /// Save market data to cache
  static Future<void> saveMarketData(List<MarketData> marketData) async {
    if (!_initialized || _box == null) {
      await initialize();
    }

    if (_box == null) return;

    try {
      final jsonList = marketData.map((data) => data.toJson()).toList();
      await _box!.put(_dataKey, jsonEncode(jsonList));
      await _box!.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving market data to cache: $e');
    }
  }

  /// Load market data from cache
  static Future<List<MarketData>?> loadMarketData() async {
    if (!_initialized || _box == null) {
      await initialize();
    }

    if (_box == null) return null;

    try {
      final cachedJson = _box!.get(_dataKey) as String?;

      if (cachedJson == null) return null;

      final jsonList = jsonDecode(cachedJson) as List;
      return MarketData.fromJsonList(jsonList);
    } catch (e) {
      debugPrint('Error loading market data from cache: $e');
      return null;
    }
  }

  /// Get cache timestamp
  static Future<DateTime?> getCacheTimestamp() async {
    if (!_initialized || _box == null) {
      await initialize();
    }

    if (_box == null) return null;

    try {
      final timestamp = _box!.get(_timestampKey) as int?;

      if (timestamp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('Error getting cache timestamp: $e');
      return null;
    }
  }

  /// Check if cache exists and is valid (not expired)
  static Future<bool> hasValidCache() async {
    if (!_initialized || _box == null) {
      await initialize();
    }

    if (_box == null) return false;

    try {
      final timestamp = _box!.get(_timestampKey) as int?;

      if (timestamp == null) return false;

      final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      return now.difference(cacheDate) < _cacheExpiration;
    } catch (e) {
      return false;
    }
  }

  /// Check if cache is expired
  static Future<bool> isCacheExpired() async {
    if (!_initialized || _box == null) {
      await initialize();
    }

    if (_box == null) return true;

    try {
      final timestamp = _box!.get(_timestampKey) as int?;

      if (timestamp == null) return true;

      final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      return now.difference(cacheDate) >= _cacheExpiration;
    } catch (e) {
      return true;
    }
  }

  /// Clear cache
  static Future<void> clearCache() async {
    if (!_initialized || _box == null) {
      await initialize();
    }

    if (_box == null) return;

    try {
      await _box!.delete(_dataKey);
      await _box!.delete(_timestampKey);
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
