import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../main.dart'; // for supabase instance
import 'add_new_script_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

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
        index: _currentIndex,
        children: [
          const _DashboardTab(),
          const _PortfolioTab(),
          const _MarketStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewScriptScreen()),
          );
          if (result == true) {
            // StreamBuilder will automatically update
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
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Market Stats',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('portfolio').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                final data = snapshot.data ?? [];
                
                double totalInvestment = 0;
                for (var row in data) {
                  final price = (row['purchase_price'] as num).toDouble();
                  final qty = (row['quantity'] as num).toInt();
                  totalInvestment += (price * qty);
                }

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
                              Text('Total Investment', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onPrimaryContainer.withOpacity(0.8))),
                              const SizedBox(height: 8),
                              Text(
                                'NPR ${currencyFormat.format(totalInvestment)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Icon(Icons.account_balance_wallet, size: 48, color: AppTheme.onPrimaryContainer),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: data.isEmpty 
                        ? Center(
                            child: Text('No scripts added yet. Click + to add.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
                          )
                        : ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final item = data[index];
                              final price = (item['purchase_price'] as num).toDouble();
                              final qty = (item['quantity'] as num).toInt();
                              final total = price * qty;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.surfaceContainerHigh,
                                  child: Text(item['symbol'].toString().substring(0, 1), style: const TextStyle(color: AppTheme.primary)),
                                ),
                                title: Text(item['symbol'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('$qty Units @ NPR ${currencyFormat.format(price)}'),
                                trailing: Text('NPR ${currencyFormat.format(total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab();

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('portfolio').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return Center(
            child: Text('Your portfolio is empty.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final price = (item['purchase_price'] as num).toDouble();
            final qty = (item['quantity'] as num).toInt();
            final date = item['purchase_date'].toString();
            
            return Card(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['symbol'], style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        Text('NPR ${currencyFormat.format(price * qty)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$qty Units @ NPR $price', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                        Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MarketStatsTab extends StatelessWidget {
  const _MarketStatsTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Market Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              border: Border.all(color: AppTheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('NEPSE Index', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                        Text(' 2,145.32', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Turnover', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                    Text('NPR 4.2B', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Top Gainers', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.trending_up, color: Colors.white)),
            title: const Text('NABIL'),
            trailing: const Text('+4.2%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            tileColor: AppTheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.trending_up, color: Colors.white)),
            title: const Text('NTC'),
            trailing: const Text('+2.1%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            tileColor: AppTheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ],
      ),
    );
  }
}
