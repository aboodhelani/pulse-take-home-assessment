// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketData _$MarketDataFromJson(Map<String, dynamic> json) => MarketData(
      symbol: json['symbol'] as String?,
      price: MarketData._numFromJson(json['price']),
      change24h: MarketData._numFromJson(json['change24h']),
      changePercent24h: MarketData._numFromJson(json['changePercent24h']),
      volume: MarketData._numFromJson(json['volume']),
    );

Map<String, dynamic> _$MarketDataToJson(MarketData instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'price': MarketData._numToJson(instance.price),
      'change24h': MarketData._numToJson(instance.change24h),
      'changePercent24h': MarketData._numToJson(instance.changePercent24h),
      'volume': MarketData._numToJson(instance.volume),
    };
