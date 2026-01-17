import 'package:flutter_test/flutter_test.dart';
import 'package:pulsenow_flutter/utils/extensions.dart';

void main() {
  group('NumExtensions', () {
    group('formattedPrice', () {
      test('should format price with dollar sign and commas', () {
        expect(1234.56.formattedPrice, equals('\$1,234.56'));
        expect(1234567.89.formattedPrice, equals('\$1,234,567.89'));
        expect(123.formattedPrice, equals('\$123.00'));
      });

      test('should handle null values', () {
        num? nullValue;
        expect(nullValue.formattedPrice, equals(r'$-'));
      });

      test('should format small prices correctly', () {
        expect(0.99.formattedPrice, equals('\$0.99'));
        expect(1.5.formattedPrice, equals('\$1.50'));
      });
    });

    group('formattedPercentage', () {
      test('should format positive percentages with + sign', () {
        expect(5.5.formattedPercentage, equals('+5.5%'));
        expect(100.formattedPercentage, equals('+100%'));
      });

      test('should format negative percentages without + sign', () {
        expect((-5.5).formattedPercentage, equals('-5.5%'));
        expect((-10).formattedPercentage, equals('-10%'));
      });

      test('should handle null values', () {
        num? nullValue;
        expect(nullValue.formattedPercentage, equals('-%'));
      });

      test('should handle zero', () {
        expect(0.formattedPercentage, equals('0%'));
      });
    });

    group('formattedVolume', () {
      test('should format trillions', () {
        expect(1500000000000.formattedVolume, equals('\$1.50T'));
        expect(2000000000000.formattedVolume, equals('\$2.00T'));
      });

      test('should format billions', () {
        expect(1500000000.formattedVolume, equals('\$1.50B'));
        expect(2500000000.formattedVolume, equals('\$2.50B'));
      });

      test('should format millions', () {
        expect(1500000.formattedVolume, equals('\$1.50M'));
        expect(25000000.formattedVolume, equals('\$25.00M'));
      });

      test('should format thousands', () {
        expect(1500.formattedVolume, equals('\$1.50K'));
        expect(25000.formattedVolume, equals('\$25.00K'));
      });

      test('should format values less than 1000', () {
        expect(500.formattedVolume, equals('\$500.00'));
        expect(99.99.formattedVolume, equals('\$99.99'));
      });

      test('should handle null values', () {
        num? nullValue;
        expect(nullValue.formattedVolume, equals('-'));
      });
    });

    group('formattedLargeNumber', () {
      test('should format trillions without dollar sign', () {
        expect(1500000000000.formattedLargeNumber, equals('1.50T'));
        expect(2000000000000.formattedLargeNumber, equals('2.00T'));
      });

      test('should format billions without dollar sign', () {
        expect(1500000000.formattedLargeNumber, equals('1.50B'));
        expect(2500000000.formattedLargeNumber, equals('2.50B'));
      });

      test('should format millions without dollar sign', () {
        expect(1500000.formattedLargeNumber, equals('1.50M'));
        expect(25000000.formattedLargeNumber, equals('25.00M'));
      });

      test('should format thousands without dollar sign', () {
        expect(1500.formattedLargeNumber, equals('1.50K'));
        expect(25000.formattedLargeNumber, equals('25.00K'));
      });

      test('should format values less than 1000', () {
        expect(500.formattedLargeNumber, equals('500.00'));
        expect(99.99.formattedLargeNumber, equals('99.99'));
      });

      test('should handle null values', () {
        num? nullValue;
        expect(nullValue.formattedLargeNumber, equals('-'));
      });
    });
  });
}
