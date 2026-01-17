import 'package:flutter/material.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import 'package:pulsenow_flutter/screens/market_data/widgets/detail_card.dart';
import 'package:pulsenow_flutter/screens/market_data/widgets/detail_section.dart';
import 'package:pulsenow_flutter/screens/market_data/widgets/header_detail_card.dart';
import 'package:pulsenow_flutter/utils/extensions.dart';

class MarketDataDetailsScreen extends StatefulWidget {
  final MarketData marketData;

  const MarketDataDetailsScreen({
    super.key,
    required this.marketData,
  });

  @override
  State<MarketDataDetailsScreen> createState() => _MarketDataDetailsScreenState();
}

class _MarketDataDetailsScreenState extends State<MarketDataDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = widget.marketData.change24h != null && widget.marketData.change24h! > 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.marketData.symbol ?? 'Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderDetailCard(
                  marketData: widget.marketData,
                  changeColor: changeColor,
                  isPositive: isPositive,
                ),
                const SizedBox(height: 24),
                DetailSection(
                  title: 'Price Information',
                  child: Column(
                    children: [
                      DetailCard(
                        icon: Icons.attach_money,
                        iconColor: theme.colorScheme.primary,
                        label: 'Current Price',
                        value: widget.marketData.price.formattedPrice,
                        animation: _fadeAnimation,
                        delay: 100,
                      ),
                      const SizedBox(height: 12),
                      DetailCard(
                        icon: isPositive ? Icons.trending_up : Icons.trending_down,
                        iconColor: changeColor,
                        label: '24h Change',
                        value: widget.marketData.change24h.formattedPercentage,
                        animation: _fadeAnimation,
                        delay: 200,
                        valueStyle: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DetailCard(
                        icon: Icons.percent,
                        iconColor: theme.colorScheme.secondary,
                        label: '24h Change %',
                        value: widget.marketData.changePercent24h?.formattedPercentage ?? '-',
                        animation: _fadeAnimation,
                        delay: 300,
                        valueStyle: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                DetailSection(
                  title: 'Trading Information',
                  child: DetailCard(
                    icon: Icons.bar_chart,
                    iconColor: theme.colorScheme.tertiary,
                    label: '24h Volume',
                    value: widget.marketData.volume?.formattedVolume ?? '-',
                    animation: _fadeAnimation,
                    delay: 400,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
