import 'package:dio/dio.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
  final Dio dio = Dio();

  Future<List<MarketData>> getMarketData() async {
    try {
      final result = await dio.get('$baseUrl/market-data');
      if (result.data == null) {
        throw UnimplementedError('getMarketData() empty response');
      }
      return MarketData.fromJsonList(result.data['data']);
    } on DioException catch (e) {
      throw UnimplementedError('getMarketData() error: $e');
    } catch (e) {
      throw UnimplementedError('getMarketData() error: $e');
    }
  }
}
