import 'package:flutter/cupertino.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import 'package:pulsenow_flutter/screens/home_screen.dart';
import 'package:pulsenow_flutter/screens/market_data/market_data_details_screen.dart';

class AppRouter {
  static String currentRoute = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    currentRoute = settings.name ?? '/';
    switch (settings.name) {
      //default
      case '/market-data-details':
        return CupertinoPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => MarketDataDetailsScreen(marketData: settings.arguments as MarketData),
        );
      default:
        return CupertinoPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
