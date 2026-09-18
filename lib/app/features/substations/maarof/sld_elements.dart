import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'maarof_controller.dart';
import 'maarof_models.dart';

/// 🏷️ بادج كود المفتاح أو السكينة لتسهيل الإشارة والتعديل أثناء التطوير
class DevCodeBadge extends StatelessWidget {
  final String code;
  final Color? color;

  const DevCodeBadge({
    super.key,
    required this.code,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MaarofController>()) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<MaarofController>();
    return Obx(() {
      if (!controller.showDeviceCodes.value) {
        return const SizedBox.shrink();
      }
      return IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
          decoration: BoxDecoration(
            color: const Color(0xE60A101D),
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(
              color: color ?? const Color(0xFFFFD54F),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            code,
            style: TextStyle(
              color: color ?? const Color(0xFFFFD54F),
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 0.2,
            ),
          ),
        ),
      );
    });
  }
}

/// 🏷️ استخراج كود مختصر ومميز لكل خط 66kV
String getShortLineCode(String id) {
  switch (id) {
    case 'AZBAKIA':
      return 'AZB';
    case 'SAYEDA1':
      return 'SYD1';
    case 'NSABT3':
      return 'NSB3';
    case 'NSABT1':
      return 'NSB1';
    case 'NSABT2':
      return 'NSB2';
    case 'SAYEDA2':
      return 'SYD2';
    default:
      return id;
  }
}

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
    const busColor = Color(0xFF00FF00);
    final redColor = closedColor ?? const Color(0xFFFF2222);
    final orangeColor = openColor ?? const Color(0xFFFFA726);

    final busLinePaint = Paint()
      ..color = busColor
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.square;

    if (!isHorizontal) {
      final cx = size.width / 2;
      final topDotY = 3.2;
      final botDotY = size.height - 3.2;

      // 1. وصول خطوط التغذية الخضراء حتى نقطتي التلامس
      canvas.drawLine(Offset(cx, 0), Offset(cx, topDotY), busLinePaint);
      canvas.drawLine(
          Offset(cx, botDotY), Offset(cx, size.height), busLinePaint);

      if (isClosed) {
        // 2. موصل (CLOSED): نقطتان حمراوان + جسر أحمر يربط بينهما
        final dotPaint = Paint()
          ..color = redColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(cx, topDotY), 2.5, dotPaint);
        canvas.drawCircle(Offset(cx, botDotY), 2.5, dotPaint);

        final bridgePaint = Paint()
          ..color = redColor
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.miter
          ..strokeCap = StrokeCap.square;

        final bridgePath = Path()
          ..moveTo(cx, topDotY)
          ..lineTo(cx + 3.8, topDotY)
          ..lineTo(cx + 3.8, botDotY)
          ..lineTo(cx, botDotY);

        canvas.drawPath(bridgePath, bridgePaint);
      } else {
        // مفصول (OPEN): نقطتان برتقاليتان مع ريشة مفتوحة
        final dotPaint = Paint()
          ..color = orangeColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(cx, topDotY), 2.3, dotPaint);
        canvas.drawCircle(Offset(cx, botDotY), 2.3, dotPaint);

        final bladePaint = Paint()
          ..color = orangeColor
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;

        // ريشة مفتوحة للأعلى جهة اليمين
        canvas.drawLine(
          Offset(cx, botDotY),
          Offset(cx + 6.5, topDotY + 3.0),
          bladePaint,
        );
      }
    } else {
      final cy = size.height / 2;
      final leftDotX = 3.2;
      final rightDotX = size.width - 3.2;

      // 1. وصول خطوط التغذية الخضراء الأفقية حتى نقطتي التلامس
      canvas.drawLine(Offset(0, cy), Offset(leftDotX, cy), busLinePaint);
      canvas.drawLine(
          Offset(rightDotX, cy), Offset(size.width, cy), busLinePaint);

      if (isClosed) {
        // 2. موصل (CLOSED): نقطتان حمراوان + جسر أفقي أحمر
        final dotPaint = Paint()
          ..color = redColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(leftDotX, cy), 2.5, dotPaint);
        canvas.drawCircle(Offset(rightDotX, cy), 2.5, dotPaint);

        final bridgePaint = Paint()
          ..color = redColor
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.miter
          ..strokeCap = StrokeCap.square;

        final bridgePath = Path()
          ..moveTo(leftDotX, cy)
          ..lineTo(leftDotX, cy - 3.8)
          ..lineTo(rightDotX, cy - 3.8)
          ..lineTo(rightDotX, cy);

        canvas.drawPath(bridgePath, bridgePaint);
      } else {
        // مفصول (OPEN): نقطتان برتقاليتان مع ريشة مفتوحة
        final dotPaint = Paint()
          ..color = orangeColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(leftDotX, cy), 2.3, dotPaint);
        canvas.drawCircle(Offset(rightDotX, cy), 2.3, dotPaint);

        final bladePaint = Paint()
          ..color = orangeColor
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(leftDotX, cy),
          Offset(size.width / 2 + 2.0, cy - 6.5),
          bladePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DisconnectorPainter oldDelegate) =>
      oldDelegate.isClosed != isClosed ||
      oldDelegate.isHorizontal != isHorizontal ||
      oldDelegate.openColor != openColor ||
      oldDelegate.closedColor != closedColor;
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
  final SwitchState? ngrDsState;
  final SwitchState ngrEsState;
  final String busKv;
  final VoidCallback onPriCbTap;
  final VoidCallback onSecCbTap;
  final VoidCallback onBusDsATap;
  final VoidCallback onBusDsBTap;
  final VoidCallback? onNgrDsTap;
  final VoidCallback onNgrEsTap;
  final double? incomerTargetX;
  final double bottomStickEndY;

  const TransformerBayWidget({
    super.key,
    required this.transformer,
    required this.priCbState,
    required this.secCbState,
    required this.busDsAState,
    required this.busDsBState,
    this.ngrDsState,
    required this.ngrEsState,
    required this.busKv,
    required this.onPriCbTap,
    required this.onSecCbTap,
    required this.onBusDsATap,
    required this.onBusDsBTap,
    this.onNgrDsTap,
    required this.onNgrEsTap,
    this.incomerTargetX,
    this.bottomStickEndY = 455.0,
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
    const double leftArmX =
        55.0; // مطابقة تماماً للمسافة البينية في خلايا الخطوط كالسيدة (40px بين الذراعين)
    const double rightArmX = 95.0;
    const double ngrX = 22.0;
    final double totalWidth =
        incomerTargetX != null ? (incomerTargetX! + 30.0) : 150.0;

    return SizedBox(
      width: totalWidth,
      height: bottomStickEndY,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // =========================================================
          // 1. تفريعة السكاكين المزدوجة من البارتين (BB1 و BB2) - مطابقة لخلية السيدة والخطوط
          // =========================================================
          // أ. الذراع الأيسر المتصل بـ BB1 (يبدأ من Y=0 ويعبر BB2 إلى السكينة A)
          Positioned(
            left: leftArmX - 1.0,
            top: 0,
            width: 2.0,
            height: 64,
            child: Container(color: const Color(0xFF00FF00)),
          ),
          Positioned(
            left: leftArmX - 8.0,
            top: 64,
            child: DisconnectorSymbol(
              state: busDsAState,
              size: 16.0,
              onTap: onBusDsATap,
            ),
          ),
          Positioned(
            left: leftArmX + 11,
            top: 64,
            child: DevCodeBadge(code: '${transformer.id}-DS1'),
          ),
          Positioned(
            left: leftArmX - 1.0,
            top: 80,
            width: 2.0,
            height: 10,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // ب. الذراع الأيمن المتصل بـ BB2 (يبدأ من Y=40 على البارة الثانية للسكينة B)
          Positioned(
            left: rightArmX - 1.0,
            top: 40,
            width: 2.0,
            height: 24,
            child: Container(color: const Color(0xFF00FF00)),
          ),
          Positioned(
            left: rightArmX - 8.0,
            top: 64,
            child: DisconnectorSymbol(
              state: busDsBState,
              size: 16.0,
              onTap: onBusDsBTap,
            ),
          ),
          Positioned(
            left: rightArmX + 11,
            top: 64,
            child: DevCodeBadge(code: '${transformer.id}-DS2'),
          ),
          Positioned(
            left: rightArmX - 1.0,
            top: 80,
            width: 2.0,
            height: 10,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // ج. الجسر الأفقي الجامع للذراعين أسفل السكينتين مباشرة عند Y=90
          Positioned(
            left: leftArmX - 1.0,
            top: 90,
            width: (rightArmX - leftArmX) + 2.0,
            height: 2.0,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // خط نازل من الجسر للقاطع
          Positioned(
            left: centerX - 1.0,
            top: 90,
            width: 2.0,
            height: 16,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // =========================================================
          // 2. قاطع الدخل 66kV (Primary Circuit Breaker)
          // =========================================================
          Positioned(
            left: centerX - 6.5,
            top: 106,
            child: BreakerSymbol(
              state: priCbState,
              size: 13.0,
              closedColor: const Color(0xFFFFA726),
              openBorderColor: const Color(0xFF00E5FF),
              onTap: onPriCbTap,
            ),
          ),
          Positioned(
            left: centerX + 11,
            top: 104,
            child: DevCodeBadge(code: '${transformer.id}-CB'),
          ),

          // =========================================================
          // 3. بلوك القياسات: كل قراءة على سطر مستقل على يسار المحول
          // =========================================================
          Positioned(
            left: 0,
            top: 122,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMeasRow(
                    m.mw.toStringAsFixed(1), 'MW', const Color(0xFF00E5FF)),
                _buildMeasRow(
                    m.mvar.toStringAsFixed(1), 'MVAR', const Color(0xFFFFA726)),
                _buildMeasRow(
                    m.mva.toStringAsFixed(1), 'MVA', const Color(0xFFFFA726)),
                _buildMeasRow(m.currentA.toStringAsFixed(0), 'A',
                    const Color(0xFFFFA726)),
                _buildMeasRow((m.powerFactor ?? 1.0).toStringAsFixed(2), 'PF',
                    const Color(0xFF78909C)),
              ],
            ),
          ),

          // =========================================================
          // 4. جسم المحول: الاسم + الدائرتين + المعين + TAP & MACO + NGR
          // =========================================================
          // أ. اسم المحول يسار (محول 1 / TR1)
          Positioned(
            left: 8,
            top: 190,
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
                  topCircleY: 210.0,
                  botCircleY: 224.0,
                  radius: 11.5,
                  ngrX: ngrX,
                  cbBottomY: 119.0,
                  bottomStickEndY: bottomStickEndY,
                  yTurn: bottomStickEndY - 35.0,
                  incomerTargetX: incomerTargetX,
                ),
              ),
            ),
          ),

          // ج. سكينة تأريض تفريعة NGR التفاعلية (NES)
          Positioned(
            left: ngrX - 7.0,
            top: 236,
            child: DisconnectorSymbol(
              state: ngrEsState,
              size: 14.0,
              openColor: const Color(0xFF00E5FF),
              closedColor: const Color(0xFF00E5FF),
              onTap: onNgrEsTap,
            ),
          ),
          Positioned(
            left: ngrX - 44.0,
            top: 236,
            child: DevCodeBadge(code: '${transformer.id}-NES'),
          ),

          // د. بيانات المحول يمين (19 TAP, MACO, 66/23.5 KV, 40 MVA)
          Positioned(
            left: centerX + 15,
            top: 190,
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
                    color: Color(0xFF00E5FF),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasRow(String val, String unit, Color valColor) {
    return SizedBox(
      height: 13,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            val,
            style: TextStyle(
              color: valColor,
              fontSize: 9.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.0,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// رسم ملفات المحول النحاسية والمفتاح والتفريعة
class _TransformerBodyPainter extends CustomPainter {
  final double centerX;
  final double topCircleY;
  final double botCircleY;
  final double radius;
  final double ngrX;
  final double cbBottomY;
  final double bottomStickEndY;
  final double yTurn;
  final double? incomerTargetX;

  _TransformerBodyPainter({
    this.centerX = 75.0,
    this.topCircleY = 210.0,
    this.botCircleY = 224.0,
    this.radius = 11.5,
    this.ngrX = 22.0,
    this.cbBottomY = 119.0,
    this.bottomStickEndY = 455.0,
    this.yTurn = 425.0,
    this.incomerTargetX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final greenLinePaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;

    final purpleLinePaint = Paint()
      ..color = const Color(0xFFE040FB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final topCirclePaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final botCirclePaint = Paint()
      ..color = const Color(0xFFE040FB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    // خط واصل علوي للملفات من القاطع (أخضر كالدائرة العلوية)
    canvas.drawLine(Offset(centerX, cbBottomY),
        Offset(centerX, topCircleY - radius), greenLinePaint);

    // خط واصل سفلي للملفات يمتد لأسفل:
    if (incomerTargetX != null && (incomerTargetX! - centerX).abs() > 2.0) {
      // ذراع بزاوية قايمة حادة (شكل L) من جسم المحول إلى قاطع خلية الدخول
      final path = Path()
        ..moveTo(centerX, botCircleY + radius)
        ..lineTo(centerX, yTurn) // نزول رأسي حتى نقطة العطف
        ..lineTo(incomerTargetX!, yTurn) // أفقي حتى الهدف
        ..lineTo(incomerTargetX!, bottomStickEndY); // نزول رأسي للقاطع
      canvas.drawPath(path, purpleLinePaint);
    } else {
      // نزول رأسي مستقيم
      canvas.drawLine(Offset(centerX, botCircleY + radius),
          Offset(centerX, bottomStickEndY), purpleLinePaint);
    }

    // دائرتان متداخلتان: العلوية خضراء والسفلية بنفسجية
    final topCenter = Offset(centerX, topCircleY);
    final botCenter = Offset(centerX, botCircleY);
    canvas.drawCircle(topCenter, radius, topCirclePaint);
    canvas.drawCircle(botCenter, radius, botCirclePaint);

    // تفريعة التأريض النيوترال (NGR) جهة اليسار
    final amberPaint = Paint()
      ..color = const Color(0xFFC67D0A)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    // خط أفقي خارج من الدائرة السفلية إلى خط النيوترال (بني)
    canvas.drawLine(Offset(centerX - radius, botCircleY),
        Offset(ngrX, botCircleY), amberPaint);

    final cyanLinePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;

    // خط رأسي هابط مباشرة من خط المحول البني إلى سكينة NES (من 224 إلى 236)
    canvas.drawLine(Offset(ngrX, botCircleY), Offset(ngrX, 236), cyanLinePaint);
    // نقطة اتصال سماوية عند التقاطع لسد أي فراغ بصري
    canvas.drawCircle(Offset(ngrX, botCircleY), 2.0,
        Paint()..color = const Color(0xFF00E5FF));

    // خط بين السكينة والمقاومة (من 252 إلى 258)
    canvas.drawLine(Offset(ngrX, 252), Offset(ngrX, 258), cyanLinePaint);

    // رمز مقاومة التأريض النيوترال NGR (Cyan Zig-zag Resistor من 258 إلى 274)
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final ngrPath = Path()
      ..moveTo(ngrX, 258)
      ..lineTo(ngrX - 3.5, 261.2)
      ..lineTo(ngrX + 3.5, 264.4)
      ..lineTo(ngrX - 3.5, 267.6)
      ..lineTo(ngrX + 3.5, 270.8)
      ..lineTo(ngrX, 274);
    canvas.drawPath(ngrPath, cyanPaint);

    // خط رأسي بين المقاومة والأرضي (من 274 إلى 278)
    canvas.drawLine(Offset(ngrX, 274), Offset(ngrX, 278), cyanLinePaint);

    // رمز الأرضي ⏚ بالسماوي (3 خطوط أفقية متدرجة)
    canvas.drawLine(Offset(ngrX - 7, 278), Offset(ngrX + 7, 278), cyanPaint);
    canvas.drawLine(
        Offset(ngrX - 4.5, 281.5), Offset(ngrX + 4.5, 281.5), cyanPaint);
    canvas.drawLine(Offset(ngrX - 2, 285), Offset(ngrX + 2, 285), cyanPaint);
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
          Positioned(
            top: 26,
            left: centerX - 42,
            child: DevCodeBadge(
              code: '${getShortLineCode(line.id)}-ES',
              color: const Color(0xFF4FC3F7),
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
          Positioned(
            top: 58,
            left: centerX + 11,
            child: DevCodeBadge(code: '${getShortLineCode(line.id)}-LDS'),
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
          Positioned(
            top: 86,
            left: centerX + 11,
            child: DevCodeBadge(code: '${getShortLineCode(line.id)}-CB'),
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
            top: busDsY,
            left: rightArmX + 11,
            child: DevCodeBadge(code: '${getShortLineCode(line.id)}-DS1'),
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
            top: busDsY,
            left: leftArmX - 42,
            child: DevCodeBadge(code: '${getShortLineCode(line.id)}-DS2'),
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

  String _getShortLineCode(String id) {
    switch (id) {
      case 'AZBAKIA':
        return 'AZB';
      case 'SAYEDA1':
        return 'SYD1';
      case 'NSABT3':
        return 'NSB3';
      case 'NSABT1':
        return 'NSB1';
      case 'NSABT2':
        return 'NSB2';
      case 'SAYEDA2':
        return 'SYD2';
      default:
        return id;
    }
  }

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

          // سكينة التأريض مع تدريجة الأرضي الزرقاء (مطابقة 100% لصورة الإسكادا الحقيقية)
          Positioned(
            top: 96,
            left: centerX,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEarthDsTap,
              child: CustomPaint(
                size: const Size(44, 24),
                painter: _BlueEarthSwitchPainter(
                  isClosed: earthDsState == SwitchState.closed,
                ),
              ),
            ),
          ),
          Positioned(
            top: 97,
            left: centerX + 46,
            child: DevCodeBadge(
              code: '${_getShortLineCode(line.id)}-ES',
              color: const Color(0xFF4FC3F7),
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
          Positioned(
            top: 130,
            left: centerX + 11,
            child: DevCodeBadge(code: '${_getShortLineCode(line.id)}-CB'),
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
            top: 184,
            left: leftArmX + 11,
            child: DevCodeBadge(code: '${_getShortLineCode(line.id)}-DS1'),
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
            top: 184,
            left: rightArmX + 11,
            child: DevCodeBadge(code: '${_getShortLineCode(line.id)}-DS2'),
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

/// رسم سكينة التأريض مع تدريجة الأرضي الزرقاء (مطابق 100% لشاشة الإسكادا الحقيقية من الصورة)
class _BlueEarthSwitchPainter extends CustomPainter {
  final bool isClosed;

  _BlueEarthSwitchPainter({
    required this.isClosed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const greenColor = Color(0xFF00FF00);
    const blueColor = Color(0xFF0038FF);

    final cy = size.height / 2 + 1.0;

    // 1. العصا الخضراء الأفقية الممتدة من الخط الرئيسي
    final greenPaint = Paint()
      ..color = greenColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = greenColor
      ..style = PaintingStyle.fill;

    const lineEndX = 17.0;
    canvas.drawLine(Offset(0, cy), Offset(lineEndX, cy), greenPaint);

    // نقطة التماس الخضراء (contact terminal)
    canvas.drawCircle(Offset(lineEndX, cy), 1.6, dotPaint);

    // 2. نقطة ارتكاز السكينة (Hinge) عند مدخل تدريجة الأرضي
    const hingeX = 28.0;

    // 3. ريشة السكينة الخضراء (تفتح لأعلى اليسار نحو نقطة التماس)
    final bladePaint = Paint()
      ..color = isClosed ? const Color(0xFFFF2222) : greenColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    if (isClosed) {
      // موصل: ريشة أفقية كاملة تصل نقطة التماس الخضراء بمدخل الأرضي
      canvas.drawLine(Offset(lineEndX, cy), Offset(hingeX, cy), bladePaint);
    } else {
      // مفصول (مطابق للصورة 100%): ريشة خضراء مائلة للأعلى واليسار متجهة نحو التماس
      canvas.drawLine(
        Offset(hingeX, cy),
        Offset(hingeX - 8.5, cy - 8.5),
        bladePaint,
      );
    }

    // نقطة المفصل (Hinge dot)
    canvas.drawCircle(Offset(hingeX, cy), 1.5, dotPaint);

    // 4. تدريجة الأرضي الزرقاء (Stepped Electric Blue Ground Symbol)
    final bluePaint = Paint()
      ..color = blueColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.square;

    // ساق أفقية زرقاء ممتدة عبر التدريجة
    canvas.drawLine(Offset(hingeX, cy), Offset(hingeX + 11.5, cy), bluePaint);

    // الخطوط الرأسية المتدرجة للأرضي (أطول خط في البداية ويتدرج نحو الأصغر يميناً)
    canvas.drawLine(
      Offset(hingeX + 2.8, cy - 6.5),
      Offset(hingeX + 2.8, cy + 6.5),
      bluePaint,
    );
    canvas.drawLine(
      Offset(hingeX + 5.6, cy - 4.8),
      Offset(hingeX + 5.6, cy + 4.8),
      bluePaint,
    );
    canvas.drawLine(
      Offset(hingeX + 8.4, cy - 3.2),
      Offset(hingeX + 8.4, cy + 3.2),
      bluePaint,
    );
    canvas.drawLine(
      Offset(hingeX + 11.2, cy - 1.6),
      Offset(hingeX + 11.2, cy + 1.6),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BlueEarthSwitchPainter oldDelegate) =>
      oldDelegate.isClosed != isClosed;
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
          Positioned(
            left: leftArmX + 11,
            top: 10,
            child: DevCodeBadge(code: '${transformer.id}-DS1'),
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
          Positioned(
            left: rightArmX + 11,
            top: 46,
            child: DevCodeBadge(code: '${transformer.id}-DS2'),
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
          Positioned(
            left: centerX + 10,
            top: 74,
            child: DevCodeBadge(code: '${transformer.id}-CB'),
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

          // رمز المحول (الدائرة العلوية خضراء والسفلية بنفسجية مع تفريعة أفقية وقيمة stp)
          Positioned(
            left: centerX - 14,
            top: 104,
            child: SizedBox(
              width: 56,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: const Size(44, 40),
                    painter: const _ScadaTransformerCirclesPainter(),
                  ),
                  Positioned(
                    left: 28,
                    top: 14,
                    child: Text(
                      stpText,
                      style: const TextStyle(
                        color: Color(0xFF00FF00),
                        fontSize: 8.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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

/// رسم دائرتي المحول المتداخلتين (الدائرة العلوية خضراء والسفلية بنفسجية مع خط أفقي لليمين)
/// مطابق 100% لصورة الإسكادا الحقيقية
class _ScadaTransformerCirclesPainter extends CustomPainter {
  const _ScadaTransformerCirclesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const greenColor = Color(0xFF00FF00);
    const purpleColor = Color(0xFFE040FB);

    final greenCirclePaint = Paint()
      ..color = greenColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final purpleCirclePaint = Paint()
      ..color = purpleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    const cx = 14.0;
    const r = 11.0;
    const topY = 12.0;
    const botY = 26.5;

    // 1. الدائرة العلوية (ملف 66kV الابتدائي باللون الأخضر)
    canvas.drawCircle(const Offset(cx, topY), r, greenCirclePaint);

    // 2. الدائرة السفلية (ملف 11kV الثانوي باللون البنفسجي)
    canvas.drawCircle(const Offset(cx, botY), r, purpleCirclePaint);
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
  final double cellWidth;

  const Scada11kVCellWidget({
    super.key,
    required this.cell,
    required this.cbState,
    required this.onCbTap,
    this.cellWidth = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    final isCap =
        cell.code == 'K02' || cell.code == 'K17' || cell.code == 'K40';
    final isIncomer =
        cell.code == 'K05' || cell.code == 'K21' || cell.code == 'K35';
    final hasCurrent = cell.measurements.currentA != 0;
    const double busbarY = 42.0;
    final double centerX = cellWidth / 2;

    return SizedBox(
      width: cellWidth,
      height: 310,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. مقطع البارة البنفسجية الأفقي الممتد عبر كامل عرض الخلية
          Positioned(
            top: busbarY,
            left: 0,
            right: 0,
            height: 3.0,
            child: Container(color: const Color(0xFFE040FB)),
          ),

          // 2. نقطة العقدة على البارة (Pink/Magenta dot)
          Positioned(
            top: busbarY - 1.0,
            left: centerX - 2.5,
            child: Container(
              width: 5.0,
              height: 5.0,
              decoration: const BoxDecoration(
                color: Color(0xFFE040FB),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // =========================================================
          // أ. إذا كانت الخلية هي دخول محول (INCOMER: K05, K21, K35)
          // =========================================================
          if (isIncomer) ...[
            // الخط الهابط من المحول علوياً
            Positioned(
              top: 0,
              left: centerX - 1.1,
              width: 2.2,
              height: 15.0,
              child: Container(color: const Color(0xFFE040FB)),
            ),

            // قاطع الدخول يقع فوق البارة (مربع أحمر مصمت عند الإغلاق ومربع أخضر مفرغ عند الفتح)
            Positioned(
              top: 15.0,
              left: centerX - 6.5,
              child: BreakerSymbol(
                state: cbState,
                size: 13.0,
                closedColor: const Color(0xFFFF0000),
                openBorderColor: const Color(0xFF00FF00),
                onTap: onCbTap,
              ),
            ),

            // الخط النازل من القاطع مباشرة إلى نقطة الاتصال بالبارة
            Positioned(
              top: 28.0,
              left: centerX - 1.1,
              width: 2.2,
              height: busbarY - 28.0,
              child: Container(color: const Color(0xFFE040FB)),
            ),

            // كود خلية الدخول (K21, K05, K35) يكتب أسفل البارة بالأصفر رأسياً
            Positioned(
              top: busbarY + 8.0,
              left: centerX - 12.0,
              width: 24.0,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    cell.code,
                    style: const TextStyle(
                      color: Color(0xFFFFEE58),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ]

          // =========================================================
          // ب. إذا كانت الخلية مغذي خروج عادي (OUTGOING FEEDER)
          // =========================================================
          else ...[
            // كود الخلية (K20, K22, ...) مكتوب رأسياً بالأصفر فوق البارة تماماً
            Positioned(
              top: 8.0,
              left: centerX - 12.0,
              width: 24.0,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    cell.code,
                    style: const TextStyle(
                      color: Color(0xFFFFEE58),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),

            // خط واصل هابط من البارة إلى القاطع
            Positioned(
              top: busbarY + 3.0,
              left: centerX - 0.9,
              width: 1.8,
              height: 12.0,
              child: Container(color: const Color(0xFFE040FB)),
            ),

            // قاطع المغذي أسفل البارة (مربع أحمر مصمت عند الإغلاق ومربع أخضر مفرغ عند الفتح)
            Positioned(
              top: busbarY + 15.0,
              left: centerX - 6.5,
              child: BreakerSymbol(
                state: cbState,
                size: 13.0,
                closedColor: const Color(0xFFFF0000),
                openBorderColor: const Color(0xFF00FF00),
                onTap: onCbTap,
              ),
            ),

            // الخط الطولي البنفسجي الهابط الحامل للرموز والقراءات
            Positioned(
              top: busbarY + 28.0,
              left: centerX - 0.8,
              width: 1.6,
              height: 100.0,
              child: Container(color: const Color(0xFFE040FB)),
            ),

            // في حالة المكثف (K02, K17, K40)
            if (isCap) ...[
              Positioned(
                top: busbarY + 48.0,
                left: centerX - 7.0,
                child: Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF00FF00), width: 1.5),
                  ),
                ),
              ),
              Positioned(
                top: busbarY + 80.0,
                left: centerX - 14.0,
                width: 28.0,
                child: const Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      '0.0 MVAR',
                      style: TextStyle(
                        color: Color(0xFF00FF00),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // رمز محول التيار CT: حلقة دائرية صغيرة مفرغة على الخط
              Positioned(
                top: busbarY + 44.0,
                left: centerX - 3.25,
                child: Container(
                  width: 6.5,
                  height: 6.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFE040FB), width: 1.2),
                  ),
                ),
              ),

              // رمز رأس الكابل / اتجاه التغذية: سهم بنفسجي مصمت متجه لأسفل ▼
              Positioned(
                top: busbarY + 58.0,
                left: centerX - 3.5,
                child: CustomPaint(
                  size: const Size(7.0, 5.0),
                  painter:
                      _DownwardTrianglePainter(color: const Color(0xFFE040FB)),
                ),
              ),

              // رمز الوحدة 'A' مكتوب رأسياً بالأبيض
              Positioned(
                top: busbarY + 76.0,
                left: centerX - 10.0,
                width: 20.0,
                child: const Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),

              // قيمة التيار بالأخضر الفاتح #00E676 مكتوبة رأسياً
              Positioned(
                top: busbarY + 98.0,
                left: centerX - 14.0,
                width: 28.0,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      hasCurrent
                          ? cell.measurements.currentA.toStringAsFixed(1)
                          : '0.0',
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // اسم الخلية بالأسفل مكتوب رأسياً باللون الأبيض
            if (cell.name.isNotEmpty)
              Positioned(
                bottom: 4.0,
                left: centerX - 15.0,
                width: 30.0,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 110),
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
              ),
          ],
        ],
      ),
    );
  }
}

/// مثلث بنفسجي مصمت متجه لأسفل ▼ لرمز رأس كابل المغذي
class _DownwardTrianglePainter extends CustomPainter {
  final Color color;
  const _DownwardTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

    const busColor = Color(0xFF00FF00);
    const redColor = Color(0xFFFF2222);

    final leftDotX = cx - 6.0;
    final rightDotX = cx + 6.0;

    // 1. أطراف البارة الخضراء القادمة من اليمين واليسار حتى نقطتي التلامس
    final busLinePaint = Paint()
      ..color = busColor
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(0, cy), Offset(leftDotX, cy), busLinePaint);
    canvas.drawLine(
        Offset(rightDotX, cy), Offset(size.width, cy), busLinePaint);

    if (isClosed) {
      // 2. السكينة موصلة (CLOSED) - مطابقة 100% لصورة الإسكادا الحقيقية:
      // نقطتا تلامس حمراوان عند طرفي البارة + جسر أحمر أفقي يعلوهما ويربط بينهما
      final dotPaint = Paint()
        ..color = redColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(leftDotX, cy), 2.5, dotPaint);
      canvas.drawCircle(Offset(rightDotX, cy), 2.5, dotPaint);

      final bridgePaint = Paint()
        ..color = redColor
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.miter
        ..strokeCap = StrokeCap.square;

      final bridgePath = Path()
        ..moveTo(leftDotX, cy)
        ..lineTo(leftDotX, cy - 3.8)
        ..lineTo(rightDotX, cy - 3.8)
        ..lineTo(rightDotX, cy);

      canvas.drawPath(bridgePath, bridgePaint);
    } else {
      // السكينة مفصولة (OPEN):
      // نقطتا تلامس برتقاليتان مع ريشة مفتوحة للأعلى
      final dotPaint = Paint()
        ..color = const Color(0xFFFFA726)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(leftDotX, cy), 2.3, dotPaint);
      canvas.drawCircle(Offset(rightDotX, cy), 2.3, dotPaint);

      final bladePaint = Paint()
        ..color = const Color(0xFFFFA726)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(leftDotX, cy),
        Offset(cx + 2.0, cy - 6.5),
        bladePaint,
      );
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
///   وتحتوي على سكينة كابلر 1 برتقالية ثم قاطع الكابلر (مربع أخضر مفرغ عند الفتح)
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
            child: Container(color: const Color(0xFF00FF00)),
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
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // ب. قاطع الكابلر (مربع أخضر مفرغ عند الفتح وأحمر مصمت عند التوصيل)
          Positioned(
            top: topBridgeY + 38,
            left: leftLegX - 7.0,
            child: BreakerSymbol(
              state: cplrCbState,
              size: 14.0,
              openBorderColor: const Color(0xFF00FF00),
              onTap: onCplrCbTap,
            ),
          ),
          Positioned(
            top: topBridgeY + 36,
            left: leftLegX + 11,
            child: const DevCodeBadge(code: 'CPLR-CB'),
          ),

          // ج. الخط من القاطع إلى سكينة كابلر 1
          Positioned(
            top: topBridgeY + 38 + 14,
            left: leftLegX - 1.0,
            width: 2.0,
            height: 36,
            child: Container(color: const Color(0xFF00FF00)),
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
          Positioned(
            top: topBridgeY + 38 + 14 + 36,
            left: leftLegX + 11,
            child: const DevCodeBadge(code: 'CPLR-DS1'),
          ),

          // هـ. الخط النازل من السكينة عبر BB1 وصولاً إلى BB2
          Positioned(
            top: topBridgeY + 38 + 14 + 36 + 18,
            left: leftLegX - 1.0,
            width: 2.0,
            height: bb2Y - (topBridgeY + 38 + 14 + 36 + 18),
            child: Container(color: const Color(0xFF00FF00)),
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
            child: Container(color: const Color(0xFF00FF00)),
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
          Positioned(
            top: topBridgeY + 62,
            left: rightLegX + 11,
            child: const DevCodeBadge(code: 'CPLR-DS2'),
          ),

          // ج. الخط النازل من السكينة 2 متصلاً بالبارة الأولى BB1 فقط
          Positioned(
            top: topBridgeY + 62 + 18,
            left: rightLegX - 1.0,
            width: 2.0,
            height: bb1Y - (topBridgeY + 62 + 18),
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // =========================================================
          // 5. البارة الأولى BB1 الأفقية الخضراء بالكامل مع سكاكين TIE
          // =========================================================
          // مقطع البارة يسار التاي
          Positioned(
            top: bb1Y - 1.4,
            left: 0,
            width: tieLeftX - 12,
            height: 2.8,
            child: Container(color: const Color(0xFF00FF00)),
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
          Positioned(
            top: bb1Y - 24,
            left: tieLeftX - 16,
            child: const DevCodeBadge(code: 'TIE-1A'),
          ),
          // مقطع البارة الأوسط الرابط بين التاي الأيسر والأيمن (يعبر من خلاله كابلر BB1)
          Positioned(
            top: bb1Y - 1.4,
            left: tieLeftX + 12,
            width: (tieRightX - 12) - (tieLeftX + 12),
            height: 2.8,
            child: Container(color: const Color(0xFF00FF00)),
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
          Positioned(
            top: bb1Y - 24,
            left: tieRightX - 16,
            child: const DevCodeBadge(code: 'TIE-1B'),
          ),
          // مقطع البارة يمين التاي
          Positioned(
            top: bb1Y - 1.4,
            left: tieRightX + 12,
            width: width - (tieRightX + 12),
            height: 2.8,
            child: Container(color: const Color(0xFF00FF00)),
          ),

          // =========================================================
          // 6. البارة الثانية BB2 الأفقية الخضراء بالكامل مع سكاكين TIE
          // =========================================================
          // مقطع البارة يسار التاي
          Positioned(
            top: bb2Y - 1.4,
            left: 0,
            width: tieLeftX - 12,
            height: 2.8,
            child: Container(color: const Color(0xFF00FF00)),
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
          Positioned(
            top: bb2Y - 24,
            left: tieLeftX - 16,
            child: const DevCodeBadge(code: 'TIE-2A'),
          ),
          // مقطع البارة الأوسط الرابط بين التاي الأيسر والأيمن (تتصل به الرجل اليسرى للكابلر)
          Positioned(
            top: bb2Y - 1.4,
            left: tieLeftX + 12,
            width: (tieRightX - 12) - (tieLeftX + 12),
            height: 2.8,
            child: Container(color: const Color(0xFF00FF00)),
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
          Positioned(
            top: bb2Y - 24,
            left: tieRightX - 16,
            child: const DevCodeBadge(code: 'TIE-2B'),
          ),
          // مقطع البارة يمين التاي
          Positioned(
            top: bb2Y - 1.4,
            left: tieRightX + 12,
            width: width - (tieRightX + 12),
            height: 2.8,
            child: Container(color: const Color(0xFF00FF00)),
          ),
        ],
      ),
    );
  }
}

/// 🔲 مستطيل الزون الرمادي المنقط المحيط بقطاع الـ 11kV بالكامل (لون هادئ وخفيف)
class Scada11kVZoneBox extends StatelessWidget {
  final String label;
  final Color borderColor;
  final double strokeWidth;

  const Scada11kVZoneBox({
    super.key,
    this.label = '11 KV SWITCHGEAR ZONE',
    this.borderColor = const Color(0xFF424242),
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // المستطيل المنقط ذو الحواف المنحنية الخفيفة بلون رمادي خفيف وهادئ
          Positioned.fill(
            child: CustomPaint(
              painter: _DottedRectPainter(
                color: borderColor,
                strokeWidth: strokeWidth,
                dash: 5.0,
                gap: 5.0,
                radius: 6.0,
                fillColor: const Color(0x02FFFFFF),
              ),
            ),
          ),

          // بادج تعريف الزون على الإطار العلوي بتصميم رمادي خفيف
          Positioned(
            top: -9,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: borderColor, width: 0.9),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4.5,
                    height: 4.5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE040FB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF78909C),
                      fontSize: 8.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// رسم مستطيل منقط/متقطع (Dotted/Dashed Rounded Rectangle)
class _DottedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;
  final double radius;
  final Color? fillColor;

  _DottedRectPainter({
    required this.color,
    this.strokeWidth = 1.4,
    this.dash = 6.0,
    this.gap = 4.5,
    this.radius = 6.0,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    if (fillColor != null && fillColor != Colors.transparent) {
      final fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
    }

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dash : gap;
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(
                distance, (distance + len).clamp(0.0, metric.length)),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }

    canvas.drawPath(dashedPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _DottedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap ||
      oldDelegate.radius != radius ||
      oldDelegate.fillColor != fillColor;
}
