import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LotCalculatorScreen extends StatefulWidget {
  const LotCalculatorScreen({super.key});
  @override State<LotCalculatorScreen> createState() => _LotCalculatorScreenState();
}

class _LotCalculatorScreenState extends State<LotCalculatorScreen> {
  final _balanceCtrl = TextEditingController(text: '1000');
  final _riskPctCtrl = TextEditingController(text: '1');
  final _pipsCtrl    = TextEditingController();
  final _entryCtrl   = TextEditingController();
  final _slCtrl      = TextEditingController();
  final _tpCtrl      = TextEditingController();
  final _manualPipValueCtrl = TextEditingController();
  bool _manualPipValue = false;

  String _pair = 'EUR/USD';
  bool _priceMode = false;

  // Typical CFD/futures contract sizes per 1.0 lot (varies by broker - shown as a guide).
  static const _commodityContractSize = {
    'XAU/USD': 100.0, 'XAG/USD': 5000.0, 'PLATINUM': 50.0, 'PALLADIUM': 100.0,
    'COPPER': 25000.0, 'WTI OIL': 1000.0, 'BRENT': 1000.0, 'NAT GAS': 10000.0,
  };
  static const _commodityPipSize = {
    'XAU/USD': 0.01, 'XAG/USD': 0.001, 'PLATINUM': 0.01, 'PALLADIUM': 0.01,
    'COPPER': 0.0001, 'WTI OIL': 0.01, 'BRENT': 0.01, 'NAT GAS': 0.001,
  };

  @override
  void dispose() {
    _manualPipValueCtrl.dispose();
    _balanceCtrl.dispose(); _riskPctCtrl.dispose(); _pipsCtrl.dispose();
    _entryCtrl.dispose(); _slCtrl.dispose(); _tpCtrl.dispose();
    super.dispose();
  }

  double _pipSize(String pair, String category, double refPrice) {
    if (category == 'Commodities') return _commodityPipSize[pair] ?? 0.01;
    if (pair.contains('JPY')) return 0.01;
    if (refPrice > 50) return 0.01; // heuristic for low-precision exotic forex pairs
    return 0.0001;
  }

  double? _quoteToUsdRate(String pair, List<dynamic> allPairs) {
    final parts = pair.split('/');
    if (parts.length != 2) return null;
    final quote = parts[1];
    if (quote == 'USD') return 1.0;
    for (final p in allPairs) {
      if (p.pair == '$quote/USD') return p.price as double;
      if (p.pair == 'USD/$quote') { final pr = p.price as double; return pr > 0 ? 1 / pr : null; }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dp = context.watch<DataProvider>();
    final calcPairs = dp.pairs.where((p) => p.category == 'Forex' || p.category == 'Commodities').toList();
    final selected = calcPairs.firstWhere((p) => p.pair == _pair, orElse: () => calcPairs.first);
    final refPrice = selected.price;
    final category = selected.category;

    final balance = double.tryParse(_balanceCtrl.text) ?? 0;
    final riskPct = double.tryParse(_riskPctCtrl.text) ?? 0;
    final riskAmount = balance * riskPct / 100;

    final pipSize = _pipSize(_pair, category, refPrice);
    double? pips;
    if (_priceMode) {
      final entry = double.tryParse(_entryCtrl.text);
      final sl    = double.tryParse(_slCtrl.text);
      if (entry != null && sl != null && entry != sl) {
        pips = (entry - sl).abs() / pipSize;
      }
    } else {
      pips = double.tryParse(_pipsCtrl.text);
    }

    double? pipValuePerStdLot;
    if (category == 'Commodities') {
      final contractSize = _commodityContractSize[_pair] ?? 100.0;
      pipValuePerStdLot = pipSize * contractSize; // already USD-quoted
    } else {
      final quoteRate = _quoteToUsdRate(_pair, dp.pairs);
      if (quoteRate != null) pipValuePerStdLot = pipSize * 100000 * quoteRate;
    }

    double? lots;
    if (_manualPipValue) {
      pipValuePerStdLot = double.tryParse(_manualPipValueCtrl.text);
    }
    if (pips != null && pips > 0 && pipValuePerStdLot != null && pipValuePerStdLot > 0 && riskAmount > 0) {
      lots = riskAmount / (pips * pipValuePerStdLot);
    }

    double? rr;
    if (_priceMode) {
      final entry = double.tryParse(_entryCtrl.text);
      final sl    = double.tryParse(_slCtrl.text);
      final tp    = double.tryParse(_tpCtrl.text);
      if (entry != null && sl != null && tp != null && (entry - sl).abs() > 0) {
        rr = (tp - entry).abs() / (entry - sl).abs();
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(label: 'Risk Management', title: 'Lot', titleAccent: 'Calculator'),
          const SizedBox(height: 16),

          _card(isDark, 'ACCOUNT & RISK', [
            _labeledField('Account Balance (\$)', _balanceCtrl, isDark),
            const SizedBox(height: 12),
            _labeledField('Risk per Trade (%)', _riskPctCtrl, isDark),
            const SizedBox(height: 8),
            Text('Risking \$${riskAmount.toStringAsFixed(2)} on this trade',
                style: TextStyle(fontSize: 11.5, color: AppColors.gold, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),

          _card(isDark, 'INSTRUMENT', [
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: calcPairs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final p = calcPairs[i];
                  final sel = p.pair == _pair;
                  final col = p.category == 'Commodities' ? const Color(0xFFE040FB) : AppColors.cyan;
                  return GestureDetector(
                    onTap: () => setState(() => _pair = p.pair),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? col.withOpacity(0.15) : (isDark ? AppColors.navyCard2 : AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? col : Colors.transparent),
                      ),
                      child: Text(p.pair, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: sel ? col : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('Current price: ${refPrice.toStringAsFixed(refPrice > 50 ? 2 : 4)}  \u2022  $category',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          ]),
          const SizedBox(height: 14),

          _card(isDark, 'PIP VALUE', [
            Row(children: [
              Expanded(child: _modeButton('Auto (Live)', !_manualPipValue, () => setState(() => _manualPipValue = false), isDark)),
              const SizedBox(width: 8),
              Expanded(child: _modeButton('Manual', _manualPipValue, () => setState(() => _manualPipValue = true), isDark)),
            ]),
            if (_manualPipValue) ...[
              const SizedBox(height: 12),
              _labeledField('Pip Value per Standard Lot (\$)', _manualPipValueCtrl, isDark),
              const SizedBox(height: 6),
              Text('No live data needed - enter the pip value your broker quotes.',
                  style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
            ] else ...[
              const SizedBox(height: 8),
              Text(pipValuePerStdLot != null
                  ? 'Live pip value: ${pipValuePerStdLot.toStringAsFixed(2)} per standard lot'
                  : 'Waiting for live price data...',
                  style: TextStyle(fontSize: 11, color: AppColors.cyan, fontWeight: FontWeight.w600)),
            ],
          ]),
          const SizedBox(height: 14),

          _card(isDark, 'STOP LOSS', [
            Row(children: [
              Expanded(child: _modeButton('Pips/Points', !_priceMode, () => setState(() => _priceMode = false), isDark)),
              const SizedBox(width: 8),
              Expanded(child: _modeButton('Entry \u2192 SL Price', _priceMode, () => setState(() => _priceMode = true), isDark)),
            ]),
            const SizedBox(height: 12),
            if (!_priceMode)
              _labeledField('Stop Loss (pips/points)', _pipsCtrl, isDark)
            else ...[
              _labeledField('Entry Price', _entryCtrl, isDark),
              const SizedBox(height: 12),
              _labeledField('Stop Loss Price', _slCtrl, isDark),
              const SizedBox(height: 12),
              _labeledField('Take Profit Price (optional)', _tpCtrl, isDark),
              if (pips != null) ...[
                const SizedBox(height: 8),
                Text('= ${pips.toStringAsFixed(1)} pips/points',
                    style: TextStyle(fontSize: 11.5, color: AppColors.cyan, fontWeight: FontWeight.w700)),
              ],
              if (rr != null) ...[
                const SizedBox(height: 4),
                Text('Risk:Reward = 1:${rr.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11.5, color: AppColors.green, fontWeight: FontWeight.w700)),
              ],
            ],
          ]),
          const SizedBox(height: 18),

          GlowCard(
            glowColor: AppColors.green,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text('RECOMMENDED POSITION SIZE', style: TextStyle(fontSize: 11, letterSpacing: 1.5,
                  fontWeight: FontWeight.w700, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
              const SizedBox(height: 10),
              Text(lots != null ? lots.toStringAsFixed(2) : '--',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900,
                      color: AppColors.green, fontFamily: 'monospace')),
              Text('Standard Lots', style: TextStyle(fontSize: 12,
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
              const SizedBox(height: 16),
              if (lots != null) Row(children: [
                Expanded(child: _resultChip('Mini Lots', (lots * 10).toStringAsFixed(1), AppColors.cyan)),
                const SizedBox(width: 8),
                Expanded(child: _resultChip('Micro Lots', (lots * 100).toStringAsFixed(1), AppColors.gold)),
                const SizedBox(width: 8),
                Expanded(child: _resultChip(category == 'Commodities' ? 'Units/oz' : 'Units', (lots * (category == 'Commodities' ? (_commodityContractSize[_pair] ?? 100.0) : 100000)).round().toString(), AppColors.red)),
              ]),
              if (lots == null) Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Fill in balance, risk % and stop loss to calculate',
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                    textAlign: TextAlign.center),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          GlowCard(padding: const EdgeInsets.all(14), child: Row(children: [
            Icon(Icons.info_outline, size: 16, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
            const SizedBox(width: 8),
            Expanded(child: Text(
                category == 'Commodities'
                    ? 'Commodity contract sizes (oz/lbs per lot) vary by broker. Values shown use common industry defaults - always confirm your broker\'s exact contract specification before trading.'
                    : 'Pip value is derived from live prices in this app. Exotic pairs use an approximation. Always double-check against your broker before placing a trade.',
                style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.mutedDark : AppColors.mutedLight))),
          ])),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _card(bool isDark, String title, List<Widget> children) {
    return GlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700,
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _labeledField(String label, TextEditingController ctrl, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textLight, fontFamily: 'monospace'),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: isDark ? AppColors.navyCard2 : AppColors.lightBorder,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    ]);
  }

  Widget _modeButton(String label, bool selected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan.withOpacity(0.15) : (isDark ? AppColors.navyCard2 : AppColors.lightBorder),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.cyan : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: selected ? AppColors.cyan : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
      ),
    );
  }

  Widget _resultChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace')),
        Text(label, style: TextStyle(fontSize: 9, color: color)),
      ]),
    );
  }
}







