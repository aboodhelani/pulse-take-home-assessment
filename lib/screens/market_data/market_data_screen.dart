import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pulsenow_flutter/enms/sort_type.dart';
import 'package:pulsenow_flutter/screens/market_data/widgets/market_data_card.dart';
import 'package:pulsenow_flutter/screens/market_data/widgets/sort_chip.dart';
import '../../providers/market_data_provider.dart';

class MarketDataScreen extends StatefulWidget {
  const MarketDataScreen({super.key});

  @override
  State<MarketDataScreen> createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> with TickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final Map<String, AnimationController> _animationControllers = {};
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final provider = Provider.of<MarketDataProvider>(context, listen: false);
      // Initialize cache first
      await provider.initialize();
      // Then load fresh data
      await provider.loadMarketData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();
    _searchController.dispose();
    super.dispose();
  }

  AnimationController _getOrCreateController(String key) {
    if (!_animationControllers.containsKey(key)) {
      _animationControllers[key] = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    }
    return _animationControllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MarketDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.marketData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: const AlwaysStoppedAnimation(1.0),
                  child: Text(
                    'Loading market data...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withAlpha(60),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return FadeTransition(
            opacity: const AlwaysStoppedAnimation(1.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + (value * 0.2),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error loading data',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(70),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: ElevatedButton.icon(
                        onPressed: () => provider.loadMarketData(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (provider.allMarketData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.textTheme.bodyLarge?.color?.withAlpha(30),
                ),
                const SizedBox(height: 16),
                Text(
                  'No market data available',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withAlpha(60),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.marketData.isEmpty && (provider.searchQuery.isNotEmpty || provider.sortType != SortType.none)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.textTheme.bodyLarge?.color?.withAlpha(30),
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withAlpha(60),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    provider.clearFilters();
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear filters'),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withAlpha(95),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, -10 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        provider.setSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by symbol...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        suffixIcon: provider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: theme.colorScheme.primary),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sort Controls
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, -10 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12, right: 8),
                                child: Icon(
                                  Icons.sort,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      SortChip(
                                        label: 'Symbol',
                                        sortType: SortType.symbol,
                                        currentSortType: provider.sortType,
                                        isAscending: provider.sortAscending,
                                        onTap: () => provider.setSortType(SortType.symbol),
                                      ),
                                      const SizedBox(width: 8),
                                      SortChip(
                                        label: 'Price',
                                        sortType: SortType.price,
                                        currentSortType: provider.sortType,
                                        isAscending: provider.sortAscending,
                                        onTap: () => provider.setSortType(SortType.price),
                                      ),
                                      const SizedBox(width: 8),
                                      SortChip(
                                        label: 'Change',
                                        sortType: SortType.change,
                                        currentSortType: provider.sortType,
                                        isAscending: provider.sortAscending,
                                        onTap: () => provider.setSortType(SortType.change),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (provider.sortType != SortType.none || provider.searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            icon: Icon(Icons.clear_all, color: theme.colorScheme.primary),
                            onPressed: () {
                              provider.clearFilters();
                              _searchController.clear();
                            },
                            tooltip: 'Clear filters',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Results count and cache indicator
                if (provider.searchQuery.isNotEmpty || provider.sortType != SortType.none || provider.isFromCache)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (provider.searchQuery.isNotEmpty || provider.sortType != SortType.none)
                          Text(
                            '${provider.marketData.length} result${provider.marketData.length != 1 ? 's' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        if (provider.isFromCache && provider.cacheTimestamp != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.offline_bolt,
                                size: 14,
                                color: theme.colorScheme.secondary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Cached ${_formatTimestamp(provider.cacheTimestamp!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                // Animated header
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, -20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Symbol',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Price',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '24h Change',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      await provider.loadMarketData();
                      _refreshController.refreshCompleted();
                    },
                    header: WaterDropHeader(
                      waterDropColor: theme.colorScheme.primary,
                    ),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.marketData.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final marketData = provider.marketData[index];
                        final animationKey = marketData.symbol ?? index.toString();
                        final controller = _getOrCreateController(animationKey);

                        // Start animation if not already started
                        if (!controller.isAnimating && controller.value == 0) {
                          Future.delayed(Duration(milliseconds: index * 100), () {
                            if (mounted) controller.forward();
                          });
                        }

                        return MarketDataCard(
                          marketData: marketData,
                          animation: CurvedAnimation(
                            parent: controller,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
