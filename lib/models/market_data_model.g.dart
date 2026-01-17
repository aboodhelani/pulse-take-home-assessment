// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketData _$MarketDataFromJson(Map<String, dynamic> json) => MarketData(
      symbol: json['symbol'] as String?,
      price: json['price'] as num?,
      change24h: json['change24h'] as num?,
      changePercent24h: json['changePercent24h'] as num?,
      volume: json['volume'] as num?,
    );

Map<String, dynamic> _$MarketDataToJson(MarketData instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'price': instance.price,
      'change24h': instance.change24h,
      'changePercent24h': instance.changePercent24h,
      'volume': instance.volume,
    };
