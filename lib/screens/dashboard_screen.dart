import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../main.dart'; // for supabase instance
import 'add_new_script_screen.dart';
import '../mock_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'watchlist_screen.dart';
import 'tools_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Key _refreshKey = UniqueKey();

  Future<void> _logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NEPSE Pro',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primary,
              ),
        ),
        backgroundColor: AppTheme.surfaceContainerLowest,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.onSurfaceVariant),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        key: _refreshKey,
        index: _currentIndex,
        children: [
          const _DashboardTab(),
          const _PortfolioTab(),
          const WatchlistScreen(),
          const _MarketStatsTab(),
          const ToolsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewScriptScreen()),
          );
          if (result == true) {
            setState(() {
              _refreshKey = UniqueKey();
            });
          }
        },
        backgroundColor: AppTheme.primaryContainer,
        child: const Icon(Icons.add, color: AppTheme.onPrimaryContainer),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.surfaceContainerLowest,
        indicatorColor: AppTheme.secondaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Market Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  late Future<List<Map<String, dynamic>>> _portfolioFuture;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
  }

  void _fetchPortfolio() {
    _portfolioFuture = supabase.from('portfolio').select().order('created_at', ascending: false);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _fetchPortfolio();
    });
    await _portfolioFuture;
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _portfolioFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }

          final data = snapshot.data ?? [];

          // Group by symbol
          Map<String, Map<String, dynamic>> groupedData = {};
          double totalInvested = 0;
          double currentPortfolioValue = 0;
          double todaysChangeRs = 0;

          for (var row in data) {
            final symbol = row['symbol'];
            final price = (row['purchase_price'] as num).toDouble();
            final qty = (row['quantity'] as num).toInt();
            
            if (groupedData.containsKey(symbol)) {
              final prevQty = groupedData[symbol]!['quantity'] as int;
              final prevTotal = groupedData[symbol]!['total_invested'] as double;
              groupedData[symbol]!['quantity'] = prevQty + qty;
              groupedData[symbol]!['total_invested'] = prevTotal + (price * qty);
              groupedData[symbol]!['avg_price'] = groupedData[symbol]!['total_invested'] / groupedData[symbol]!['quantity'];
            } else {
              groupedData[symbol] = {
                'symbol': symbol,
                'quantity': qty,
                'total_invested': price * qty,
                'avg_price': price,
              };
            }
          }

          List<Widget> liveItems = [];

          groupedData.forEach((symbol, info) {
            final qty = info['quantity'] as int;
            final invested = info['total_invested'] as double;
            totalInvested += invested;

            final liveData = MockData.getLivePrice(symbol);
            final livePrice = liveData['price'] as double;
            final changeRs = liveData['change_rs'] as double;
            final changePct = liveData['change'] as double;

            final currentValue = livePrice * qty;
            currentPortfolioValue += currentValue;
            todaysChangeRs += (changeRs * qty);

            final totalGain = currentValue - invested;
            final totalGainPct = (totalGain / invested) * 100;
            final isPositive = totalGain >= 0;

            liveItems.add(
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('$qty Units', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('LTP: Rs. $livePrice', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${changeRs > 0 ? '+' : ''}$changeRs (${changePct > 0 ? '+' : ''}$changePct%)', style: TextStyle(color: changeRs >= 0 ? AppTheme.primary : AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(isPositive ? '+ Rs. ${currencyFormat.format(totalGain)}' : '- Rs. ${currencyFormat.format(totalGain.abs())}', style: TextStyle(color: isPositive ? AppTheme.primary : AppTheme.error, fontWeight: FontWeight.bold)),
                          Text('${isPositive ? '+' : ''}${totalGainPct.toStringAsFixed(2)}%', style: TextStyle(color: isPositive ? AppTheme.primary : AppTheme.error, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            );
          });

          final overallGain = currentPortfolioValue - totalInvested;
          final isTodayPositive = todaysChangeRs >= 0;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Balance', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onPrimaryContainer.withOpacity(0.8))),
                        const SizedBox(height: 4),
                        Text(
                          'NPR ${currencyFormat.format(currentPortfolioValue)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Today: ', style: TextStyle(color: AppTheme.onPrimaryContainer.withOpacity(0.8))),
                            Text(
                              '${isTodayPositive ? '+' : '-'} NPR ${currencyFormat.format(todaysChangeRs.abs())}',
                              style: TextStyle(color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Icon(Icons.show_chart, size: 48, color: AppTheme.onPrimaryContainer),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Live P&L', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Today\'s Change', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: data.isEmpty 
                  ? Center(
                      child: Text('No scripts added yet. Click + to add.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: liveItems,
                    ),
              ),
            ],
          );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioTab extends StatefulWidget {
  const _PortfolioTab();

  @override
  State<_PortfolioTab> createState() => _PortfolioTabState();
}

class _PortfolioTabState extends State<_PortfolioTab> {
  late Future<List<Map<String, dynamic>>> _portfolioFuture;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
  }

  void _fetchPortfolio() {
    _portfolioFuture = supabase.from('portfolio').select().order('created_at', ascending: false);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _fetchPortfolio();
    });
    await _portfolioFuture;
  }

  Future<void> _deleteSymbol(String symbol) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      
      final response = await supabase.from('portfolio')
          .delete()
          .eq('symbol', symbol)
          .eq('user_id', user.id)
          .select();
          
      if (response.isEmpty) {
        throw Exception('0 rows deleted. (Missing DELETE policy in Supabase RLS?)');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$symbol deleted from portfolio')));
      }
      _handleRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppTheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');
    
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primary,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _portfolioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text('Your portfolio is empty.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ),
                ),
              ],
            );
          }

          // Group by symbol
          Map<String, Map<String, dynamic>> groupedData = {};
          double totalInvested = 0;
          double currentPortfolioValue = 0;

          for (var row in data) {
            final symbol = row['symbol'];
            final price = (row['purchase_price'] as num).toDouble();
            final qty = (row['quantity'] as num).toInt();
            
            if (groupedData.containsKey(symbol)) {
              final prevQty = groupedData[symbol]!['quantity'] as int;
              final prevTotal = groupedData[symbol]!['total_invested'] as double;
              groupedData[symbol]!['quantity'] = prevQty + qty;
              groupedData[symbol]!['total_invested'] = prevTotal + (price * qty);
              groupedData[symbol]!['avg_price'] = groupedData[symbol]!['total_invested'] / groupedData[symbol]!['quantity'];
            } else {
              groupedData[symbol] = {
                'symbol': symbol,
                'quantity': qty,
                'total_invested': price * qty,
                'avg_price': price,
              };
            }
          }

          List<PieChartSectionData> pieSections = [];
          final colors = [AppTheme.primary, AppTheme.secondary, Colors.orange, Colors.purple, Colors.teal, Colors.indigo];
          int colorIndex = 0;

          List<Widget> listItems = [];
          
          groupedData.forEach((symbol, info) {
            final qty = info['quantity'] as int;
            final avgPrice = info['avg_price'] as double;
            final invested = info['total_invested'] as double;
            totalInvested += invested;

            final liveData = MockData.getLivePrice(symbol);
            final livePrice = liveData['price'] as double;
            final changeRs = liveData['change_rs'] as double;
            final changePct = liveData['change'] as double;

            final currentValue = livePrice * qty;
            currentPortfolioValue += currentValue;
            
            final totalGain = currentValue - invested;
            final totalGainPct = (totalGain / invested) * 100;
            final isPositive = totalGain >= 0;

            pieSections.add(PieChartSectionData(
              color: colors[colorIndex % colors.length],
              value: currentValue,
              title: symbol,
              radius: 50,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ));
            colorIndex++;

            listItems.add(
              Dismissible(
                key: Key(symbol),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _deleteSymbol(symbol);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppTheme.surfaceContainerLowest,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(symbol, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                            ),
                            Text('NPR ${currencyFormat.format(currentValue)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                              onPressed: () => _deleteSymbol(symbol),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.only(left: 8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('$qty Units | Avg: NPR ${currencyFormat.format(avgPrice)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: isPositive ? AppTheme.primary : AppTheme.error),
                                  Flexible(
                                    child: Text(
                                      ' ${currencyFormat.format(totalGain.abs())} (${totalGainPct.toStringAsFixed(2)}%)',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isPositive ? AppTheme.primary : AppTheme.error, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('LTP: Rs. $livePrice', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text('Today: ${changeRs > 0 ? '+' : ''}$changeRs (${changePct > 0 ? '+' : ''}$changePct%)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: changeRs >= 0 ? AppTheme.primary : AppTheme.error)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            );
          });
          
          final overallGain = currentPortfolioValue - totalInvested;
          final overallGainPct = totalInvested > 0 ? (overallGain / totalInvested) * 100 : 0;
          final isOverallPositive = overallGain >= 0;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Portfolio Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Text('Current Value', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('NPR ${currencyFormat.format(currentPortfolioValue)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total Gain: ', style: Theme.of(context).textTheme.bodyMedium),
                        Icon(isOverallPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: isOverallPositive ? AppTheme.primary : AppTheme.error),
                        Text(
                          ' Rs. ${currencyFormat.format(overallGain.abs())} (${overallGainPct.toStringAsFixed(2)}%)',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: isOverallPositive ? AppTheme.primary : AppTheme.error, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Allocation Pie Chart
              if (pieSections.isNotEmpty) ...[
                Text('Asset Allocation', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text('Holdings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...listItems,
            ],
          );
        },
      ),
    );
  }
}

class _MarketStatsTab extends StatelessWidget {
  const _MarketStatsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Market Stats & Insights', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          const SizedBox(height: 8),
          Text('Real-time technical analysis and institutional flow.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          
          // NEPSE Line Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('NEPSE Index', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Text('2,154.32', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sensitive: 410.15', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const Text('+15.42 (0.72%)', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 2100),
                            FlSpot(1, 2120),
                            FlSpot(2, 2110),
                            FlSpot(3, 2140),
                            FlSpot(4, 2130),
                            FlSpot(5, 2154),
                          ],
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Technicals Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NEPSE Index Technicals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Live', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Technicals Cards
          Row(
            children: [
              Expanded(
                child: _buildTechnicalCard(
                  context,
                  title: 'RSI (14)',
                  value: '68.4',
                  subtitle: 'Approaching Overbought',
                  subtitleColor: AppTheme.primary,
                  icon: Icons.show_chart,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTechnicalCard(
                  context,
                  title: 'MACD',
                  value: '+12.5',
                  subtitle: 'Bullish Crossover',
                  subtitleColor: AppTheme.primary,
                  icon: Icons.stacked_line_chart,
                  isPositive: true,
                  isUpArrow: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Whale Tracker Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.track_changes, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text('Whale Tracker', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Text('Filter', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                label: const Icon(Icons.filter_list, size: 18, color: AppTheme.onSurfaceVariant),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Whale Tracker List
          _buildWhaleTrackerItem(
            context,
            type: 'HUGE BUY',
            symbol: 'NABIL',
            qty: '50,000',
            price: '610',
            tag1: 'Institutional',
            vol: '30.5M',
            time: 'Just now',
            isBuy: true,
          ),
          _buildWhaleTrackerItem(
            context,
            type: 'BLOCK SELL',
            symbol: 'NICA',
            qty: '120,000',
            price: '745',
            tag1: 'Off-market',
            tag1Color: Colors.red.shade100,
            tag1TextColor: Colors.red.shade800,
            vol: '89.4M',
            time: '5m ago',
            isBuy: false,
          ),
          _buildWhaleTrackerItem(
            context,
            type: 'ACCUMULATION',
            symbol: 'SHIVM',
            qty: '25,000',
            price: '420',
            tag1: 'Broker 45',
            vol: '10.5M',
            time: '12m ago',
            isBuy: true,
          ),
          _buildWhaleTrackerItem(
            context,
            type: 'LARGE BUY',
            symbol: 'GBIME',
            qty: '30,000',
            price: '185',
            tag1: 'Institutional',
            vol: '5.5M',
            time: '28m ago',
            isBuy: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalCard(BuildContext context, {required String title, required String value, required String subtitle, required Color subtitleColor, required IconData icon, required bool isPositive, bool isUpArrow = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
              Icon(icon, size: 16, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: isPositive ? AppTheme.primary : AppTheme.error)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isUpArrow) const Icon(Icons.arrow_upward, size: 12, color: AppTheme.primary) else Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: subtitleColor)),
              const SizedBox(width: 4),
              Expanded(child: Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhaleTrackerItem(BuildContext context, {required String type, required String symbol, required String qty, required String price, required String tag1, Color? tag1Color, Color? tag1TextColor, required String vol, required String time, required bool isBuy}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isBuy ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(isBuy ? Icons.arrow_downward : Icons.arrow_upward, color: isBuy ? AppTheme.primary : Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$type: $symbol', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppTheme.onSurface, fontSize: 13),
                    children: [
                      TextSpan(text: '$qty units ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'at '),
                      TextSpan(text: 'Rs. $price', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tag1Color ?? Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(tag1, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tag1TextColor ?? AppTheme.primary)),
                    ),
                    const SizedBox(width: 8),
                    Text('Vol: Rs. $vol', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

