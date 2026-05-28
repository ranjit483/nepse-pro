import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

// Constants for exact color matching requested
const Color nepseOrange = Color(0xFFF37021);
const Color charcoalText = Color(0xFF333333);
const Color lightGrayBg = Color(0xFFF9F9F9);
const Color clearGray = Color(0xFF7F8C8D);

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: lightGrayBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('NEPSE Investor Toolkit', style: TextStyle(color: charcoalText, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: nepseOrange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: nepseOrange,
            indicatorWeight: 3,
            labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
            tabs: [
              Tab(text: 'Share'),
              Tab(text: 'Bonus Adjust'),
              Tab(text: 'Dividend'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ShareCalculatorTab(),
            _BonusAdjustmentTab(),
            _DividendCalculatorTab(),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// WIDGETS
// ----------------------------------------------------------------------

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? bgColor;
  final Color? textColor;

  const _ResultRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor ?? charcoalText,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor ?? charcoalText,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDivider() {
  return Container(height: 1, color: const Color(0xFFDDDDDD));
}

Widget _buildInputField(String label, TextEditingController controller, {bool enabled = true, String placeholder = "Numbers Only"}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: charcoalText, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade200,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: nepseOrange),
            ),
          ),
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------------------
// TAB 1: SHARE CALCULATOR
// ----------------------------------------------------------------------

class _ShareCalculatorTab extends StatefulWidget {
  const _ShareCalculatorTab();

  @override
  State<_ShareCalculatorTab> createState() => _ShareCalculatorTabState();
}

class _ShareCalculatorTabState extends State<_ShareCalculatorTab> {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController(text: 'Buy');

  double _totalAmount = 0.0;
  double _brokerCommission = 0.0;
  double _sebonFee = 0.0;
  double _dpCharge = 0.0;
  double _totalPayable = 0.0;
  double _costPerShare = 0.0;
  bool _calculated = false;

  void _calculate() {
    FocusScope.of(context).unfocus();
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (qty > 0 && price > 0) {
      _totalAmount = qty * price;
      
      // Tiered Broker Commission
      double comm = 0.0;
      if (_totalAmount <= 50000) comm = _totalAmount * 0.0036;
      else if (_totalAmount <= 500000) comm = _totalAmount * 0.0033;
      else if (_totalAmount <= 2000000) comm = _totalAmount * 0.0031;
      else if (_totalAmount <= 10000000) comm = _totalAmount * 0.0027;
      else comm = _totalAmount * 0.0024;
      
      _brokerCommission = comm < 10.0 ? 10.0 : comm;
      _sebonFee = _totalAmount * 0.00015;
      _dpCharge = 25.0;
      
      _totalPayable = _totalAmount + _brokerCommission + _sebonFee + _dpCharge;
      _costPerShare = _totalPayable / qty;
      
      setState(() {
        _calculated = true;
      });
    }
  }

  void _clear() {
    _qtyController.clear();
    _priceController.clear();
    setState(() {
      _calculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField("Transaction Type", _typeController, enabled: false),
          _buildInputField("Share Quantity", _qtyController),
          _buildInputField("Purchase Price (Rs)", _priceController),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: clearGray, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _clear,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: nepseOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _ResultRow(label: "Total Amount", value: _calculated ? "Rs. ${fmt.format(_totalAmount)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "* Broker Commission", value: _calculated ? "Rs. ${fmt.format(_brokerCommission)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "SEBON Fee", value: _calculated ? "Rs. ${fmt.format(_sebonFee)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "DP Charge", value: _calculated ? "Rs. ${fmt.format(_dpCharge)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "Total Amount Payable (Rs)", value: _calculated ? "Rs. ${fmt.format(_totalPayable)}" : "-", isBold: true),
                _buildDivider(),
                _ResultRow(label: "Cost Price Per Share (Rs)", value: _calculated ? "Rs. ${fmt.format(_costPerShare)}" : "-", isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "* Commission Amount includes NEPSE Commission & SEBON Regularity Fee",
            style: TextStyle(color: Color(0xFFD35400), fontSize: 12),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// TAB 2: BONUS ADJUSTMENT
// ----------------------------------------------------------------------

class _BonusAdjustmentTab extends StatefulWidget {
  const _BonusAdjustmentTab();

  @override
  State<_BonusAdjustmentTab> createState() => _BonusAdjustmentTabState();
}

class _BonusAdjustmentTabState extends State<_BonusAdjustmentTab> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();

  double _marketPrice = 0.0;
  double _bonusPct = 0.0;
  double _adjustedPrice = 0.0;
  bool _calculated = false;

  void _calculate() {
    FocusScope.of(context).unfocus();
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final bonus = double.tryParse(_bonusController.text) ?? 0.0;

    if (price > 0 && bonus > 0) {
      _marketPrice = price;
      _bonusPct = bonus;
      _adjustedPrice = price / (1 + (bonus / 100));
      
      setState(() {
        _calculated = true;
      });
    }
  }

  void _clear() {
    _priceController.clear();
    _bonusController.clear();
    setState(() {
      _calculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField("Market Price (Before Book Closure)", _priceController),
          _buildInputField("% of Bonus Share", _bonusController),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: clearGray, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _clear,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: nepseOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _ResultRow(label: "Market Price (Before Book Closure)", value: _calculated ? "Rs. ${fmt.format(_marketPrice)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "% of Bonus Share", value: _calculated ? "${fmt.format(_bonusPct)} %" : "-"),
                _buildDivider(),
                _ResultRow(
                  label: "Market Price after Right Adjustment", 
                  value: _calculated ? "Rs. ${fmt.format(_adjustedPrice)}" : "-", 
                  isBold: true,
                  bgColor: _calculated ? const Color(0xFFFDF2E9) : null,
                  textColor: _calculated ? const Color(0xFFD35400) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// TAB 3: DIVIDEND CALCULATOR
// ----------------------------------------------------------------------

class _DividendCalculatorTab extends StatefulWidget {
  const _DividendCalculatorTab();

  @override
  State<_DividendCalculatorTab> createState() => _DividendCalculatorTabState();
}

class _DividendCalculatorTabState extends State<_DividendCalculatorTab> {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _bonusPctController = TextEditingController();
  final TextEditingController _cashPctController = TextEditingController();
  final TextEditingController _paidUpController = TextEditingController(text: '100');

  double _cashAmount = 0.0;
  double _bonusTax = 0.0;
  double _cashTax = 0.0;
  double _totalTax = 0.0;
  double _receivableBonus = 0.0;
  bool _calculated = false;

  void _calculate() {
    FocusScope.of(context).unfocus();
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final bonusPct = double.tryParse(_bonusPctController.text) ?? 0.0;
    final cashPct = double.tryParse(_cashPctController.text) ?? 0.0;

    if (qty > 0) {
      final faceValue = qty * 100.0;
      _cashAmount = faceValue * (cashPct / 100);
      _bonusTax = faceValue * (bonusPct / 100) * 0.05;
      _cashTax = _cashAmount * 0.05;
      _totalTax = _bonusTax + _cashTax;
      _receivableBonus = qty * (bonusPct / 100);
      
      setState(() {
        _calculated = true;
      });
    }
  }

  void _clear() {
    _qtyController.clear();
    _bonusPctController.clear();
    _cashPctController.clear();
    setState(() {
      _calculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField("Share Quantity", _qtyController),
          _buildInputField("% of Bonus Dividend", _bonusPctController),
          _buildInputField("% of Cash Dividend", _cashPctController),
          _buildInputField("Paid-up Value per Share", _paidUpController, enabled: false),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: clearGray, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _clear,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: nepseOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _ResultRow(label: "Cash Amount", value: _calculated ? "Rs. ${fmt.format(_cashAmount)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "Bonus Share Tax (5%)", value: _calculated ? "Rs. ${fmt.format(_bonusTax)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "Cash Amount Tax (5%)", value: _calculated ? "Rs. ${fmt.format(_cashTax)}" : "-"),
                _buildDivider(),
                _ResultRow(label: "Total Payable Tax", value: _calculated ? "Rs. ${fmt.format(_totalTax)}" : "-", isBold: true),
                _buildDivider(),
                _ResultRow(label: "Receivable Bonus Quantity", value: _calculated ? fmt.format(_receivableBonus) : "-", isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
