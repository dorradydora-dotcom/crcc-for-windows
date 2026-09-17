import 'package:flutter/material.dart';
import 'maarof_models.dart';

/// 📊 صندوق قراءات الخط (Line / Transformer Measurement Block)
class DigitalMeterBox extends StatelessWidget {
  final Measurements measurements;
  final String title;
  final String? cableSpec;
  final Color headerColor;
  final bool isCompact;

  const DigitalMeterBox({
    super.key,
    required this.measurements,
    required this.title,
    this.cableSpec,
    this.headerColor = const Color(0xFF00E676),
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C14),
        border: Border.all(color: Colors.white12, width: 0.8),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // مواصفات الكابل إن وجدت
          if (cableSpec != null && cableSpec!.isNotEmpty)
            Text(
              cableSpec!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 7.5,
                color: Colors.white60,
                fontFamily: 'monospace',
              ),
            ),
          // كارت اسم الخط بالأخضر كما في الإسكادا
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: headerColor.withAlpha(40),
              border: Border.all(color: headerColor, width: 0.8),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color: headerColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // القراءات الرقمية
          _buildRow('MW', measurements.mw),
          _buildRow('MVAR', measurements.mvar),
          _buildRow('MVA', measurements.mva),
          _buildRow('A', measurements.currentA, highlight: true),
          if (measurements.powerFactor != null)
            _buildRow('PF', measurements.powerFactor!),
        ],
      ),
    );
  }

  Widget _buildRow(String unit, double value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: highlight
                    ? const Color(0xFF00E5FF)
                    : (value < 0
                        ? const Color(0xFFFF5252)
                        : const Color(0xFFE0E0E0)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 34,
            child: Text(
              unit,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 8.5,
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 💡 قراءة سريعة لتيار خلية 11kV
class CellCurrentTag extends StatelessWidget {
  final double currentA;
  final double? mvar;

  const CellCurrentTag({
    super.key,
    required this.currentA,
    this.mvar,
  });

  @override
  Widget build(BuildContext context) {
    if (mvar != null && mvar! > 0) {
      return Text(
        '${mvar!.toStringAsFixed(1)} MVAR',
        style: const TextStyle(
          fontSize: 9.5,
          color: Color(0xFF00E676),
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      );
    }

    return Text(
      '${currentA.toStringAsFixed(1)} A',
      style: TextStyle(
        fontSize: 9.5,
        color: currentA > 0 ? const Color(0xFF00E676) : Colors.white38,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }
}
