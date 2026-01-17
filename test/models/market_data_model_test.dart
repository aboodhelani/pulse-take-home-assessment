import 'package:flutter_test/flutter_test.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';

void main() {
  group('MarketData', () {
    test('should create MarketData with all fields', () {
      // Arrange & Act
      final marketData = MarketData(
        symbol: 'BTC',
        price: 50000,
        change24h: 1000,
        changePercent24h: 2.0,
        volume: 1000000,
      );

      // Assert
      expect(marketData.symbol, equals('BTC'));
      expect(marketData.price, equals(50000));
      expect(marketData.change24h, equals(1000));
      expect(marketData.changePercent24h, equals(2.0));
      expect(marketData.volume, equals(1000000));
    });

    test('should create MarketData with null values', () {
      // Arrange & Act
      final marketData = MarketData(
        symbol: null,
        price: null,
        change24h: null,
        changePercent24h: null,
        volume: null,
      );

      // Assert
      expect(marketData.symbol, isNull);
      expect(marketData.price, isNull);
      expect(marketData.change24h, isNull);
      expect(marketData.changePercent24h, isNull);
      expect(marketData.volume, isNull);
    });

    test('fromJsonList should handle empty list', () {
      // Act
      final result = MarketData.fromJsonList([]);

      // Assert
      expect(result, isEmpty);
    });

    test('fromJsonList should handle null', () {
      // Act
      final result = MarketData.fromJsonList(null);

      // Assert
      expect(result, isEmpty);
    });

    test('fromJsonList should parse list of JSON objects', () {
      // Arrange
      final jsonList = [
        {
          'symbol': 'BTC',
          'price': '50000',
          'change24h': '1000',
          'changePercent24h': '2.0',
          'volume': '1000000',
        },
        {
          'symbol': 'ETH',
          'price': 3000,
          'change24h': -50,
          'changePercent24h': -1.5,
          'volume': 500000,
        },
      ];

      // Act
      final result = MarketData.fromJsonList(jsonList);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].symbol, equals('BTC'));
      expect(result[1].symbol, equals('ETH'));
    });

    test('toJson should convert to JSON format', () {
      // Arrange
      final marketData = MarketData(
        symbol: 'BTC',
        price: 50000,
        change24h: 1000,
        changePercent24h: 2.0,
        volume: 1000000,
      );

      // Act
      final json = marketData.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['symbol'], equals('BTC'));
      expect(json['price'], equals(50000));
    });
  });
}

