import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'maarof_models.dart';
import 'maarof_controller.dart';
import 'sld_elements.dart';
import 'digital_meter_box.dart';

/// 🎨 المخطط الأحادي التفاعلي لمحطة معروف (MAAROUF 66/11 kV)
/// - تصميم مطابق بنسبة 100% لشاشة الإسكادا الحقيقية بغرفة التحكم
/// - قضبان مزدوجة 66kV مع مسارات تفريغ لكل خط (Bus A & Bus B)
/// - كابلر رأسي رابط بين البارتين (Coupler Bay) في المنتصف
/// - سكاكين عزل وتأريض قياسية وتغيير فوري بضغطة واحدة
class MaarofSldCanvas extends StatelessWidget {
  final MaarofController controller = Get.find<MaarofController>();

  MaarofSldCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1560,
      height: 640,
      color: const Color(0xFF090B12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            // 1. خطوط البارات الأفقية البيضاء 66kV المستمرة الممتدة بكامل العرض
            // =========================================================
            Positioned(
              left: 0,
              right: 0,
              top: 156, // محاذاة البارة الأولى BB1
              child: _buildContinuousBusbar(
                labelLeft: 'BB1A',
                kvLeft: '${controller.bus1AVoltage.value} KV',
                labelRight: 'BB1B',
                kvRight: '${controller.bus1BVoltage.value} KV',
                color: Colors.white,
                isTop: true,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 198, // محاذاة البارة الثانية BB2
              child: _buildContinuousBusbar(
                labelLeft: 'BB2A',
                kvLeft: '${controller.bus2AVoltage.value} KV',
                labelRight: 'BB2B',
                kvRight: '${controller.bus2BVoltage.value} KV',
                color: Colors.white,
                isTop: false,
              ),
            ),

            // =========================================================
            // 2. خلايا الـ 66kV السبعة في مواقع منفصلة تماماً وداخل امتداد البارات
            // =========================================================
            // خط 1: AZBAKIA
            Positioned(
              left: 40,
              top: 0,
              child: _build66kVBay(context, lines[0]),
            ),
            // خط 2: SAYEDA1
            Positioned(
              left: 175,
              top: 0,
              child: _build66kVBay(context, lines[1]),
            ),
            // خط 3: NSABT3
            Positioned(
              left: 480,
              top: 0,
              child: _build66kVBay(context, lines[2]),
            ),
            // الكابلر بالمنتصف: CPLR (قوس U-Loop)
            Positioned(
              left: 620,
              top: 0,
              child: _build66kVCouplerBay(context),
            ),
            // خط 4: NSABT1
            Positioned(
              left: 800,
              top: 0,
              child: _build66kVBay(context, lines[3]),
            ),
            // خط 5: NSABT2
            Positioned(
              left: 1105,
              top: 0,
              child: _build66kVBay(context, lines[4]),
            ),
            // خط 6: SAYEDA2
            Positioned(
              left: 1410,
              top: 0,
              child: _build66kVBay(context, lines[5]),
            ),

            // =========================================================
            // 3. المحولات الثلاثة بأذرع ممتدة طويلة وموصولة مباشرة بالبارات
            // =========================================================
            // محول 2 (TR2): بين خط SAYEDA1 و NSABT3
            Positioned(
              left: 315,
              top: 156, // يتصل بالبارة الأولى BB1
              child: _buildSingleTransformer(context, transformers[0]),
            ),
            // محول 3 (TR3): بين خط NSABT1 و NSABT2
            Positioned(
              left: 940,
              top: 156, // يتصل بالبارة الأولى BB1
              child: _buildSingleTransformer(context, transformers[1]),
            ),
            // محول 4 (TR4): بين خط NSABT2 و SAYEDA2
            Positioned(
              left: 1245,
              top: 156, // يتصل بالبارة الأولى BB1
              child: _buildSingleTransformer(context, transformers[2]),
            ),

            // =========================================================
            // 4. قضبان 11kV وخلايا التوزيع السفلية (متصلة بأسفل المحولات مباشرة)
            // =========================================================
            Positioned(
              left: 0,
              right: 0,
              top: 446, // تلتقي مباشرة مع خطوط الخرج الهابطة من المحولات
              child: _build11kVBusbarsAndCells(context),
            ),
          ],
        );
      }),
    );
  }

  /// بارة أفقية مستمرة تمتد بكامل عرض المحطة دون انقطاع مع قراءات الجهد
  Widget _buildContinuousBusbar({
    required String labelLeft,
    required String kvLeft,
    required String labelRight,
    required String kvRight,
    required Color color,
    required bool isTop,
  }) {
    return IgnorePointer(
      child: SizedBox(
        height: 24,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // خط البارة الرئيسي الأبيض المستمر الممتد عبر كامل العرض
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                height: 3.2,
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(100),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    )
                  ],
                ),
              ),
            ),
            // بيان الجهد يسار البارة
            Positioned(
              left: 4,
              top: isTop ? -18 : 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$labelLeft ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    kvLeft,
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
            // بيان الجهد يمين البارة
            Positioned(
              right: 4,
              top: isTop ? -18 : 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$labelRight ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    kvRight,
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
          ],
        ),
      ),
    );
  }

  /// خلية خط 66kV فردية متصلة بالبارتين
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

      return Line66kVBayWidget(
        line: line,
        cbState: cbState,
        lineDsState: lineDsState,
        earthDsState: earthState,
        busDsAState: busAState,
        busDsBState: busBState,
        bb1Y: 156.0,
        bb2Y: 198.0,
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

  /// 🔲 خلية كابلر الـ 66kV المطابقة للمخطط الفعلي (66kV Bus Coupler U-Loop & TIE Switches)
  Widget _build66kVCouplerBay(BuildContext context) {
    return Obx(() {
      final cplrCb = controller.switches['CB_66_COUPLER'];
      final cplrDs1 = controller.switches['DS_66_CPLR_1'];
      final cplrDs2 = controller.switches['DS_66_CPLR_2'];
      final tie1A = controller.switches['DS_66_TIE_1A'];
      final tie2A = controller.switches['DS_66_TIE_2A'];
      final tie1B = controller.switches['DS_66_TIE_1B'];
      final tie2B = controller.switches['DS_66_TIE_2B'];

      final cplrCbState = cplrCb?.state ?? SwitchState.open;
      final cplrDs1State = cplrDs1?.state ?? SwitchState.open;
      final cplrDs2State = cplrDs2?.state ?? SwitchState.open;
      final tie1AState = tie1A?.state ?? SwitchState.closed;
      final tie2AState = tie2A?.state ?? SwitchState.closed;
      final tie1BState = tie1B?.state ?? SwitchState.closed;
      final tie2BState = tie2B?.state ?? SwitchState.closed;

      return SizedBox(
        width: 160,
        height: 220,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // =========================================================
            // أ. سكاكين الـ TIE الجانبية على البارتين (يسار الكابلر)
            // =========================================================
            // 1. سكينة TIE بارة 1 علوية يسار (BB1)
            Positioned(
              left: 2,
              top: 146,
              child: TieSwitchSymbol(
                state: tie1AState,
                width: 36,
                height: 20,
                onTap: () => controller.toggleSwitch('DS_66_TIE_1A'),
              ),
            ),
            // 2. سكينة TIE بارة 2 سفلية يسار (BB2) مع كلمة TIE
            Positioned(
              left: 2,
              top: 188,
              child: TieSwitchSymbol(
                state: tie2AState,
                width: 36,
                height: 20,
                showLabel: true,
                label: 'TIE',
                onTap: () => controller.toggleSwitch('DS_66_TIE_2A'),
              ),
            ),

            // =========================================================
            // ب. سكاكين الـ TIE الجانبية على البارتين (يمين الكابلر)
            // =========================================================
            // 3. سكينة TIE بارة 1 علوية يمين (BB1)
            Positioned(
              right: 2,
              top: 146,
              child: TieSwitchSymbol(
                state: tie1BState,
                width: 36,
                height: 20,
                onTap: () => controller.toggleSwitch('DS_66_TIE_1B'),
              ),
            ),
            // 4. سكينة TIE بارة 2 سفلية يمين (BB2) مع كلمة TIE
            Positioned(
              right: 2,
              top: 188,
              child: TieSwitchSymbol(
                state: tie2BState,
                width: 36,
                height: 20,
                showLabel: true,
                label: 'TIE',
                onTap: () => controller.toggleSwitch('DS_66_TIE_2B'),
              ),
            ),

            // =========================================================
            // ج. جسر الكابلر العلوي المقلوب (Inverted U-Shape Coupler Loop)
            // =========================================================
            // 1. اسم الكابلر CPLR في أعلى القوس
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'CPLR',
                  style: TextStyle(
                    color: Color(0xFFFFA726), // برتقالي زاهي مثل صورة الإسكادا
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),

            // 2. السقف الأفقي للكابلر (Horizontal Header Line)
            Positioned(
              left: 58,
              top: 30,
              width: 44,
              height: 2.5,
              child: Container(color: Colors.white),
            ),

            // =========================================================
            // د. الرجل اليسرى للكابلر (تنطلق من البارة السفلية BB2 وتصعد للأعلى)
            // =========================================================
            // خط صاعد من البارة السفلية BB2 (Y=198) حتى أسفل سكينة الكابلر 1 (Y=132)
            Positioned(
              left: 58,
              top: 132,
              width: 2.5,
              height: 66,
              child: Container(color: Colors.white),
            ),
            // سكينة الكابلر الأولى (DS1)
            Positioned(
              left: 49,
              top: 108,
              child: DisconnectorSymbol(
                state: cplrDs1State,
                size: 18,
                onTap: () => controller.toggleSwitch('DS_66_CPLR_1'),
              ),
            ),
            // خط واصل بين السكينة والقاطع
            Positioned(
              left: 58,
              top: 80,
              width: 2.5,
              height: 28,
              child: Container(color: Colors.white),
            ),
            // قاطع دائرة الكابلر (CB_66_COUPLER)
            Positioned(
              left: 49,
              top: 56,
              child: BreakerSymbol(
                state: cplrCbState,
                size: 20,
                onTap: () => controller.toggleSwitch('CB_66_COUPLER'),
              ),
            ),
            // خط صاعد من القاطع إلى السقف الأفقي
            Positioned(
              left: 58,
              top: 30,
              width: 2.5,
              height: 26,
              child: Container(color: Colors.white),
            ),

            // =========================================================
            // هـ. الرجل اليمنى للكابلر (تنطلق من البارة العلوية BB1 وتصعد للأعلى)
            // =========================================================
            // خط صاعد من البارة العلوية BB1 (Y=156) حتى أسفل سكينة الكابلر 2 (Y=110)
            Positioned(
              left: 100,
              top: 110,
              width: 2.5,
              height: 46,
              child: Container(color: Colors.white),
            ),
            // سكينة الكابلر الثانية (DS2)
            Positioned(
              left: 91,
              top: 86,
              child: DisconnectorSymbol(
                state: cplrDs2State,
                size: 18,
                onTap: () => controller.toggleSwitch('DS_66_CPLR_2'),
              ),
            ),
            // خط صاعد من السكينة إلى السقف الأفقي
            Positioned(
              left: 100,
              top: 30,
              width: 2.5,
              height: 56,
              child: Container(color: Colors.white),
            ),
          ],
        ),
      );
    });
  }

  // =========================================================
  // 🔄 محولات القدرة TR2, TR3, TR4 المطابقة للمخطط الحقيقي
  // =========================================================
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
          ? '${controller.bus2Voltage.value}'
          : tr.id == 'TR3'
              ? '${controller.bus3Voltage.value}'
              : '${controller.bus4Voltage.value}';

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

  // =========================================================
  // 🏢 قضبان وخلايا 11kV السفلية
  // =========================================================
  Widget _build11kVBusbarsAndCells(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // خط بارة 11kV الرئيسية الممتدة باللون البنفسجي
          Row(
            children: [
              _build11kVBusbarLabel(
                  'BB2', '${controller.bus2Voltage.value} KV'),
              Expanded(
                  child: Container(
                      height: 3.5,
                      color: const Color(0xFFFF00FF),
                      margin: const EdgeInsets.symmetric(horizontal: 2))),
              _build11kVBusbarLabel(
                  'BB3', '${controller.bus3Voltage.value} KV'),
              Expanded(
                  child: Container(
                      height: 3.5,
                      color: const Color(0xFFFF00FF),
                      margin: const EdgeInsets.symmetric(horizontal: 2))),
              _build11kVBusbarLabel(
                  'BB4', '${controller.bus4Voltage.value} KV'),
              Expanded(
                  child: Container(
                      height: 3.5,
                      color: const Color(0xFFFF00FF),
                      margin: const EdgeInsets.symmetric(horizontal: 2))),
            ],
          ),
          const SizedBox(height: 4),

          // شبكة الخلايا السفلية (Section 1, Section 2, Section 3)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child:
                    _buildSectionCells(context, controller.cells11kVSection1),
              ),
              Container(width: 1.5, height: 135, color: Colors.white24),
              Expanded(
                flex: 10,
                child:
                    _buildSectionCells(context, controller.cells11kVSection2),
              ),
              Container(width: 1.5, height: 135, color: Colors.white24),
              Expanded(
                flex: 15,
                child:
                    _buildSectionCells(context, controller.cells11kVSection3),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _build11kVBusbarLabel(String name, String kv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
          Text(kv,
              style: const TextStyle(
                  color: Color(0xFFFF00FF),
                  fontSize: 8.5,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionCells(BuildContext context, List<FeederBay> cells) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          cells.map((cell) => _buildSingle11kVCell(context, cell)).toList(),
    );
  }

  Widget _buildSingle11kVCell(BuildContext context, FeederBay cell) {
    return Obx(() {
      final cbState = controller.switches[cell.cb.id]?.state ?? cell.cb.state;
      final earthState =
          controller.switches[cell.earthDs?.id]?.state ?? SwitchState.open;

      return Container(
        width: 32,
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 1.5, height: 4, color: const Color(0xFFFF00FF)),

            // قاطع الخلية 11kV
            BreakerSymbol(
              state: cbState,
              size: 13,
              onTap: () => controller.toggleSwitch(cell.cb.id),
            ),

            // سكينة التأريض مع رمز الأرضي ⏚
            if (cell.earthDs != null) ...[
              Container(width: 1.5, height: 2, color: const Color(0xFFFF00FF)),
              EarthBranchWidget(
                state: earthState,
                width: 22,
                height: 12,
                onTap: () => controller.toggleSwitch(cell.earthDs!.id),
              ),
            ] else
              Container(width: 1.5, height: 4, color: const Color(0xFFFF00FF)),

            const SizedBox(height: 2),

            // قراءة التيار أو MVAR
            CellCurrentTag(
              currentA: cell.measurements.currentA,
              mvar: cell.measurements.mvar,
            ),

            const SizedBox(height: 3),

            // اسم الخلية مكتوب رأسياً باللغة العربية
            RotatedBox(
              quarterTurns: 3,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 75),
                child: Text(
                  cell.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
