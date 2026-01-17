import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pulsenow_flutter/utils/extensions.dart';
import '../providers/market_data_provider.dart';

class MarketDataScreen extends StatefulWidget {
  const MarketDataScreen({super.key});

  @override
  State<MarketDataScreen> createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<MarketDataProvider>(context, listen: false).loadMarketData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadMarketData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Symbol', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('24h Change', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: provider.loadMarketData,
                  child: ListView.builder(
                    itemCount: provider.marketData.length,
                    itemBuilder: (context, index) {
                      final marketData = provider.marketData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(marketData.symbol ?? '-'),
                            Text(marketData.price.formattedPrice),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    marketData.change24h != null && marketData.change24h! > 0 ? Colors.green.withAlpha(20) : Colors.red.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                marketData.change24h.formattedPercentage,
                                style: TextStyle(
                                    color: marketData.change24h != null && marketData.change24h! > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
