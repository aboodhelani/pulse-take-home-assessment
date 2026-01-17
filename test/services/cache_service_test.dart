import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import 'package:pulsenow_flutter/services/cache_service.dart';
import 'dart:io';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationCachePath() {
    // TODO: implement getApplicationCachePath
    throw UnimplementedError();
  }

  @override
  Future<String?> getApplicationSupportPath() {
    // TODO: implement getApplicationSupportPath
    throw UnimplementedError();
  }

  @override
  Future<String?> getDownloadsPath() {
    // TODO: implement getDownloadsPath
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getExternalCachePaths() {
    // TODO: implement getExternalCachePaths
    throw UnimplementedError();
  }

  @override
  Future<String?> getExternalStoragePath() {
    // TODO: implement getExternalStoragePath
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) {
    // TODO: implement getExternalStoragePaths
    throw UnimplementedError();
  }

  @override
  Future<String?> getLibraryPath() {
    // TODO: implement getLibraryPath
    throw UnimplementedError();
  }

  @override
  Future<String?> getTemporaryPath() {
    // TODO: implement getTemporaryPath
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize fake path provider for testing
    PathProviderPlatform.instance = FakePathProviderPlatform();
    // Initialize Hive for testing
    await Hive.initFlutter();
  });

  tearDown(() async {
    // Clear cache after each test
    await CacheService.clearCache();
  });

  group('CacheService', () {
    group('saveMarketData and loadMarketData', () {
      test('should save and load market data correctly', () async {
        // Arrange
        final testData = [
          MarketData(
            symbol: 'BTC',
            price: 50000,
            change24h: 1000,
            changePercent24h: 2.0,
            volume: 1000000,
          ),
          MarketData(
            symbol: 'ETH',
            price: 3000,
            change24h: -50,
            changePercent24h: -1.5,
            volume: 500000,
          ),
        ];

        // Act
        await CacheService.saveMarketData(testData);
        final loadedData = await CacheService.loadMarketData();

        // Assert
        expect(loadedData, isNotNull);
        expect(loadedData!.length, equals(2));
        expect(loadedData[0].symbol, equals('BTC'));
        expect(loadedData[1].symbol, equals('ETH'));
        expect(loadedData[0].price, equals(50000));
      });

      test('should return null when no cache exists', () async {
        // Act
        final loadedData = await CacheService.loadMarketData();

        // Assert
        expect(loadedData, isNull);
      });

      test('should overwrite existing cache', () async {
        // Arrange
        final initialData = [
          MarketData(
            symbol: 'BTC',
            price: 50000,
            change24h: 1000,
            changePercent24h: 2.0,
            volume: 1000000,
          ),
        ];

        final updatedData = [
          MarketData(
            symbol: 'ETH',
            price: 3000,
            change24h: -50,
            changePercent24h: -1.5,
            volume: 500000,
          ),
        ];

        // Act
        await CacheService.saveMarketData(initialData);
        await CacheService.saveMarketData(updatedData);
        final loadedData = await CacheService.loadMarketData();

        // Assert
        expect(loadedData, isNotNull);
        expect(loadedData!.length, equals(1));
        expect(loadedData[0].symbol, equals('ETH'));
      });
    });

    group('getCacheTimestamp', () {
      test('should return timestamp after saving data', () async {
        // Arrange
        final testData = [
          MarketData(
            symbol: 'BTC',
            price: 50000,
            change24h: 1000,
            changePercent24h: 2.0,
            volume: 1000000,
          ),
        ];

        // Act
        await CacheService.saveMarketData(testData);
        final timestamp = await CacheService.getCacheTimestamp();

        // Assert
        expect(timestamp, isNotNull);
        expect(timestamp!.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
        expect(timestamp.isAfter(DateTime.now().subtract(const Duration(seconds: 1))), isTrue);
      });

      test('should return null when no cache exists', () async {
        // Act
        final timestamp = await CacheService.getCacheTimestamp();

        // Assert
        expect(timestamp, isNull);
      });
    });

    group('hasValidCache', () {
      test('should return true for fresh cache', () async {
        // Arrange
        final testData = [
          MarketData(
            symbol: 'BTC',
            price: 50000,
            change24h: 1000,
            changePercent24h: 2.0,
            volume: 1000000,
          ),
        ];

        // Act
        await CacheService.saveMarketData(testData);
        final hasValid = await CacheService.hasValidCache();

        // Assert
        expect(hasValid, isTrue);
      });

      test('should return false when no cache exists', () async {
        // Act
        final hasValid = await CacheService.hasValidCache();

        // Assert
        expect(hasValid, isFalse);
      });
    });

    group('isCacheExpired', () {
      test('should return false for fresh cache', () async {
        // Arrange
        final testData = [
          MarketData(
            symbol: 'BTC',
            price: 50000,
            change24h: 1000,
            changePercent24h: 2.0,
            volume: 1000000,
          ),
        ];

        // Act
        await CacheService.saveMarketData(testData);
        final isExpired = await CacheService.isCacheExpired();

        // Assert
        expect(isExpired, isFalse);
      });

      test('should return true when no cache exists', () async {
        // Act
        final isExpired = await CacheService.isCacheExpired();

        // Assert
        expect(isExpired, isTrue);
      });
    });

    group('clearCache', () {
      test('should clear all cached data', () async {
        // Arrange
        final testData = [
          MarketData(
            symbol: 'BTC',
            price: 50000,
            change24h: 1000,
            changePercent24h: 2.0,
            volume: 1000000,
          ),
        ];

        // Act
        await CacheService.saveMarketData(testData);
        await CacheService.clearCache();
        final loadedData = await CacheService.loadMarketData();
        final timestamp = await CacheService.getCacheTimestamp();

        // Assert
        expect(loadedData, isNull);
        expect(timestamp, isNull);
      });
    });
  });
}
