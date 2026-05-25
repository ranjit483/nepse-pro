import 'package:flutter/material.dart';
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
        children: const [
          _DashboardTab(),
          _PortfolioTab(),
          _MarketStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewScriptScreen()),
          );
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          // Placeholder for Dashboard widgets
          Expanded(
            child: Center(
              child: Text(
                'Dashboard content will appear here.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
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
    return Center(
      child: Text(
        'Portfolio Management',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MarketStatsTab extends StatelessWidget {
  const _MarketStatsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Market Stats & Insights',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
