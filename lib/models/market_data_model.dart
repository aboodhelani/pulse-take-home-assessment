import 'package:json_annotation/json_annotation.dart';

part 'market_data_model.g.dart';

@JsonSerializable()
class MarketData {
  final String? symbol;
  @JsonKey(fromJson: _numFromJson, toJson: _numToJson)
  final num? price;
  @JsonKey(fromJson: _numFromJson, toJson: _numToJson)
  final num? change24h;
  @JsonKey(fromJson: _numFromJson, toJson: _numToJson)
  final num? changePercent24h;
  @JsonKey(fromJson: _numFromJson, toJson: _numToJson)
  final num? volume;

  MarketData({required this.symbol, required this.price, required this.change24h, required this.changePercent24h, required this.volume});

  factory MarketData.fromJson(json) => _$MarketDataFromJson(json);

  Map<String, dynamic> toJson() => _$MarketDataToJson(this);

  static List<MarketData> fromJsonList(List? json) => json?.map((e) => MarketData.fromJson(e)).toList() ?? [];

  static num? _numFromJson(dynamic json) => json is String ? num.tryParse(json) : json;
  static dynamic _numToJson(num? num) => num;
}
