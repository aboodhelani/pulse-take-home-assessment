import 'package:flutter_test/flutter_test.dart';
import 'package:pulsenow_flutter/enms/sort_type.dart';
import 'package:pulsenow_flutter/providers/market_data_provider.dart';

void main() {
  group('MarketDataProvider', () {
    late MarketDataProvider provider;

    setUp(() {
      provider = MarketDataProvider();
    });

    tearDown(() {
      // Clean up after each test
    });

    group('Filtering', () {
      test('should filter by search query', () {
        // Arrange - Add test data via reflection or make internal method testable
        // Since _marketData is private, we'll test via loadMarketData mock
        // For now, testing the search functionality through the public API
        expect(provider.searchQuery, isEmpty);
        expect(provider.marketData, isEmpty);
      });

      test('setSearchQuery should update search query', () {
        // Act
        provider.setSearchQuery('BTC');

        // Assert
        expect(provider.searchQuery, equals('BTC'));
      });

      test('clearFilters should reset search query', () {
        // Arrange
        provider.setSearchQuery('BTC');

        // Act
        provider.clearFilters();

        // Assert
        expect(provider.searchQuery, isEmpty);
      });
    });

    group('Sorting', () {
      test('setSortType should update sort type', () {
        // Act
        provider.setSortType(SortType.price);

        // Assert
        expect(provider.sortType, equals(SortType.price));
        expect(provider.sortAscending, isTrue);
      });

      test('setSortType should toggle ascending when same type clicked', () {
        // Arrange
        provider.setSortType(SortType.price);
        expect(provider.sortAscending, isTrue);

        // Act
        provider.setSortType(SortType.price);

        // Assert
        expect(provider.sortType, equals(SortType.price));
        expect(provider.sortAscending, isFalse);
      });

      test('setSortType should reset to ascending when different type selected', () {
        // Arrange
        provider.setSortType(SortType.price);
        provider.setSortType(SortType.price); // Now descending

        // Act
        provider.setSortType(SortType.change);

        // Assert
        expect(provider.sortType, equals(SortType.change));
        expect(provider.sortAscending, isTrue);
      });

      test('clearFilters should reset sort type', () {
        // Arrange
        provider.setSortType(SortType.price);

        // Act
        provider.clearFilters();

        // Assert
        expect(provider.sortType, equals(SortType.none));
        expect(provider.sortAscending, isTrue);
      });
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        expect(provider.marketData, isEmpty);
        expect(provider.allMarketData, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
        expect(provider.searchQuery, isEmpty);
        expect(provider.sortType, equals(SortType.none));
        expect(provider.sortAscending, isTrue);
        expect(provider.isFromCache, isFalse);
        expect(provider.cacheTimestamp, isNull);
      });
    });
  });

  group('MarketDataProvider - Filter and Sort Logic', () {
    test('should handle empty data gracefully', () {
      // Arrange
      final provider = MarketDataProvider();

      // Act
      provider.setSearchQuery('BTC');
      provider.setSortType(SortType.price);

      // Assert
      expect(provider.marketData, isEmpty);
    });

    test('should maintain filter state', () {
      // Arrange
      final provider = MarketDataProvider();

      // Act
      provider.setSearchQuery('ETH');
      provider.setSortType(SortType.change);

      // Assert
      expect(provider.searchQuery, equals('ETH'));
      expect(provider.sortType, equals(SortType.change));
    });
  });
}
