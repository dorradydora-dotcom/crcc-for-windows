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
  final Color? openBorderColor;
  final Color? closedColor;

  const BreakerSymbol({
    super.key,
    required this.state,
    this.onTap,
    this.onLongPress,
    this.size = 20.0,
    this.showLabel = false,
    this.label,
    this.openBorderColor,
    this.closedColor,
  });

  @override
  Widget build(BuildContext context) {
    Color boxColor;
    Color borderColor;
    bool isFilled;

    switch (state) {
      case SwitchState.closed:
        boxColor = closedColor ??
            const Color(0xFFFF0000); // أحمر مصمت (أو برتقالي مخصص) - موصل
        borderColor = closedColor ?? const Color(0xFFFF2222);
        isFilled = true;
        break;
      case SwitchState.open:
        boxColor =
            const Color(0xFF000000); // أسود مع إطار أخضر أو مخصص - مفصول (open)
        borderColor = openBorderColor ?? const Color(0xFF00FF00);
        isFilled = false;
        break;
      case SwitchState.trip:
        boxColor = const Color(0xFFFFD600); // أصفر للتريب
        borderColor = Colors.white;
        isFilled = true;
        break;
      case SwitchState.unknown:
        boxColor = Colors.grey.shade800;
        borderColor = Colors.grey;
        isFilled = true;
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        child: SizedBox(
          width: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // منطقة لمس ممتدة ومتماثلة تماماً دون التأثير على المحاذاة (+8px من كل جانب)
              Positioned(
                left: -8,
                right: -8,
                top: -8,
                bottom: -8,
                child: const SizedBox.expand(),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
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
  final Color? openColor;
  final Color? closedColor;

  const DisconnectorSymbol({
    super.key,
    required this.state,
    this.onTap,
    this.onLongPress,
    this.size = 20.0,
    this.isHorizontal = false,
    this.openColor,
    this.closedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = state == SwitchState.closed;
    final double w = isHorizontal ? size * 1.2 : size;
    final double h = isHorizontal ? size : size * 1.2;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // منطقة لمس ممتدة ومتماثلة تماماً دون التأثير على المحاذاة (+8px من كل جانب)
              Positioned(
                left: -8,
                right: -8,
                top: -8,
                bottom: -8,
                child: const SizedBox.expand(),
              ),
              CustomPaint(
                size: Size(w, h),
                painter: _DisconnectorPainter(
                  isClosed: isClosed,
                  isHorizontal: isHorizontal,
                  openColor: openColor,
                  closedColor: closedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisconnectorPainter extends CustomPainter {
  final bool isClosed;
  final bool isHorizontal;
  final Color? openColor;
  final Color? closedColor;

  _DisconnectorPainter({
    required this.isClosed,
    required this.isHorizontal,
    this.openColor,
    this.closedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // لون السكينة: أحمر (أو مخصص) للموصل، وأخضر (أو برتقالي أو سماوي مخصص) للمفصول
    final switchColor = isClosed
        ? (closedColor ?? const Color(0xFFFF2222))
        : (openColor ?? const Color(0xFF00E676));

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
      final topY = 0.0;
      final botY = size.height;

      // أطراف السكينة العلوية والسفلية (Terminal stops)
      canvas.drawLine(
          Offset(cx - 3.2, topY), Offset(cx + 3.2, topY), terminalPaint);
      canvas.drawLine(
          Offset(cx - 3.2, botY), Offset(cx + 3.2, botY), terminalPaint);

      // العلامة الرأسية الجانبية
      canvas.drawLine(Offset(cx + 4.5, topY + 1.0),
          Offset(cx + 4.5, botY - 1.0), terminalPaint);

      if (isClosed) {
        // خط مستقيم يربط الطرفين (أحمر موصل)
        canvas.drawLine(Offset(cx, topY), Offset(cx, botY), linePaint);
      } else {
        // ريشة مفتوحة لليمين بزاوية قائمة ونهاية عمودية (أخضر أو برتقالي مفصول)
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
      final leftX = 0.0;
      final rightX = size.width;

      canvas.drawLine(
          Offset(leftX, cy - 3.2), Offset(leftX, cy + 3.2), terminalPaint);
      canvas.drawLine(
          Offset(rightX, cy - 3.2), Offset(rightX, cy + 3.2), terminalPaint);

      // العلامة الأفقية الجانبية
      canvas.drawLine(Offset(leftX + 1.0, cy + 4.5),
          Offset(rightX - 1.0, cy + 4.5), terminalPaint);

      if (isClosed) {
        // خط مستقيم يربط الطرفين (أحمر موصل)
        canvas.drawLine(Offset(leftX, cy), Offset(rightX, cy), linePaint);
      } else {
        // ريشة مفتوحة (أخضر أو برتقالي مفصول)
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
      oldDelegate.isHorizontal != isHorizontal ||
      oldDelegate.openColor != openColor;
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -8,
                right: -8,
                top: -8,
                bottom: -8,
                child: const SizedBox.expand(),
              ),
              CustomPaint(
                size: Size(width, height),
                painter: _DisconnectorPainter(
                  isClosed: isClosed,
                  isHorizontal: true,
                ),
              ),
              if (showLabel && label != null)
                Positioned(
                  top: height + 1,
                  left: -10,
                  right: -10,
                  child: Center(
                    child: Text(
                      label!,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isClosed
                            ? const Color(0xFFFF2222)
                            : const Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -6,
                right: -6,
                top: -6,
                bottom: -6,
                child: const SizedBox.expand(),
              ),
              CustomPaint(
                size: Size(width, height),
                painter: _EarthBranchPainter(
                  isClosed: isClosed,
                  color: color,
                  isLeft: isLeft,
                ),
              ),
            ],
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
      final rightX = size.width;
      final hingeX = size.width - 5.0;
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
      canvas.drawLine(Offset(groundX - 2.2, cy - 2.8),
          Offset(groundX - 2.2, cy + 2.8), paint);
      canvas.drawLine(Offset(groundX - 4.4, cy - 1.4),
          Offset(groundX - 4.4, cy + 1.4), paint);
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
    const double leftArmX = 45.0;
    const double rightArmX = 105.0;
    const double ngrX = 22.0;

    return SizedBox(
      width: 150,
      height: 265,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // =========================================================
          // 1. تفريعة السكاكين المزدوجة من البارتين (BB1 و BB2)
          // =========================================================
          // أ. الذراع الأيسر المتصل بـ BB1 (يبدأ من Y=0 ويعبر BB2 إلى السكينة A)
          Positioned(
            left: leftArmX - 1.1,
            top: 0,
            width: 2.2,
            height: 44,
            child: Container(color: Colors.white),
          ),
          Positioned(
            left: leftArmX - 8.0,
            top: 44,
            child: DisconnectorSymbol(
              state: busDsAState,
              size: 14,
              openColor: const Color(0xFF00E5FF),
              closedColor: const Color(0xFF00E5FF),
              onTap: onBusDsATap,
            ),
          ),
          Positioned(
            left: leftArmX - 1.1,
            top: 61,
            width: 2.2,
            height: 5,
            child: Container(color: Colors.white),
          ),

          // ب. الذراع الأيمن المتصل بـ BB2 (يبدأ من Y=40 على البارة الثانية للسكينة B)
          Positioned(
            left: rightArmX - 1.1,
            top: 40,
            width: 2.2,
            height: 4,
            child: Container(color: Colors.white),
          ),
          Positioned(
            left: rightArmX - 8.0,
            top: 44,
            child: DisconnectorSymbol(
              state: busDsBState,
              size: 14,
              openColor: const Color(0xFF00E5FF),
              closedColor: const Color(0xFF00E5FF),
              onTap: onBusDsBTap,
            ),
          ),
          Positioned(
            left: rightArmX - 1.1,
            top: 61,
            width: 2.2,
            height: 5,
            child: Container(color: Colors.white),
          ),

          // ج. الجسر الأفقي الجامع للذراعين أسفل السكينتين مباشرة عند Y=66
          Positioned(
            left: leftArmX - 1.1,
            top: 66,
            width: (rightArmX - leftArmX) + 2.2,
            height: 2.2,
            child: Container(color: Colors.white),
          ),

          // خط نازل من الجسر للقاطع
          Positioned(
            left: centerX - 1.1,
            top: 66,
            width: 2.2,
            height: 8,
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 2. قاطع الدخل 66kV (Primary Circuit Breaker)
          // =========================================================
          Positioned(
            left: centerX - 6.5,
            top: 74,
            child: BreakerSymbol(
              state: priCbState,
              size: 13.0,
              closedColor: const Color(0xFFFFA726),
              openBorderColor: const Color(0xFF00E5FF),
              onTap: onPriCbTap,
            ),
          ),

          // =========================================================
          // 3. بلوك القياسات مقسوم بالخط الرأسي تماماً كما في شاشة الإسكادا:
          //    الأرقام على اليسار والوحدات على اليمين والخط بالمنتصف
          // =========================================================
          Positioned(
            right: (150.0 - centerX) + 4.0,
            top: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildValText(m.mw.toStringAsFixed(1), const Color(0xFF00E5FF)),
                _buildValText(
                    m.mvar.toStringAsFixed(1), const Color(0xFFFFA726)),
                _buildValText(
                    m.mva.toStringAsFixed(1), const Color(0xFFFFA726)),
                _buildValText(
                    m.currentA.toStringAsFixed(0), const Color(0xFFFFA726)),
                _buildValText((m.powerFactor ?? 1.0).toStringAsFixed(2),
                    const Color(0xFF78909C)),
              ],
            ),
          ),
          Positioned(
            left: centerX + 4.0,
            top: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUnitText('MW'),
                _buildUnitText('MVAR'),
                _buildUnitText('MVA'),
                _buildUnitText('A'),
                _buildUnitText('PF'),
              ],
            ),
          ),

          // =========================================================
          // 4. جسم المحول: الاسم + الدائرتين + المعين + TAP & MACO + NGR
          // =========================================================
          // أ. اسم المحول يسار (محول 1 / TR1)
          Positioned(
            left: 8,
            top: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  arabicName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transformer.name,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ب. رسمة الدائرتين البيضاوين + المعين + تفريعة NGR
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TransformerBodyPainter(
                  centerX: centerX,
                  topCircleY: 154.0,
                  botCircleY: 166.0,
                  radius: 10.5,
                  ngrX: ngrX,
                ),
              ),
            ),
          ),

          // ج. سكاكين تفريعة NGR التفاعلية
          Positioned(
            left: ngrX - 6.0,
            top: 172,
            child: DisconnectorSymbol(
              state: ngrDsState,
              size: 11,
              openColor: const Color(0xFF00E5FF),
              closedColor: const Color(0xFF00E5FF),
              onTap: onNgrDsTap,
            ),
          ),
          Positioned(
            left: ngrX - 6.0,
            top: 188,
            child: DisconnectorSymbol(
              state: ngrEsState,
              size: 11,
              openColor: const Color(0xFF00E5FF),
              closedColor: const Color(0xFF00E5FF),
              onTap: onNgrEsTap,
            ),
          ),

          // د. بيانات المحول يمين (19 TAP, MACO, 66/23.5 KV, 40 MVA)
          Positioned(
            left: centerX + 15,
            top: 140,
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
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Text(
                      'TAP',
                      style: TextStyle(
                        color: Color(0xFFFFA726),
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  transformer.manufacturer.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '66/23.5 KV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  '40 MVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // 5. قاطع الخرج 11kV (Secondary Circuit Breaker)
          // =========================================================
          Positioned(
            left: centerX - 6.5,
            top: 212,
            child: BreakerSymbol(
              state: secCbState,
              size: 13.0,
              closedColor: const Color(0xFFFFA726),
              openBorderColor: const Color(0xFF00E5FF),
              onTap: onSecCbTap,
            ),
          ),

          // =========================================================
          // 6. خط الخرج الهابط المتصل مباشرة بقضيب الـ 11kV
          // =========================================================
          Positioned(
            left: centerX - 1.1,
            top: 225,
            width: 2.2,
            height: 40,
            child: Container(color: Colors.white),
          ),

          // بيان البارة السفلية فوق نقطة الاتصال بالبارة
          Positioned(
            left: 8,
            bottom: 4,
            child: Text(
              transformer.id == 'TR1'
                  ? 'BB 1'
                  : transformer.id == 'TR2'
                      ? 'BB 2'
                      : transformer.id == 'TR3'
                          ? 'BB 3'
                          : 'BB 4',
              style: const TextStyle(
                color: Color(0xFFFFA726),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  busKv,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 3),
                const Text(
                  'KV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // دائرة PT البنفسجية أسفل خط البارة مباشرة
          Positioned(
            left: centerX - 4.5,
            top: 265,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE040FB),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValText(String val, Color color) {
    return Container(
      height: 13,
      alignment: Alignment.centerRight,
      child: Text(
        val,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildUnitText(String unit) {
    return Container(
      height: 13,
      alignment: Alignment.centerLeft,
      child: Text(
        unit,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.0,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
    );
  }
}

class _TransformerBodyPainter extends CustomPainter {
  final double centerX;
  final double topCircleY;
  final double botCircleY;
  final double radius;
  final double ngrX;

  _TransformerBodyPainter({
    this.centerX = 75.0,
    this.topCircleY = 154.0,
    this.botCircleY = 166.0,
    this.radius = 10.5,
    this.ngrX = 22.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final whiteLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // خط واصل علوي للملفات من القاطع
    canvas.drawLine(Offset(centerX, 87), Offset(centerX, topCircleY - radius),
        whiteLinePaint);
    // خط واصل سفلي للملفات إلى القاطع الثانوي
    canvas.drawLine(Offset(centerX, botCircleY + radius), Offset(centerX, 212),
        whiteLinePaint);

    // دائرتان متداخلتان باللون الأبيض
    final topCenter = Offset(centerX, topCircleY);
    final botCenter = Offset(centerX, botCircleY);
    canvas.drawCircle(topCenter, radius, circlePaint);
    canvas.drawCircle(botCenter, radius, circlePaint);

    // المعين البرتقالي عند التقاطع الأيمن ◇
    final diamondCenter = Offset(centerX + 11.8, (topCircleY + botCircleY) / 2);
    final diamondPath = Path()
      ..moveTo(diamondCenter.dx, diamondCenter.dy - 3.2)
      ..lineTo(diamondCenter.dx + 3.2, diamondCenter.dy)
      ..lineTo(diamondCenter.dx, diamondCenter.dy + 3.2)
      ..lineTo(diamondCenter.dx - 3.2, diamondCenter.dy)
      ..close();

    final diamondPaint = Paint()
      ..color = const Color(0xFFFFA726)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(diamondPath, diamondPaint);

    // تفريعة التأريض النيوترال (NGR) جهة اليسار باللون البني
    final amberPaint = Paint()
      ..color = const Color(0xFFC67D0A)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    // خط أفقي خارج من الدائرة السفلية إلى خط النيوترال
    canvas.drawLine(Offset(centerX - radius, botCircleY),
        Offset(ngrX, botCircleY), amberPaint);
    // خط رأسي هابط إلى السكينة الأولى
    canvas.drawLine(Offset(ngrX, botCircleY), Offset(ngrX, 172), amberPaint);
    // خط بين السكينة 1 والسكينة 2
    canvas.drawLine(Offset(ngrX, 183), Offset(ngrX, 188), amberPaint);
    // تفريعة أفقية خارجة لليسار بين السكينتين
    canvas.drawLine(Offset(ngrX, 185), Offset(0, 185), amberPaint);
    // خط بين السكينة 2 والمقاومة
    canvas.drawLine(Offset(ngrX, 199), Offset(ngrX, 202), amberPaint);

    // رمز مقاومة التأريض النيوترال NGR (Cyan Zig-zag Resistor)
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final ngrPath = Path()
      ..moveTo(ngrX, 202)
      ..lineTo(ngrX - 2.8, 204.5)
      ..lineTo(ngrX + 2.8, 207.0)
      ..lineTo(ngrX - 2.8, 209.5)
      ..lineTo(ngrX, 212);
    canvas.drawPath(ngrPath, cyanPaint);

    // رمز الأرضي ⏚ بالسماوي (3 خطوط أفقية متدرجة)
    canvas.drawLine(Offset(ngrX, 212), Offset(ngrX, 214), cyanPaint);
    canvas.drawLine(Offset(ngrX - 6, 214), Offset(ngrX + 6, 214), cyanPaint);
    canvas.drawLine(Offset(ngrX - 4, 217), Offset(ngrX + 4, 217), cyanPaint);
    canvas.drawLine(Offset(ngrX - 2, 220), Offset(ngrX + 2, 220), cyanPaint);
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
    this.bb1Y = 160.0,
    this.bb2Y = 235.0,
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
                    fontSize: 13.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  scadaTag,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
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
            left: centerX - 8.0,
            child: DisconnectorSymbol(
              state: lineDsState,
              size: 16,
              onTap: onLineDsTap,
            ),
          ),

          // 6. الخط الرأسي الواصل بين سكينة الخط والقاطع
          Positioned(
            top: 79,
            left: centerX - 1.1,
            width: 2.2,
            height: 9,
            child: Container(color: Colors.white),
          ),

          // 7. قاطع الدائرة الرئيسي CB (مربع سماوي مصمت #00E5FF)
          Positioned(
            top: 88,
            left: centerX - 8.0,
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
            height: 10,
            child: Container(color: Colors.white),
          ),

          // 9. جسر التفرع الأفقي الأبيض
          Positioned(
            top: bridgeY,
            left: leftArmX - 1.1,
            width: rightArmX - leftArmX + 2.2,
            height: 2.2,
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 10. تفريعة السكاكين المزدوجة للبارتين
          // =========================================================
          // أ. الفرع الأيمن (سكينة بارة 1 - DS_BUS_A واصلة لـ BB1)
          Positioned(
            top: bridgeY + 2.2,
            left: rightArmX - 1.1,
            width: 2.2,
            height: busDsY - (bridgeY + 2.2),
            child: Container(color: Colors.white),
          ),
          Positioned(
            top: busDsY,
            left: rightArmX - 8.0,
            child: DisconnectorSymbol(
              state: busDsAState,
              size: 16,
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
            top: bridgeY + 2.2,
            left: leftArmX - 1.1,
            width: 2.2,
            height: busDsY - (bridgeY + 2.2),
            child: Container(color: Colors.white),
          ),
          Positioned(
            top: busDsY,
            left: leftArmX - 8.0,
            child: DisconnectorSymbol(
              state: busDsBState,
              size: 16,
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

// =========================================================================
// 🎯 ويدجت خط 66kV المطابقة 100% لشاشة الإسكادا الحقيقية بالملي
// =========================================================================
class ScadaLine66kVBay extends StatelessWidget {
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

  const ScadaLine66kVBay({
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
    required this.bb1Y,
    required this.bb2Y,
  });

  @override
  Widget build(BuildContext context) {
    const double centerX = 50.0;
    const double leftArmX = 30.0;
    const double rightArmX = 70.0;

    final hasCableSpec = line.id == 'AZBAKIA' || line.id == 'NSABT2';
    final isHighlighted = line.id == 'NSABT2' || line.id == 'SAYEDA2';

    return SizedBox(
      width: 100,
      height: bb2Y + 10,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // مواصفات الكابل إن وجدت 1 X 800 mm²
          if (hasCableSpec)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '1 X 800 mm²',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 8.0,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // جدول القياسات (MW, MVAR, MVA, A)
          Positioned(
            top: hasCableSpec ? 14 : 6,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: const Color(0xFF00FF00),
                      borderRadius: BorderRadius.circular(1),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMeasureRow(line.measurements.mw, 'MW', isHighlighted),
                  _buildMeasureRow(
                      line.measurements.mvar, 'MVAR', isHighlighted),
                  _buildMeasureRow(line.measurements.mva, 'MVA', isHighlighted),
                  _buildMeasureRow(
                      line.measurements.currentA, 'A', isHighlighted),
                ],
              ),
            ),
          ),

          // كارت اسم الخط داخل مستطيل أخضر (بالعربي)
          Positioned(
            top: 72,
            left: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: const Color(0xFF00FF00), width: 1.4),
              ),
              child: Center(
                child: Text(
                  line.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // خط رأسي أخضر هابط من البوكس
          Positioned(
            top: 94,
            left: centerX - 1.0,
            width: 2.0,
            height: 38,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // سكينة التأريض الزرقاء متفرعة لليمين مع رمز الأرضي
          Positioned(
            top: 102,
            left: centerX,
            child: GestureDetector(
              onTap: onEarthDsTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 14, height: 1.8, color: const Color(0xFF00FF00)),
                  CustomPaint(
                    size: const Size(18, 14),
                    painter: _BlueEarthSwitchPainter(
                      isClosed: earthDsState == SwitchState.closed,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // قاطع الدائرة الرئيسي (مربع أحمر مصمت عند التوصيل)
          Positioned(
            top: 132,
            left: centerX - 6.5,
            child: BreakerSymbol(
              state: cbState,
              size: 13.0,
              onTap: onCbTap,
            ),
          ),

          // خط رأسي من القاطع إلى جسر التوزيع
          Positioned(
            top: 145,
            left: centerX - 1.0,
            width: 2.0,
            height: 25,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // جسر التوزيع الأفقي
          Positioned(
            top: 170,
            left: leftArmX - 1.0,
            width: (rightArmX - leftArmX) + 2.0,
            height: 2.0,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // الذراع الأيسر المتصل بـ BB1 (سكينة بارة 1)
          Positioned(
            top: 172,
            left: leftArmX - 1.0,
            width: 2.0,
            height: 12,
            child: Container(color: const Color(0xFF00FF00)),
          ),
          Positioned(
            top: 184,
            left: leftArmX - 8.0,
            child: DisconnectorSymbol(
              state: busDsAState,
              size: 16.0,
              onTap: onBusDsATap,
            ),
          ),
          Positioned(
            top: 202,
            left: leftArmX - 1.0,
            width: 2.0,
            height: bb1Y - 202,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // الذراع الأيمن المتصل بـ BB2 (سكينة بارة 2)
          Positioned(
            top: 172,
            left: rightArmX - 1.0,
            width: 2.0,
            height: 12,
            child: Container(color: const Color(0xFF00FF00)),
          ),
          Positioned(
            top: 184,
            left: rightArmX - 8.0,
            child: DisconnectorSymbol(
              state: busDsBState,
              size: 16.0,
              onTap: onBusDsBTap,
            ),
          ),
          Positioned(
            top: 202,
            left: rightArmX - 1.0,
            width: 2.0,
            height: bb2Y - 202,
            child: Container(color: const Color(0xFF00FF00)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasureRow(double val, String unit, bool isHighlighted) {
    final textColor = isHighlighted ? Colors.black : const Color(0xFF00FF00);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            val.toStringAsFixed(1),
            style: TextStyle(
              color: textColor,
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 28,
            child: Text(
              unit,
              style: TextStyle(
                color: textColor,
                fontSize: 8.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// رسم سكينة التأريض الزرقاء مع الأرضي
class _BlueEarthSwitchPainter extends CustomPainter {
  final bool isClosed;
  _BlueEarthSwitchPainter({required this.isClosed});

  @override
  void paint(Canvas canvas, Size size) {
    const blueColor = Color(0xFF2979FF);
    final paint = Paint()
      ..color = blueColor
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.square;

    final cy = size.height / 2;

    if (isClosed) {
      canvas.drawLine(Offset(0, cy), Offset(size.width - 6, cy), paint);
    } else {
      // ريشة مفتوحة للأعلى
      canvas.drawLine(Offset(0, cy), Offset(size.width - 8, cy - 6), paint);
    }

    // رمز الأرضي باللون الأزرق
    final groundX = size.width - 4;
    canvas.drawLine(Offset(groundX, cy - 6), Offset(groundX, cy + 6), paint);
    canvas.drawLine(
        Offset(groundX + 2.5, cy - 4), Offset(groundX + 2.5, cy + 4), paint);
    canvas.drawLine(
        Offset(groundX + 5, cy - 2), Offset(groundX + 5, cy + 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// 🔄 ويدجت محول القدرة 66/11kV المطابق للصورة بالضبط
// =========================================================================
class ScadaTransformerBayWidget extends StatelessWidget {
  final TransformerModel transformer;
  final SwitchState priCbState;
  final SwitchState busDsAState;
  final SwitchState busDsBState;
  final VoidCallback onPriCbTap;
  final VoidCallback onBusDsATap;
  final VoidCallback onBusDsBTap;
  final double bb1Y;
  final double bb2Y;

  const ScadaTransformerBayWidget({
    super.key,
    required this.transformer,
    required this.priCbState,
    required this.busDsAState,
    required this.busDsBState,
    required this.onPriCbTap,
    required this.onBusDsATap,
    required this.onBusDsBTap,
    required this.bb1Y,
    required this.bb2Y,
  });

  @override
  Widget build(BuildContext context) {
    final m = transformer.primaryMeasurements;
    final sm = transformer.secondaryMeasurements;
    const double centerX = 60.0;
    const double leftArmX = 35.0;
    const double rightArmX = 85.0;

    final isTr3 = transformer.id == 'TR3';
    final nameColor = isTr3 ? const Color(0xFFFF2222) : const Color(0xFF00E5FF);
    final stpText = transformer.id == 'TR4' ? '8 stp' : '0 stp';

    return SizedBox(
      width: 150,
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // أذرع التوصيل بالبارتين BB1 و BB2: كل سكينة على بارة مستقلة
          // 1. الذراع الأيسر المتصل بـ BB1 (يبدأ من البارة الأولى عند Y=0)
          Positioned(
            left: leftArmX - 1.0,
            top: 0,
            width: 2.0,
            height: 10,
            child: Container(color: const Color(0xFF00FF00)),
          ),
          Positioned(
            left: leftArmX - 8.0,
            top: 10,
            child: DisconnectorSymbol(
              state: busDsAState,
              size: 15.0,
              onTap: onBusDsATap,
            ),
          ),
          // امتداد خط الذراع الأيسر هابطاً متجاوزاً منسوب البارة الثانية BB2 حتى جسر التجميع عند Y=68
          Positioned(
            left: leftArmX - 1.0,
            top: 28,
            width: 2.0,
            height: 40,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // 2. الذراع الأيمن المتصل بـ BB2 (يبدأ مباشرة من البارة الثانية عند Y=40 ولا يمس البارة الأولى)
          Positioned(
            left: rightArmX - 1.0,
            top: 40,
            width: 2.0,
            height: 6,
            child: Container(color: const Color(0xFF00FF00)),
          ),
          Positioned(
            left: rightArmX - 8.0,
            top: 46,
            child: DisconnectorSymbol(
              state: busDsBState,
              size: 15.0,
              onTap: onBusDsBTap,
            ),
          ),
          // امتداد خط الذراع الأيمن من السكينة B إلى جسر التجميع عند Y=68
          Positioned(
            left: rightArmX - 1.0,
            top: 64,
            width: 2.0,
            height: 4,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // 3. الجسر الأفقي الجامع للذراعين أسفل البارة الثانية عند Y=68
          Positioned(
            left: leftArmX - 1.0,
            top: 68,
            width: (rightArmX - leftArmX) + 2.0,
            height: 2.0,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // خط هابط من الجسر لقاطع المحول 66kV
          Positioned(
            left: centerX - 1.0,
            top: 68,
            width: 2.0,
            height: 8,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // قاطع المحول الابتدائي (مربع مصمت عند التوصيل ومفرغ عند الفصل)
          Positioned(
            left: centerX - 6.5,
            top: 76,
            child: BreakerSymbol(
              state: priCbState,
              size: 13.0,
              onTap: onPriCbTap,
            ),
          ),

          // قياسات الابتدائي بجانب القاطع (MW, MVAR, MVA, A, PF)
          Positioned(
            left: centerX - 56,
            top: 66,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRow(m.mw.toStringAsFixed(1), 'MW'),
                _buildRow(m.mvar.toStringAsFixed(1), 'MVAR'),
                _buildRow(m.mva.toStringAsFixed(1), 'MVA'),
                _buildRow(m.currentA.toStringAsFixed(1), 'A'),
                _buildRow((m.powerFactor ?? 0.98).toStringAsFixed(2), 'PF'),
              ],
            ),
          ),

          // خط رأسي هابط إلى الملفات
          Positioned(
            left: centerX - 1.0,
            top: 89,
            width: 2.0,
            height: 16,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // بيانات المحول (TR2, 66/11KV, 25MVA, Maco, 19TAP)
          Positioned(
            left: centerX + 18,
            top: 86,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transformer.name,
                  style: TextStyle(
                    color: nameColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  '66/11KV\n25MVA\nMaco\n19 TAP',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 8.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),

          // رمز المحول (دائرتان متداخلتان باللون البنفسجي)
          Positioned(
            left: centerX - 14,
            top: 101,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(28, 42),
                  painter: _PurpleTransformerCirclesPainter(),
                ),
                const SizedBox(width: 4),
                Text(
                  stpText,
                  style: const TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 8.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // قياسات الثانوي أسفل الملفات
          Positioned(
            left: centerX - 56,
            top: 136,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRow(sm.mw.toStringAsFixed(1), 'MW'),
                _buildRow(sm.mvar.toStringAsFixed(1), 'MVAR'),
                _buildRow(sm.mva.toStringAsFixed(1), 'MVA'),
                _buildRow(sm.currentA.toStringAsFixed(1), 'A'),
                _buildRow((sm.currentA * 1.02).toStringAsFixed(1), 'A'),
                _buildRow((sm.currentA * 0.96).toStringAsFixed(1), 'A'),
                _buildRow((sm.powerFactor ?? 0.98).toStringAsFixed(2), 'PF'),
              ],
            ),
          ),

          // خط الخرج البنفسجي الهابط المتصل بالبارة 11kV
          Positioned(
            left: centerX - 1.0,
            top: 143,
            width: 2.0,
            height: 107,
            child: Container(color: const Color(0xFFE040FB)),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String val, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            val,
            style: const TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 8.0,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          SizedBox(
            width: 28,
            child: Text(
              unit,
              style: const TextStyle(
                color: Color(0xFF00FF00),
                fontSize: 7.5,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// رسم دائرتين متداخلتين باللون البنفسجي للمحول
class _PurpleTransformerCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const purpleColor = Color(0xFFE040FB);
    final paint = Paint()
      ..color = purpleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    const r = 11.0;
    canvas.drawCircle(Offset(cx, 13), r, paint);
    canvas.drawCircle(Offset(cx, 27), r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// 🏢 ويدجت خلية 11kV الفردية المطابقة للصورة بالملي مع الخط الطولي
// =========================================================================
class Scada11kVCellWidget extends StatelessWidget {
  final FeederBay cell;
  final SwitchState cbState;
  final VoidCallback onCbTap;

  const Scada11kVCellWidget({
    super.key,
    required this.cell,
    required this.cbState,
    required this.onCbTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCap =
        cell.code == 'K02' || cell.code == 'K17' || cell.code == 'K40';
    final hasCurrent = cell.measurements.currentA != 0;

    return SizedBox(
      width: 34,
      height: 310,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. كود الخلية (K01, K02...) مكتوب رأسياً بلون أخضر فوق البارة مباشرة
          Positioned(
            top: 2,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                cell.code,
                style: const TextStyle(
                  color: Color(0xFF76FF03),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),

          // 2. مقطع البارة البنفسجية الأفقي المتصل بين الخلايا
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            height: 3.0,
            child: Container(color: const Color(0xFFE040FB)),
          ),

          // 3. قاطع الدائرة ملتصق بالبارة (مربع أحمر مغلق، أو مربع أخضر مفرغ إذا كان مفتوحاً)
          Positioned(
            top: 26,
            child: BreakerSymbol(
              state: cbState,
              size: 11.5,
              onTap: onCbTap,
            ),
          ),

          // 4. الخط الطولي البنفسجي الهابط بطول 135 بكسل
          Positioned(
            top: 38,
            left: 16.2,
            width: 1.6,
            height: 135,
            child: Container(color: const Color(0xFFE040FB)),
          ),

          // 5. رمز المكثف إن وجد، أو قراءة التيار على الخط الطولي
          if (isCap) ...[
            Positioned(
              top: 85,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFF00FF00), width: 1.5),
                ),
              ),
            ),
            const Positioned(
              top: 118,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  '0.0 MVAR',
                  style: TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ] else if (hasCurrent) ...[
            Positioned(
              top: 75,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  '${cell.measurements.currentA.toStringAsFixed(1)}  A',
                  style: const TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],

          // 6. اسم الخلية بالأسفل مكتوب رأسياً باللون الأبيض
          if (cell.name.isNotEmpty)
            Positioned(
              bottom: 4,
              child: RotatedBox(
                quarterTurns: 3,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 125),
                  child: Text(
                    cell.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🔀 رمز سكينة الـ TIE الأفقية على البارة بتصميم مطابق لشاشة الإسكادا الحقيقية بالملي
class ScadaBusTieSwitchWidget extends StatelessWidget {
  final SwitchState state;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const ScadaBusTieSwitchWidget({
    super.key,
    required this.state,
    this.onTap,
    this.width = 28.0,
    this.height = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = state == SwitchState.closed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            size: Size(width, height),
            painter: _ScadaBusTiePainter(isClosed: isClosed),
          ),
        ),
      ),
    );
  }
}

class _ScadaBusTiePainter extends CustomPainter {
  final bool isClosed;
  _ScadaBusTiePainter({required this.isClosed});

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final cx = size.width / 2;

    // القضبان الطرفية الأفقية السماوية المميزة لشاشات PCS-9700
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square;

    // القضيب العلوي
    canvas.drawLine(
        Offset(cx - 8, cy - 4.5), Offset(cx + 8, cy - 4.5), cyanPaint);
    // القضيب السفلي
    canvas.drawLine(
        Offset(cx - 8, cy + 4.5), Offset(cx + 8, cy + 4.5), cyanPaint);

    if (isClosed) {
      // موصل: خط مستمر يعبر بين الطرفين
      final closedPaint = Paint()
        ..color = const Color(0xFFFF2222)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), closedPaint);
    } else {
      // مفصول: ريشة برتقالية وفراغ بين نهايتي البارة
      final busLinePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(0, cy), Offset(cx - 6, cy), busLinePaint);
      canvas.drawLine(Offset(cx + 6, cy), Offset(size.width, cy), busLinePaint);

      final bladePaint = Paint()
        ..color = const Color(0xFFFFA726)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(cx - 6, cy), Offset(cx + 3, cy - 4.5), bladePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScadaBusTiePainter oldDelegate) =>
      oldDelegate.isClosed != isClosed;
}

/// 🔲 ويدجت خلية الكابلر (CPLR) وسكاكين الربط (TIE) لبارات 66kV
/// مطابقة 100% للصورة المرفقة من المستخدم:
/// - قوس رأسي صاعد (Inverted U Loop) يربط بين البارتين
/// - الرجل اليسرى تبدأ من البارة السفلى BB2 وتمر عبر البارة العليا BB1
///   وتحتوي على سكينة كابلر 1 برتقالية ثم قاطع الكابلر (مربع سماوي مفرغ عند الفتح)
/// - جسر أفقي علوي مكتوب فوقه CPLR باللون البرتقالي
/// - الرجل اليمنى تهبط وتحتوي على سكينة كابلر 2 برتقالية وتنتهي على البارة العليا BB1
/// - سكاكين TIE على البارتين يميناً ويساراً مع كتابة TIE بالبرتقالي أسفل كل منهما
class ScadaCouplerAndTieBayWidget extends StatelessWidget {
  final SwitchState cplrCbState;
  final SwitchState cplrDs1State;
  final SwitchState cplrDs2State;
  final SwitchState tie1AState;
  final SwitchState tie2AState;
  final SwitchState tie1BState;
  final SwitchState tie2BState;
  final VoidCallback onCplrCbTap;
  final VoidCallback onCplrDs1Tap;
  final VoidCallback onCplrDs2Tap;
  final VoidCallback onTie1ATap;
  final VoidCallback onTie2ATap;
  final VoidCallback onTie1BTap;
  final VoidCallback onTie2BTap;
  final double bb1Y;
  final double bb2Y;

  const ScadaCouplerAndTieBayWidget({
    super.key,
    required this.cplrCbState,
    required this.cplrDs1State,
    required this.cplrDs2State,
    required this.tie1AState,
    required this.tie2AState,
    required this.tie1BState,
    required this.tie2BState,
    required this.onCplrCbTap,
    required this.onCplrDs1Tap,
    required this.onCplrDs2Tap,
    required this.onTie1ATap,
    required this.onTie2ATap,
    required this.onTie1BTap,
    required this.onTie2BTap,
    this.bb1Y = 230.0,
    this.bb2Y = 270.0,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 280.0;
    const double height = 310.0;
    const double centerX = 140.0;
    const double leftLegX = 125.0;
    const double rightLegX = 155.0;
    const double tieLeftX = 55.0;
    const double tieRightX = 225.0;
    const double topBridgeY = 92.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // =========================================================
          // 0. خلفية حجب للبارات خلف منطقة التاي والكابلر لمنع التداخل
          // =========================================================
          Positioned(
            left: 0,
            top: bb1Y - 10,
            width: width,
            height: (bb2Y - bb1Y) + 20,
            child: Container(color: Colors.black),
          ),

          // =========================================================
          // 1. عنوان الكابلر في الأعلى CPLR باللون البرتقالي
          // =========================================================
          Positioned(
            top: topBridgeY - 18,
            left: centerX - 25,
            width: 50,
            child: const Center(
              child: Text(
                'CPLR',
                style: TextStyle(
                  color: Color(0xFFFFA726),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // =========================================================
          // 2. الجسر الأفقي العلوي للكابلر
          // =========================================================
          Positioned(
            top: topBridgeY,
            left: leftLegX - 1.0,
            width: (rightLegX - leftLegX) + 2.0,
            height: 2.0,
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 3. الرجل اليسرى للكابلر (تصل من BB2 صعوداً للجسر)
          // =========================================================
          // أ. الخط من الجسر العلوي إلى القاطع
          Positioned(
            top: topBridgeY,
            left: leftLegX - 1.0,
            width: 2.0,
            height: 38,
            child: Container(color: Colors.white),
          ),

          // ب. قاطع الكابلر (مربع سماوي مفرغ عند الفتح وأحمر مصمت عند التوصيل)
          Positioned(
            top: topBridgeY + 38,
            left: leftLegX - 7.0,
            child: BreakerSymbol(
              state: cplrCbState,
              size: 14.0,
              openBorderColor: const Color(0xFF00E5FF),
              onTap: onCplrCbTap,
            ),
          ),

          // ج. الخط من القاطع إلى سكينة كابلر 1
          Positioned(
            top: topBridgeY + 38 + 14,
            left: leftLegX - 1.0,
            width: 2.0,
            height: 36,
            child: Container(color: Colors.white),
          ),

          // د. سكينة كابلر 1 برتقالية عند الفتح
          Positioned(
            top: topBridgeY + 38 + 14 + 36,
            left: leftLegX - 8.0,
            child: DisconnectorSymbol(
              state: cplrDs1State,
              size: 15.0,
              openColor: const Color(0xFFFFA726),
              onTap: onCplrDs1Tap,
            ),
          ),

          // هـ. الخط النازل من السكينة عبر BB1 وصولاً إلى BB2
          Positioned(
            top: topBridgeY + 38 + 14 + 36 + 18,
            left: leftLegX - 1.0,
            width: 2.0,
            height: bb2Y - (topBridgeY + 38 + 14 + 36 + 18),
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 4. الرجل اليمنى للكابلر (تهبط من الجسر وتنتهي على BB1 فقط)
          // =========================================================
          // أ. الخط من الجسر العلوي إلى سكينة كابلر 2
          Positioned(
            top: topBridgeY,
            left: rightLegX - 1.0,
            width: 2.0,
            height: 62,
            child: Container(color: Colors.white),
          ),

          // ب. سكينة كابلر 2 برتقالية عند الفتح (في منسوب وسطي مطابق للصورة)
          Positioned(
            top: topBridgeY + 62,
            left: rightLegX - 8.0,
            child: DisconnectorSymbol(
              state: cplrDs2State,
              size: 15.0,
              openColor: const Color(0xFFFFA726),
              onTap: onCplrDs2Tap,
            ),
          ),

          // ج. الخط النازل من السكينة 2 متصلاً بالبارة الأولى BB1 فقط
          Positioned(
            top: topBridgeY + 62 + 18,
            left: rightLegX - 1.0,
            width: 2.0,
            height: bb1Y - (topBridgeY + 62 + 18),
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 5. البارة الأولى BB1 الأفقية والبيضاء مع سكاكين TIE
          // =========================================================
          // مقطع البارة يسار التاي
          Positioned(
            top: bb1Y - 1.0,
            left: 0,
            width: tieLeftX - 12,
            height: 2.4,
            child: Container(color: Colors.white),
          ),
          // سكينة TIE بارة 1 يسار
          Positioned(
            top: bb1Y - 9,
            left: tieLeftX - 12,
            child: ScadaBusTieSwitchWidget(
              state: tie1AState,
              onTap: onTie1ATap,
              width: 24,
            ),
          ),
          // مقطع البارة الأوسط الرابط بين التاي الأيسر والأيمن (يعبر من خلاله كابلر BB1)
          Positioned(
            top: bb1Y - 1.0,
            left: tieLeftX + 12,
            width: (tieRightX - 12) - (tieLeftX + 12),
            height: 2.4,
            child: Container(color: Colors.white),
          ),
          // سكينة TIE بارة 1 يمين
          Positioned(
            top: bb1Y - 9,
            left: tieRightX - 12,
            child: ScadaBusTieSwitchWidget(
              state: tie1BState,
              onTap: onTie1BTap,
              width: 24,
            ),
          ),
          // مقطع البارة يمين التاي
          Positioned(
            top: bb1Y - 1.0,
            left: tieRightX + 12,
            width: width - (tieRightX + 12),
            height: 2.4,
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 6. البارة الثانية BB2 الأفقية والبيضاء مع سكاكين TIE
          // =========================================================
          // مقطع البارة يسار التاي
          Positioned(
            top: bb2Y - 1.0,
            left: 0,
            width: tieLeftX - 12,
            height: 2.4,
            child: Container(color: Colors.white),
          ),
          // سكينة TIE بارة 2 يسار
          Positioned(
            top: bb2Y - 9,
            left: tieLeftX - 12,
            child: ScadaBusTieSwitchWidget(
              state: tie2AState,
              onTap: onTie2ATap,
              width: 24,
            ),
          ),
          // مقطع البارة الأوسط الرابط بين التاي الأيسر والأيمن (تتصل به الرجل اليسرى للكابلر)
          Positioned(
            top: bb2Y - 1.0,
            left: tieLeftX + 12,
            width: (tieRightX - 12) - (tieLeftX + 12),
            height: 2.4,
            child: Container(color: Colors.white),
          ),
          // سكينة TIE بارة 2 يمين
          Positioned(
            top: bb2Y - 9,
            left: tieRightX - 12,
            child: ScadaBusTieSwitchWidget(
              state: tie2BState,
              onTap: onTie2BTap,
              width: 24,
            ),
          ),
          // مقطع البارة يمين التاي
          Positioned(
            top: bb2Y - 1.0,
            left: tieRightX + 12,
            width: width - (tieRightX + 12),
            height: 2.4,
            child: Container(color: Colors.white),
          ),

          // =========================================================
          // 7. كتابة TIE بالبرتقالي أسفل سكاكين التاي اليسرى واليمنى
          // =========================================================
          Positioned(
            top: bb2Y + 12,
            left: tieLeftX - 20,
            width: 40,
            child: const Center(
              child: Text(
                'TIE',
                style: TextStyle(
                  color: Color(0xFFFFA726),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          Positioned(
            top: bb2Y + 12,
            left: tieRightX - 20,
            width: 40,
            child: const Center(
              child: Text(
                'TIE',
                style: TextStyle(
                  color: Color(0xFFFFA726),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
