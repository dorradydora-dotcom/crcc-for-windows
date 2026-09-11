import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'maarof_models.dart';

/// 🔲 رمز قاطع الدائرة (Circuit Breaker CB)
class BreakerSymbol extends StatelessWidget {
  final SwitchState state;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;
  final bool showLabel;
  final String? label;

  const BreakerSymbol({
    super.key,
    required this.state,
    this.onTap,
    this.onLongPress,
    this.size = 20.0,
    this.showLabel = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color boxColor;
    Color borderColor;
    bool isFilled;

    switch (state) {
      case SwitchState.closed:
        boxColor = const Color(0xFFFF2222); // أحمر ممتلئ - موصل (closed)
        borderColor = const Color(0xFFFF5555);
        isFilled = true;
        break;
      case SwitchState.open:
        boxColor = const Color(0xFF00E676); // أخضر ممتلئ - مفصول (open)
        borderColor = const Color(0xFF69F0AE);
        isFilled = true;
        break;
      case SwitchState.trip:
        boxColor = const Color(0xFFFFD600); // أصفر للتريب
        borderColor = Colors.white;
        isFilled = true;
        break;
      case SwitchState.unknown:
        boxColor = Colors.grey.shade700;
        borderColor = Colors.grey;
        isFilled = true;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isFilled ? boxColor : const Color(0xFF090B12),
                  border: Border.all(color: borderColor, width: 2.0),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: boxColor.withAlpha(140),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
              ),
              if (showLabel && label != null) ...[
                const SizedBox(height: 2),
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// ⚡ رمز سكينة العزل القياسية (Disconnector Switch DS)
class DisconnectorSymbol extends StatelessWidget {
  final SwitchState state;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;
  final bool isHorizontal;

  const DisconnectorSymbol({
    super.key,
    required this.state,
    this.onTap,
    this.onLongPress,
    this.size = 20.0,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = state == SwitchState.closed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CustomPaint(
            size: Size(isHorizontal ? size * 1.2 : size,
                isHorizontal ? size : size * 1.2),
            painter: _DisconnectorPainter(
              isClosed: isClosed,
              isHorizontal: isHorizontal,
            ),
          ),
        ),
      ),
    );
  }
}

class _DisconnectorPainter extends CustomPainter {
  final bool isClosed;
  final bool isHorizontal;

  _DisconnectorPainter({
    required this.isClosed,
    required this.isHorizontal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // لون السكينة: أحمر للموصل، وأخضر للمفصول
    final switchColor =
        isClosed ? const Color(0xFFFF2222) : const Color(0xFF00E676);

    final linePaint = Paint()
      ..color = switchColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;

    final terminalPaint = Paint()
      ..color = switchColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    if (!isHorizontal) {
      final cx = size.width / 2;
      final topY = 2.5;
      final botY = size.height - 2.5;

      // أطراف السكينة العلوية والسفلية (Terminal stops)
      canvas.drawLine(
          Offset(cx - 3.2, topY), Offset(cx + 3.2, topY), terminalPaint);
      canvas.drawLine(
          Offset(cx - 3.2, botY), Offset(cx + 3.2, botY), terminalPaint);

      // العلامة الرأسية الجانبية
      canvas.drawLine(
          Offset(cx + 4.5, topY + 1.0), Offset(cx + 4.5, botY - 1.0), terminalPaint);

      if (isClosed) {
        // خط مستقيم يربط الطرفين (أحمر موصل)
        canvas.drawLine(Offset(cx, topY), Offset(cx, botY), linePaint);
      } else {
        // ريشة مفتوحة لليمين بزاوية قائمة ونهاية عمودية (أخضر مفصول)
        final bladeLength = (botY - topY) * 0.75;
        final bladeEnd =
            Offset(cx + bladeLength * 0.7, botY - bladeLength * 0.7);
        // ذراع الريشة
        canvas.drawLine(Offset(cx, botY), bladeEnd, linePaint);
        // شفة نهاية الريشة المتعامدة
        canvas.drawLine(
          Offset(bladeEnd.dx, bladeEnd.dy - 2.5),
          Offset(bladeEnd.dx, bladeEnd.dy + 2.5),
          terminalPaint,
        );
      }
    } else {
      final cy = size.height / 2;
      final leftX = 2.5;
      final rightX = size.width - 2.5;

      canvas.drawLine(
          Offset(leftX, cy - 3.2), Offset(leftX, cy + 3.2), terminalPaint);
      canvas.drawLine(
          Offset(rightX, cy - 3.2), Offset(rightX, cy + 3.2), terminalPaint);

      // العلامة الأفقية الجانبية
      canvas.drawLine(
          Offset(leftX + 1.0, cy + 4.5), Offset(rightX - 1.0, cy + 4.5), terminalPaint);

      if (isClosed) {
        // خط مستقيم يربط الطرفين (أحمر موصل)
        canvas.drawLine(Offset(leftX, cy), Offset(rightX, cy), linePaint);
      } else {
        // ريشة مفتوحة (أخضر مفصول)
        final bladeLength = (rightX - leftX) * 0.75;
        final bladeEnd =
            Offset(leftX + bladeLength * 0.7, cy - bladeLength * 0.7);
        canvas.drawLine(Offset(leftX, cy), bladeEnd, linePaint);
        canvas.drawLine(
          Offset(bladeEnd.dx - 2.5, bladeEnd.dy),
          Offset(bladeEnd.dx + 2.5, bladeEnd.dy),
          terminalPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DisconnectorPainter oldDelegate) =>
      oldDelegate.isClosed != isClosed ||
      oldDelegate.isHorizontal != isHorizontal;
}

/// 🔀 رمز سكينة الـ TIE الأفقية على البارة (Horizontal Bus Tie Switch)
class TieSwitchSymbol extends StatelessWidget {
  final SwitchState state;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double height;
  final bool showLabel;
  final String? label;

  const TieSwitchSymbol({
    super.key,
    required this.state,
    this.onTap,
    this.onLongPress,
    this.width = 38.0,
    this.height = 20.0,
    this.showLabel = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = state == SwitchState.closed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: _DisconnectorPainter(
                  isClosed: isClosed,
                  isHorizontal: true,
                ),
              ),
              if (showLabel && label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 7.5,
                    color: isClosed
                        ? const Color(0xFFFF2222)
                        : const Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ⏚ ويدجت تفريعة سكينة التأريض الجانبية (Earth Switch Branch Widget)
class EarthBranchWidget extends StatelessWidget {
  final SwitchState state;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double height;
  final bool isLeft;

  const EarthBranchWidget({
    super.key,
    required this.state,
    this.onTap,
    this.onLongPress,
    this.width = 28.0,
    this.height = 18.0,
    this.isLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = state == SwitchState.closed;
    // أحمر موصل بالأرضي، وأخضر مفصول
    final color = isClosed ? const Color(0xFFFF2222) : const Color(0xFF00E676);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
          child: CustomPaint(
            size: Size(width, height),
            painter: _EarthBranchPainter(
              isClosed: isClosed,
              color: color,
              isLeft: isLeft,
            ),
          ),
        ),
      ),
    );
  }
}

class _EarthBranchPainter extends CustomPainter {
  final bool isClosed;
  final Color color;
  final bool isLeft;

  _EarthBranchPainter({
    required this.isClosed,
    required this.color,
    this.isLeft = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cy = size.height / 2;

    if (isLeft) {
      // تفريعة لليسار: الخط الرئيسي على اليمين والتأريض على اليسار
      final rightX = size.width - 1.0;
      final hingeX = size.width - 6.0;
      final contactX = 10.0;
      final groundX = 6.0;

      // نقطة البداية على الخط الرئيسي
      canvas.drawCircle(Offset(rightX, cy), 1.6, dotPaint);
      canvas.drawLine(Offset(rightX, cy), Offset(hingeX, cy), paint);

      // مفصل السكينة
      canvas.drawCircle(Offset(hingeX, cy), 1.8, dotPaint);

      // نقطة التماس الأرضي
      canvas.drawCircle(Offset(contactX, cy), 1.8, dotPaint);

      if (isClosed) {
        // موصل بالأرضي أفقياً
        canvas.drawLine(Offset(hingeX, cy), Offset(contactX, cy), paint);
      } else {
        // مفتوح مائل للأعلى لليسار مثل صورة الإسكادا
        canvas.drawLine(Offset(hingeX, cy), Offset(contactX + 3, 2), paint);
      }

      // خط واصل لرمز الأرضي
      canvas.drawLine(Offset(contactX, cy), Offset(groundX, cy), paint);

      // رمز الأرضي ⏚ (3 خطوط أفقية متدرجة رأسياً على اليسار)
      canvas.drawLine(
          Offset(groundX, cy - 4.5), Offset(groundX, cy + 4.5), paint);
      canvas.drawLine(
          Offset(groundX - 2.2, cy - 2.8), Offset(groundX - 2.2, cy + 2.8), paint);
      canvas.drawLine(
          Offset(groundX - 4.4, cy - 1.4), Offset(groundX - 4.4, cy + 1.4), paint);
    } else {
      // نقطة البداية على الخط الرئيسي جهة اليسار
      canvas.drawCircle(Offset(1, cy), 1.8, dotPaint);
      canvas.drawLine(Offset(1, cy), Offset(5, cy), paint);

      // مفصل السكينة
      canvas.drawCircle(Offset(5, cy), 2.0, dotPaint);

      // نقطة التماس الأرضي
      final contactX = size.width - 9;
      canvas.drawCircle(Offset(contactX, cy), 2.0, dotPaint);

      if (isClosed) {
        // موصل بالأرضي أفقياً
        canvas.drawLine(Offset(5, cy), Offset(contactX, cy), paint);
      } else {
        // مفتوح مائل للأعلى
        canvas.drawLine(Offset(5, cy), Offset(contactX - 2, 2), paint);
      }

      // خط واصل لرمز الأرضي
      final groundX = size.width - 5;
      canvas.drawLine(Offset(contactX, cy), Offset(groundX, cy), paint);

      // رمز الأرضي ⏚ (3 خطوط أفقية متدرجة رأسياً)
      final gx = groundX;
      canvas.drawLine(Offset(gx, cy - 4.5), Offset(gx, cy + 4.5), paint);
      canvas.drawLine(
          Offset(gx + 2.2, cy - 2.8), Offset(gx + 2.2, cy + 2.8), paint);
      canvas.drawLine(
          Offset(gx + 4.4, cy - 1.4), Offset(gx + 4.4, cy + 1.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EarthBranchPainter oldDelegate) =>
      oldDelegate.isClosed != isClosed ||
      oldDelegate.color != color ||
      oldDelegate.isLeft != isLeft;
}

/// ▲ سهم خط الخروج/الدخول العلوي الأبيض
class LineArrowSymbol extends StatelessWidget {
  final double size;
  const LineArrowSymbol({super.key, this.size = 8.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.1),
      painter: _LineArrowPainter(),
    );
  }
}

class _LineArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ⏚ رمز سكينة التأريض الفردي
class EarthSwitchSymbol extends StatelessWidget {
  final SwitchState state;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;

  const EarthSwitchSymbol({
    super.key,
    required this.state,
    this.onTap,
    this.onLongPress,
    this.size = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return EarthBranchWidget(
      state: state,
      onTap: onTap,
      onLongPress: onLongPress,
      width: size * 1.3,
      height: size,
    );
  }
}

/// 🔄 ويدجت خلية المحول المتكاملة (Complete Transformer Bay Widget)
/// - أذرع ممتدة طويلة ومتباعدة عن أي عناصر أخرى لمنع أي تداخل
/// - متصلة بشكل مباشر ومستمر بالبارات العلوية 66kV (BB1 & BB2) والبارات السفلية 11kV
/// - سكاكين الدخل المزدوجة تمتد حتى تلمس البارات تماماً بأذرع طويلة واضحة
/// - خط الخرج السفلي يهبط حتى يلمس قضيب الـ 11kV مباشرة
/// - قاطع الدخل 66kV مع قراءات (MW, MVAR, MVA, A, PF) بالألوان الأصلية
/// - رمزي الدائرتين المتداخلتين باللون الأبيض مع المعين البرتقالي وبيانات TAP و MACO
/// - تفريعة التأريض النيوترال NGR باللون البني والرموز السماوية
class TransformerBayWidget extends StatelessWidget {
  final TransformerModel transformer;
  final SwitchState priCbState;
  final SwitchState secCbState;
  final SwitchState busDsAState;
  final SwitchState busDsBState;
  final SwitchState ngrDsState;
  final SwitchState ngrEsState;
  final String busKv;
  final VoidCallback onPriCbTap;
  final VoidCallback onSecCbTap;
  final VoidCallback onBusDsATap;
  final VoidCallback onBusDsBTap;
  final VoidCallback onNgrDsTap;
  final VoidCallback onNgrEsTap;

  const TransformerBayWidget({
    super.key,
    required this.transformer,
    required this.priCbState,
    required this.secCbState,
    required this.busDsAState,
    required this.busDsBState,
    required this.ngrDsState,
    required this.ngrEsState,
    required this.busKv,
    required this.onPriCbTap,
    required this.onSecCbTap,
    required this.onBusDsATap,
    required this.onBusDsBTap,
    required this.onNgrDsTap,
    required this.onNgrEsTap,
  });

  @override
  Widget build(BuildContext context) {
    final m = transformer.primaryMeasurements;
    final arabicName = transformer.id == 'TR1'
        ? 'محول 1'
        : transformer.id == 'TR2'
            ? 'محول 2'
            : transformer.id == 'TR3'
                ? 'محول 3'
                : 'محول 4';

    const double centerX = 75.0;

    return SizedBox(
      width: 150,
      height: 290,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // =========================================================
          // 1. تفريعة السكاكين المزدوجة بأذرع ممتدة وطويلة ومتباعدة
          // =========================================================
          // أ. الذراع الأيسر المتصل بـ BB1 (Y=0 يلمس البارة الأولى تماماً)
          Positioned(
            left: 40,
            top: 0,
            width: 2.2,
            height: 16,
            child: Container(color: Colors.white),
          ),
          Positioned(
            left: 31,
            top: 14,
            child: DisconnectorSymbol(
              state: busDsAState,
              size: 15,
              onTap: onBusDsATap,
            ),
          ),
          Positioned(
            left: 40,
            top: 34,
            width: 2.2,
            height: 32,
            child: Container(color: Colors.white),
          ),

          // ب. الذراع الأيمن المتصل بـ BB2 (Y=42 يلمس البارة الثانية تماماً)
          Positioned(
            left: 110,
            top: 42,
            width: 2.2,
            height: 10,
            child: Container(color: Colors.white),
          ),
          Positioned(
            left: 101,
            top: 24,
            child: DisconnectorSymbol(
              state: busDsBState,
              size: 15,
              onTap: onBusDsBTap,
            ),
          ),
          Positioned(
            left: 110,
            top: 44,
            width: 2.2,
            height: 22,
            child: Container(color: Colors.white),
          ),

          // ج. الجسر الأفقي الجامع للذراعين
          Positioned(
            left: 40,
            top: 65,
            width: 72,
            height: 2.2,
            child: Container(color: Colors.white),
          ),

          // خط نازل من الجسر للقاطع
          Positioned(
            left: centerX - 1.1,
            top: 65,
            width: 2.2,
            height: 10,
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 2. قاطع الدخل 66kV (Primary Circuit Breaker)
          // =========================================================
          Positioned(
            left: centerX - 8.5,
            top: 74,
            child: BreakerSymbol(
              state: priCbState,
              size: 17,
              onTap: onPriCbTap,
            ),
          ),

          // =========================================================
          // 3. خط التوصيل الرأسي مع بلوك القياسات بجانبه
          // =========================================================
          Positioned(
            left: centerX - 1.1,
            top: 92,
            width: 2.2,
            height: 72,
            child: Container(color: Colors.white),
          ),
          Positioned(
            left: centerX + 8,
            top: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMeasurementRow(
                  value: m.mw.toStringAsFixed(1),
                  unit: 'MW',
                  valColor: const Color(0xFF00E5FF),
                ),
                _buildMeasurementRow(
                  value: m.mvar.toStringAsFixed(1),
                  unit: 'MVAR',
                  valColor: const Color(0xFFFFA726),
                ),
                _buildMeasurementRow(
                  value: m.mva.toStringAsFixed(1),
                  unit: 'MVA',
                  valColor: const Color(0xFFFFA726),
                ),
                _buildMeasurementRow(
                  value: m.currentA.toStringAsFixed(0),
                  unit: 'A',
                  valColor: const Color(0xFFFFA726),
                ),
                _buildMeasurementRow(
                  value: (m.powerFactor ?? 1.0).toStringAsFixed(2),
                  unit: 'PF',
                  valColor: const Color(0xFF78909C),
                ),
              ],
            ),
          ),

          // =========================================================
          // 4. جسم المحول: الاسم + الدائرتين + المعين + TAP & MACO + NGR
          // =========================================================
          // أ. اسم المحول يسار (محول 2 / TR2)
          Positioned(
            left: 8,
            top: 156,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  arabicName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transformer.name,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ب. رسمة الدائرتين البيضاوين + المعين + تفريعة NGR
          Positioned.fill(
            child: CustomPaint(
              painter: _TransformerBodyPainter(),
            ),
          ),

          // ج. سكاكين تفريعة NGR التفاعلية
          Positioned(
            left: 14,
            top: 190,
            child: DisconnectorSymbol(
              state: ngrDsState,
              size: 13,
              onTap: onNgrDsTap,
            ),
          ),
          Positioned(
            left: 14,
            top: 208,
            child: DisconnectorSymbol(
              state: ngrEsState,
              size: 13,
              onTap: onNgrEsTap,
            ),
          ),

          // د. بيانات المحول يمين (19 TAP, MACO, 66/11 KV, 25 MVA)
          Positioned(
            left: centerX + 18,
            top: 168,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${transformer.tapPosition} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'TAP',
                      style: TextStyle(
                        color: Color(0xFFFFA726),
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  transformer.manufacturer.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  '66/11 KV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  '25 MVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // 5. قاطع الخرج 11kV (Secondary Circuit Breaker)
          // =========================================================
          Positioned(
            left: centerX - 8.5,
            top: 236,
            child: BreakerSymbol(
              state: secCbState,
              size: 17,
              onTap: onSecCbTap,
            ),
          ),

          // =========================================================
          // 6. خط الخرج الهابط المتصل مباشرة بقضيب الـ 11kV
          // =========================================================
          Positioned(
            left: centerX - 1.1,
            top: 254,
            width: 2.2,
            height: 36,
            child: Container(color: Colors.white),
          ),

          // بيان البارة السفلية فوق نقطة الاتصال بالبارة
          Positioned(
            left: 8,
            bottom: 6,
            child: Text(
              transformer.id == 'TR2'
                  ? 'BB 2'
                  : transformer.id == 'TR3'
                      ? 'BB 3'
                      : 'BB 4',
              style: const TextStyle(
                color: Color(0xFFFFA726),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  busKv,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 2),
                const Text(
                  'KV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow({
    required String value,
    required String unit,
    required Color valColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valColor,
                fontSize: 9.0,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransformerBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const centerX = 75.0;

    final whiteLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;

    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // خط واصل علوي وسفلي للملفات
    canvas.drawLine(const Offset(centerX, 164), const Offset(centerX, 175), whiteLinePaint);
    canvas.drawLine(const Offset(centerX, 207), const Offset(centerX, 236), whiteLinePaint);

    // دائرتان متداخلتان باللون الأبيض
    const radius = 12.5;
    const topCenter = Offset(centerX, 187);
    const botCenter = Offset(centerX, 202);

    canvas.drawCircle(topCenter, radius, circlePaint);
    canvas.drawCircle(botCenter, radius, circlePaint);

    // المعين البرتقالي عند التقاطع الأيمن ◇
    const diamondCenter = Offset(centerX + 12.5, 194.5);
    final diamondPath = Path()
      ..moveTo(diamondCenter.dx, diamondCenter.dy - 3.0)
      ..lineTo(diamondCenter.dx + 3.0, diamondCenter.dy)
      ..lineTo(diamondCenter.dx, diamondCenter.dy + 3.0)
      ..lineTo(diamondCenter.dx - 3.0, diamondCenter.dy)
      ..close();

    final diamondPaint = Paint()
      ..color = const Color(0xFFFFA726)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(diamondPath, diamondPaint);

    // تفريعة التأريض النيوترال (NGR Neutral Grounding Branch) جهة اليسار
    final amberPaint = Paint()
      ..color = const Color(0xFFC67D0A)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    const ngrX = 21.0;
    // خط أفقي خارج من الدائرة السفلية إلى خط النيوترال
    canvas.drawLine(const Offset(centerX - radius, 202), const Offset(ngrX, 202), amberPaint);
    // خط رأسي هابط
    canvas.drawLine(const Offset(ngrX, 202), const Offset(ngrX, 222), amberPaint);
    // خط أفقي خارج لليسار
    canvas.drawLine(const Offset(ngrX, 208), const Offset(0, 208), amberPaint);

    // رمز مقاومة التأريض النيوترال NGR (Cyan Zig-zag Resistor)
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final ngrPath = Path()
      ..moveTo(ngrX, 222)
      ..lineTo(ngrX - 3.0, 224.5)
      ..lineTo(ngrX + 3.0, 227.0)
      ..lineTo(ngrX - 3.0, 229.5)
      ..lineTo(ngrX, 232);
    canvas.drawPath(ngrPath, cyanPaint);

    // رمز الأرضي ⏚ بالسماوي (3 خطوط أفقية متدرجة)
    canvas.drawLine(const Offset(ngrX, 232), const Offset(ngrX, 235), cyanPaint);
    canvas.drawLine(const Offset(ngrX - 6, 235), const Offset(ngrX + 6, 235), cyanPaint);
    canvas.drawLine(const Offset(ngrX - 4, 238), const Offset(ngrX + 4, 238), cyanPaint);
    canvas.drawLine(const Offset(ngrX - 2, 241), const Offset(ngrX + 2, 241), cyanPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ⚡ ويدجت خلية خط الـ 66kV المتكاملة (Complete 66kV Line Bay Widget)
/// - مطابقة 100% لمخطط الـ SCADA الفعلي المرسل من المستخدم
/// - اسم الخط العربي بالأبيض وكود الخط بالسماوي #00E5FF
/// - سهم الخروج/الدخول العلوي الأبيض ▲
/// - سكينة التأريض ES على اليسار بالسماوي #00E5FF ورمز الأرضي ⏚
/// - سكينة الخط LINE_DS بالبرتقالي #FFA726 مع العلامة الجانبية
/// - قاطع الدائرة CB مربع سماوي مصمت #00E5FF
/// - تفريعة السكاكين المزدوجة للبارتين:
///   * الذراع الأيمن: سكينة بارة 1 (DS_BUS_A) وخط واصل لبارة BB1
///   * الذراع الأيسر: سكينة بارة 2 (DS_BUS_B) وخط ممتد لأسفل واصل لبارة BB2
class Line66kVBayWidget extends StatelessWidget {
  final FeederBay line;
  final SwitchState cbState;
  final SwitchState lineDsState;
  final SwitchState earthDsState;
  final SwitchState busDsAState;
  final SwitchState busDsBState;
  final VoidCallback onCbTap;
  final VoidCallback onLineDsTap;
  final VoidCallback onEarthDsTap;
  final VoidCallback onBusDsATap;
  final VoidCallback onBusDsBTap;
  final double bb1Y;
  final double bb2Y;

  const Line66kVBayWidget({
    super.key,
    required this.line,
    required this.cbState,
    required this.lineDsState,
    required this.earthDsState,
    required this.busDsAState,
    required this.busDsBState,
    required this.onCbTap,
    required this.onLineDsTap,
    required this.onEarthDsTap,
    required this.onBusDsATap,
    required this.onBusDsBTap,
    this.bb1Y = 156.0,
    this.bb2Y = 198.0,
  });

  @override
  Widget build(BuildContext context) {
    final arabicName = _getArabicName(line.id);
    final scadaTag = _getScadaTag(line.id, line.code);

    const double centerX = 59.0;
    const double leftArmX = 38.0;
    const double rightArmX = 80.0;
    const double bridgeY = 114.0;
    const double busDsY = 120.0;
    const double busDsBottomY = 138.0;

    return SizedBox(
      width: 118,
      height: bb2Y + 4,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. النصوص العلوية (الاسم العربي بالأبيض وكود الاسكادا بالسماوي)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  arabicName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  scadaTag,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 8.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 2. سهم الخروج العلوي الأبيض ▲
          const Positioned(
            top: 29,
            left: centerX - 4,
            child: LineArrowSymbol(size: 8),
          ),

          // 3. الخط الرأسي العلوي من السهم إلى سكينة الخط
          Positioned(
            top: 38,
            left: centerX - 1.1,
            width: 2.2,
            height: 24,
            child: Container(color: Colors.white),
          ),

          // 4. سكينة التأريض ES على اليسار مع رمز التأريض السماوي
          Positioned(
            top: 40,
            left: centerX - 28,
            child: EarthBranchWidget(
              state: earthDsState,
              isLeft: true,
              width: 28,
              height: 18,
              onTap: onEarthDsTap,
            ),
          ),

          // 5. سكينة الخط الرأسية LINE_DS (برتقالي)
          Positioned(
            top: 60,
            left: centerX - 10,
            child: DisconnectorSymbol(
              state: lineDsState,
              size: 16,
              onTap: onLineDsTap,
            ),
          ),

          // 6. الخط الرأسي الواصل بين سكينة الخط والقاطع
          Positioned(
            top: 78,
            left: centerX - 1.1,
            width: 2.2,
            height: 10,
            child: Container(color: Colors.white),
          ),

          // 7. قاطع الدائرة الرئيسي CB (مربع سماوي مصمت #00E5FF)
          Positioned(
            top: 86,
            left: centerX - 9,
            child: BreakerSymbol(
              state: cbState,
              size: 16,
              onTap: onCbTap,
            ),
          ),

          // 8. الخط الرأسي الهابط من القاطع إلى جسر السكاكين
          Positioned(
            top: 104,
            left: centerX - 1.1,
            width: 2.2,
            height: 11,
            child: Container(color: Colors.white),
          ),

          // 9. جسر التفرع الأفقي الأبيض
          Positioned(
            top: bridgeY,
            left: leftArmX,
            width: rightArmX - leftArmX + 2.2,
            height: 2.2,
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 10. تفريعة السكاكين المزدوجة للبارتين
          // =========================================================
          // أ. الفرع الأيمن (سكينة بارة 1 - DS_BUS_A واصلة لـ BB1)
          Positioned(
            top: bridgeY,
            left: rightArmX - 1.1,
            width: 2.2,
            height: busDsY - bridgeY,
            child: Container(color: Colors.white),
          ),
          Positioned(
            top: busDsY,
            left: rightArmX - 10,
            child: DisconnectorSymbol(
              state: busDsAState,
              size: 15,
              onTap: onBusDsATap,
            ),
          ),
          Positioned(
            top: busDsBottomY,
            left: rightArmX - 1.1,
            width: 2.2,
            height: bb1Y - busDsBottomY,
            child: Container(color: Colors.white),
          ),

          // ب. الفرع الأيسر (سكينة بارة 2 - DS_BUS_B واصلة لـ BB2)
          Positioned(
            top: bridgeY,
            left: leftArmX - 1.1,
            width: 2.2,
            height: busDsY - bridgeY,
            child: Container(color: Colors.white),
          ),
          Positioned(
            top: busDsY,
            left: leftArmX - 10,
            child: DisconnectorSymbol(
              state: busDsBState,
              size: 15,
              onTap: onBusDsBTap,
            ),
          ),
          Positioned(
            top: busDsBottomY,
            left: leftArmX - 1.1,
            width: 2.2,
            height: bb2Y - busDsBottomY,
            child: Container(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getArabicName(String id) {
    switch (id) {
      case 'AZBAKIA':
        return 'أزبكية';
      case 'SAYEDA1':
        return 'السيدة ١';
      case 'NSABT3':
        return 'ن السبتية ٣';
      case 'NSABT1':
        return 'ن السبتية ١';
      case 'NSABT2':
        return 'ن السبتية ٢';
      case 'SAYEDA2':
        return 'السيدة ٢';
      default:
        return id;
    }
  }

  String _getScadaTag(String id, String code) {
    switch (id) {
      case 'AZBAKIA':
        return 'AZB_1A';
      case 'SAYEDA1':
        return 'SYD_1B';
      case 'NSABT3':
        return 'NSB_3A';
      case 'NSABT1':
        return 'NSB_1B';
      case 'NSABT2':
        return 'NSB_2A';
      case 'SAYEDA2':
        return 'SYD_2B';
      default:
        return code.isNotEmpty ? code : id;
    }
  }
}

