import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'maarof_models.dart';
import 'maarof_controller.dart';
import 'sld_elements.dart';

/// 🎨 المخطط الأحادي التفاعلي لمحطة معروف (MAAROUF 66/11 kV)
/// - تصميم مطابق 100% بالملي لشاشة الإسكادا الحقيقية بغرفة التحكم
/// - خلفية سوداء نقية مع قضبان 66kV بلون أخضر ليموني وقضبان 11kV بلون بنفسجي
/// - خطوط طولية ممتدة لمفاتيح وقواطع المغذيات مع قراءات التيارات وأسماء المهمات
class MaarofSldCanvas extends StatelessWidget {
  final MaarofController controller = Get.find<MaarofController>();

  // 🎯 المنسوب الهندسي الدقيق للبارات في الشاشة
  static const double bb1Y = 320.0; // البارة الأولى 66kV (BB1)
  static const double bb2Y = 360.0; // البارة الثانية 66kV (BB2)
  static const double bb11kVY = 560.0; // بارة الـ 11kV السفلية

  final VoidCallback? onSoeTap;
  final VoidCallback? onCommTap;
  final VoidCallback? onNetTap;

  MaarofSldCanvas({
    super.key,
    this.onSoeTap,
    this.onCommTap,
    this.onNetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1600,
      height: 940,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() {
        final lines = controller.lines66kV;
        final transformers = controller.transformers;
        if (lines.length < 6 || transformers.length < 3) {
          return const SizedBox.shrink();
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // =========================================================
            // 0. الهيدر العلوي مدمج في الـ AppBar الرئيسي لشاشة السكادا
            // =========================================================
            const SizedBox.shrink(),

            // =========================================================
            // 1. خطوط البارات الأفقية الخضراء 66kV المستمرة عبر كامل العرض
            // =========================================================
            Positioned(
              left: 0,
              right: 0,
              top: bb1Y - 12.0,
              child: _build66kVContinuousBusbar(
                labelLeft: 'BB1A',
                kvLeft: '${controller.bus1AVoltage.value} KV',
                labelRight: 'BB1B',
                kvRight: '${controller.bus1BVoltage.value} KV',
                isTop: true,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: bb2Y - 12.0,
              child: _build66kVContinuousBusbar(
                labelLeft: 'BB2A',
                kvLeft: '${controller.bus2AVoltage.value} KV',
                labelRight: 'BB2B',
                kvRight: '${controller.bus2BVoltage.value} KV',
                isTop: false,
              ),
            ),

            // =========================================================
            // 2. خلايا خطوط الـ 66kV الستة (بالمقاسات الحقيقية)
            // =========================================================
            // خط 1: AZBAKIA
            Positioned(
              left: 50,
              top: 90,
              child: _build66kVBay(context, lines[0]),
            ),
            // خط 2: SAYEDA1
            Positioned(
              left: 210,
              top: 90,
              child: _build66kVBay(context, lines[1]),
            ),
            // خط 3: NSABT3
            Positioned(
              left: 370,
              top: 90,
              child: _build66kVBay(context, lines[2]),
            ),

            // الكابلر بالمنتصف (قاطع و سكاكين التاي بين البارتين)
            Positioned(
              left: 580,
              top: 90,
              child: _build66kVCouplerAndTieBay(context),
            ),

            // خط 4: NSABT1
            Positioned(
              left: 970,
              top: 90,
              child: _build66kVBay(context, lines[3]),
            ),
            // خط 5: NSABT2
            Positioned(
              left: 1140,
              top: 90,
              child: _build66kVBay(context, lines[4]),
            ),
            // خط 6: SAYEDA2
            Positioned(
              left: 1380,
              top: 90,
              child: _build66kVBay(context, lines[5]),
            ),

            // =========================================================
            // 3. المحولات الثلاثة (TR2, TR3, TR4)
            // =========================================================
            // محول 2 (TR2): بين SAYEDA1 و NSABT3
            Positioned(
              left: 270,
              top: bb1Y,
              child: _buildSingleTransformer(context, transformers[0]),
            ),
            // محول 3 (TR3): بين NSABT1 و NSABT2
            Positioned(
              left: 1040,
              top: bb1Y,
              child: _buildSingleTransformer(context, transformers[1]),
            ),
            // محول 4 (TR4): يمين NSABT2 بجانب SAYEDA2
            Positioned(
              left: 1250,
              top: bb1Y,
              child: _buildSingleTransformer(context, transformers[2]),
            ),

            // =========================================================
            // 4. قضبان 11kV وخلايا التوزيع السفلية الـ 42 خلية
            // =========================================================
            Positioned(
              left: 0,
              right: 0,
              top: bb11kVY,
              child: _build11kVBusbarsAndCells(context),
            ),
          ],
        );
      }),
    );
  }





  // =========================================================================
  // ⚡ بارات الـ 66kV الخضراء المستمرة
  // =========================================================================
  Widget _build66kVContinuousBusbar({
    required String labelLeft,
    required String kvLeft,
    required String labelRight,
    required String kvRight,
    required bool isTop,
  }) {
    return IgnorePointer(
      child: SizedBox(
        height: 24,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // خط البارة الرئيسي باللون الأخضر الليموني #00FF00
            Positioned(
              left: 40,
              right: 40,
              child: Container(
                height: 2.8,
                color: const Color(0xFF00FF00),
              ),
            ),
            // بيان الجهد يسار
            Positioned(
              left: 4,
              top: isTop ? -18 : 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(labelLeft,
                      style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold)),
                  Text(kvLeft,
                      style: const TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 9.0,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // بيان الجهد يمين
            Positioned(
              right: 4,
              top: isTop ? -18 : 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(labelRight,
                      style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold)),
                  Text(kvRight,
                      style: const TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 9.0,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🔌 خلية خط 66kV
  // =========================================================================
  Widget _build66kVBay(BuildContext context, FeederBay line) {
    return Obx(() {
      final cbState = controller.switches[line.cb.id]?.state ?? line.cb.state;
      final lineDsState =
          controller.switches[line.lineDs?.id]?.state ?? SwitchState.closed;
      final earthState =
          controller.switches[line.earthDs?.id]?.state ?? SwitchState.open;
      final busAState =
          controller.switches[line.busDsA?.id]?.state ?? SwitchState.closed;
      final busBState =
          controller.switches[line.busDsB?.id]?.state ?? SwitchState.open;

      return ScadaLine66kVBay(
        line: line,
        cbState: cbState,
        lineDsState: lineDsState,
        earthDsState: earthState,
        busDsAState: busAState,
        busDsBState: busBState,
        bb1Y: bb1Y - 90,
        bb2Y: bb2Y - 90,
        onCbTap: () => controller.toggleSwitch(line.cb.id),
        onLineDsTap: () {
          if (line.lineDs != null) {
            controller.toggleSwitch(line.lineDs!.id);
          }
        },
        onEarthDsTap: () {
          if (line.earthDs != null) {
            controller.toggleSwitch(line.earthDs!.id);
          }
        },
        onBusDsATap: () {
          if (line.busDsA != null) {
            controller.toggleSwitch(line.busDsA!.id);
          }
        },
        onBusDsBTap: () {
          if (line.busDsB != null) {
            controller.toggleSwitch(line.busDsB!.id);
          }
        },
      );
    });
  }

  // =========================================================================
  // 🔲 كابلر وسكاكين الربط (TIE) لبارات 66kV في المنتصف مطابق 100% لصورة الإسكادا
  // =========================================================================
  Widget _build66kVCouplerAndTieBay(BuildContext context) {
    return Obx(() {
      final cplrCb = controller.switches['CB_66_COUPLER'];
      final cplrCbState = cplrCb?.state ?? SwitchState.open;
      final cplrDs1 =
          controller.switches['DS_66_CPLR_1']?.state ?? SwitchState.open;
      final cplrDs2 =
          controller.switches['DS_66_CPLR_2']?.state ?? SwitchState.open;
      final tie1A =
          controller.switches['DS_66_TIE_1A']?.state ?? SwitchState.closed;
      final tie2A =
          controller.switches['DS_66_TIE_2A']?.state ?? SwitchState.closed;
      final tie1B =
          controller.switches['DS_66_TIE_1B']?.state ?? SwitchState.closed;
      final tie2B =
          controller.switches['DS_66_TIE_2B']?.state ?? SwitchState.closed;

      return ScadaCouplerAndTieBayWidget(
        cplrCbState: cplrCbState,
        cplrDs1State: cplrDs1,
        cplrDs2State: cplrDs2,
        tie1AState: tie1A,
        tie2AState: tie2A,
        tie1BState: tie1B,
        tie2BState: tie2B,
        bb1Y: bb1Y - 90,
        bb2Y: bb2Y - 90,
        onCplrCbTap: () => controller.toggleSwitch('CB_66_COUPLER'),
        onCplrDs1Tap: () => controller.toggleSwitch('DS_66_CPLR_1'),
        onCplrDs2Tap: () => controller.toggleSwitch('DS_66_CPLR_2'),
        onTie1ATap: () => controller.toggleSwitch('DS_66_TIE_1A'),
        onTie2ATap: () => controller.toggleSwitch('DS_66_TIE_2A'),
        onTie1BTap: () => controller.toggleSwitch('DS_66_TIE_1B'),
        onTie2BTap: () => controller.toggleSwitch('DS_66_TIE_2B'),
      );
    });
  }

  // =========================================================================
  // 🔄 محول القدرة 66/11kV
  // =========================================================================
  Widget _buildSingleTransformer(BuildContext context, TransformerModel tr) {
    return Obx(() {
      final priCbState =
          controller.switches[tr.primaryCb.id]?.state ?? tr.primaryCb.state;
      final secCbState =
          controller.switches[tr.secondaryCb.id]?.state ?? tr.secondaryCb.state;
      final busDsAState =
          controller.switches['DS_BUS_A_${tr.id}']?.state ?? SwitchState.closed;
      final busDsBState =
          controller.switches['DS_BUS_B_${tr.id}']?.state ?? SwitchState.open;
      final ngrDsState =
          controller.switches['DS_NGR_${tr.id}']?.state ?? SwitchState.closed;
      final ngrEsState =
          controller.switches['ES_NGR_${tr.id}']?.state ?? SwitchState.open;

      final busKv = tr.id == 'TR2'
          ? controller.bus2Voltage.value.toStringAsFixed(1)
          : tr.id == 'TR3'
              ? controller.bus3Voltage.value.toStringAsFixed(1)
              : controller.bus4Voltage.value.toStringAsFixed(1);

      return TransformerBayWidget(
        transformer: tr,
        priCbState: priCbState,
        secCbState: secCbState,
        busDsAState: busDsAState,
        busDsBState: busDsBState,
        ngrDsState: ngrDsState,
        ngrEsState: ngrEsState,
        busKv: busKv,
        onPriCbTap: () => controller.toggleSwitch(tr.primaryCb.id),
        onSecCbTap: () => controller.toggleSwitch(tr.secondaryCb.id),
        onBusDsATap: () => controller.toggleSwitch('DS_BUS_A_${tr.id}'),
        onBusDsBTap: () => controller.toggleSwitch('DS_BUS_B_${tr.id}'),
        onNgrDsTap: () => controller.toggleSwitch('DS_NGR_${tr.id}'),
        onNgrEsTap: () => controller.toggleSwitch('ES_NGR_${tr.id}'),
      );
    });
  }

  // =========================================================================
  // 🏢 قضبان وخلايا 11kV السفلية (الـ 42 خلية مع الخطوط الطولية الممتدة)
  // =========================================================================
  Widget _build11kVBusbarsAndCells(BuildContext context) {
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القسم 1 (14 خلية K01 حتى K14)
          Expanded(
            flex: 14,
            child: _buildSectionColumn(
              context,
              sectionTitle: 'BB2',
              sectionKv: '${controller.bus2Voltage.value} KV',
              cells: controller.cells11kVSection1,
            ),
          ),

          // وصلة الربط (Tie Loop) بين القسم 1 والقسم 2
          _build11kVTieBridge(),

          // القسم 2 (14 خلية K15 حتى K28)
          Expanded(
            flex: 14,
            child: _buildSectionColumn(
              context,
              sectionTitle: 'BB3',
              sectionKv: '${controller.bus3Voltage.value} KV',
              cells: controller.cells11kVSection2,
            ),
          ),

          // وصلة الربط (Tie Loop) بين القسم 2 والقسم 3
          _build11kVTieBridge(),

          // القسم 3 (14 خلية K29 حتى K42)
          Expanded(
            flex: 14,
            child: _buildSectionColumn(
              context,
              sectionTitle: 'BB4',
              sectionKv: '${controller.bus4Voltage.value} KV',
              cells: controller.cells11kVSection3,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSectionColumn(
    BuildContext context, {
    required String sectionTitle,
    required String sectionKv,
    required List<FeederBay> cells,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // بيان الجهد يطفو فوق البارة في مكانه الهندسي المطابق للصورة
        Positioned(
          top: -14,
          left: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$sectionTitle  ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                sectionKv,
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 9.0,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // صف الـ 14 خلية متلاصقة لتشكل بارتها خطاً أفقياً مستمراً
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              cells.map((cell) => _buildSingle11kVCell(context, cell)).toList(),
        ),
      ],
    );
  }

  Widget _build11kVTieBridge() {
    return SizedBox(
      width: 26,
      height: 310,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // خط قوس الربط العلوي
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            height: 18,
            child: CustomPaint(
              painter: _TieLoopPainter(),
            ),
          ),
          // قاطع التاي المفتوح في منتصف القوس (مربع أخضر مفرغ)
          const Positioned(
            top: 2,
            left: 7.5,
            child: BreakerSymbol(
              state: SwitchState.open,
              size: 11.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingle11kVCell(BuildContext context, FeederBay cell) {
    return Obx(() {
      final cbState = controller.switches[cell.cb.id]?.state ?? cell.cb.state;

      return Scada11kVCellWidget(
        cell: cell,
        cbState: cbState,
        onCbTap: () => controller.toggleSwitch(cell.cb.id),
      );
    });
  }
}

/// رسم قوس الربط العلوي بين أقسام بارة 11kV
class _TieLoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 4)
      ..lineTo(size.width, 4)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
