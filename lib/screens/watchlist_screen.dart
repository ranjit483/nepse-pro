import 'package:flutter/material.dart';
import '../theme.dart';
import '../mock_data.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  String _selectedWatchlist = 'Bluechip';
  final List<String> _watchlists = ['Bluechip', 'Speculative', 'Dividend', 'Banks'];
  
  final Map<String, List<String>> _mockWatchlistData = {
    'Bluechip': ['NABIL', 'NICA', 'CIT', 'NTC'],
    'Speculative': ['NGPL', 'HIDCL'],
    'Dividend': ['SHIVM', 'NTC'],
    'Banks': ['GBIME', 'NABIL', 'NICA'],
  };

  @override
  Widget build(BuildContext context) {
    final currentList = _mockWatchlistData[_selectedWatchlist] ?? [];

    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _watchlists.length,
              itemBuilder: (context, index) {
                final name = _watchlists[index];
                final isSelected = name == _selectedWatchlist;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedWatchlist = name;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: currentList.isEmpty
              ? Center(child: Text('Empty Watchlist', style: TextStyle(color: AppTheme.onSurfaceVariant)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentList.length,
                  itemBuilder: (context, index) {
                    final symbol = currentList[index];
                    final liveData = MockData.getLivePrice(symbol);
                    final price = liveData['price'] as double;
                    final change = liveData['change'] as double;
                    final changeRs = liveData['change_rs'] as double;
                    final isPositive = change >= 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppTheme.surfaceContainerLowest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.outlineVariant),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.surfaceContainerHigh,
                          child: Text(symbol.substring(0, 1), style: const TextStyle(color: AppTheme.primary)),
                        ),
                        title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Vol: 12.5K'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Rs. $price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              '${isPositive ? '+' : ''}$changeRs (${isPositive ? '+' : ''}$change%)',
                              style: TextStyle(
                                color: isPositive ? AppTheme.primary : AppTheme.error,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
      ],
    );
  }
}
