import 'package:dio/dio.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
  final Dio dio = Dio();

  // TODO: Implement getMarketData() method
  // This should call GET /api/market-data and return the response
  // Example:
  // Future<List<Map<String, dynamic>>> getMarketData() async {
  //   final response = await http.get(Uri.parse('$baseUrl/market-data'));
  //   if (response.statusCode == 200) {
  //     final jsonData = json.decode(response.body);
  //     return List<Map<String, dynamic>>.from(jsonData['data']);
  //   } else {
  //     throw Exception('Failed to load market data: ${response.statusCode}');
  //   }
  // }

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
