class MockData {
  static final Map<String, Map<String, dynamic>> livePrices = {
    'NABIL': {'price': 615.50, 'change': 1.2, 'change_rs': 7.30},
    'NICA': {'price': 745.00, 'change': -0.8, 'change_rs': -6.00},
    'SHIVM': {'price': 420.00, 'change': 2.5, 'change_rs': 10.25},
    'GBIME': {'price': 185.50, 'change': 0.5, 'change_rs': 0.90},
    'NGPL': {'price': 450.00, 'change': 3.1, 'change_rs': 13.50},
    'CIT': {'price': 2100.00, 'change': -1.2, 'change_rs': -25.20},
    'HIDCL': {'price': 205.00, 'change': 0.0, 'change_rs': 0.00},
    'NTC': {'price': 890.00, 'change': 1.5, 'change_rs': 13.15},
  };

  static Map<String, dynamic> getLivePrice(String symbol) {
    if (livePrices.containsKey(symbol)) {
      return livePrices[symbol]!;
    }
    // Default fallback mock price
    return {'price': 500.00, 'change': 0.0, 'change_rs': 0.00};
  }
}
