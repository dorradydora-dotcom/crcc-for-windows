import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'maarof_models.dart';

class MaarofController extends GetxController {
  // 🔘 وضع التشغيل: محاكاة تفاعلية أم ربط حي بالسيرفر
  final RxBool isSimulationMode = true.obs;
  final RxBool isConnectedToScada = false.obs;
  final RxString apiBaseUrl = 'http://127.0.0.1:8000/api/v1/telemetry/live'.obs;

  // ⚡ قضبان التوزيع 66kV
  final RxDouble bus1AVoltage = 65.80.obs;
  final RxDouble bus2AVoltage = 64.97.obs;
  final RxDouble bus1BVoltage = 65.99.obs;
  final RxDouble bus2BVoltage = 65.48.obs;

  // ⚡ قضبان التوزيع 11kV / 21kV
  final RxDouble bus2Voltage = 21.0.obs;
  final RxDouble bus3Voltage = 10.82.obs;
  final RxDouble bus4Voltage = 10.56.obs;

  // 📋 خريطة لجميع المفاتيح لسرعة الوصول والتحديث
  final RxMap<String, SwitchItem> switches = <String, SwitchItem>{}.obs;

  // 🔌 خطوط الـ 66kV
  final RxList<FeederBay> lines66kV = <FeederBay>[].obs;

  // 🔄 محولات القدرة TR2, TR3, TR4
  final RxList<TransformerModel> transformers = <TransformerModel>[].obs;

  // 🏢 خلايا الـ 11kV (مقسمة لـ 3 أقسام رئيسية حسب البارات)
  final RxList<FeederBay> cells11kVSection1 = <FeederBay>[].obs;
  final RxList<FeederBay> cells11kVSection2 = <FeederBay>[].obs;
  final RxList<FeederBay> cells11kVSection3 = <FeederBay>[].obs;

  // 📝 سجل الأحداث والإنذارات
  final RxList<EventLogItem> eventLogs = <EventLogItem>[].obs;

  // 🏷️ إظهار أكواد المفاتيح والسكاكين (لتسهيل الإشارة والتعديل أثناء التطوير)
  final RxBool showDeviceCodes = true.obs;
  void toggleDeviceCodes() => showDeviceCodes.toggle();

  // ⏱️ مؤقت سحب البيانات الحية
  Timer? _liveDataTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeSubstationData();
  }

  @override
  void onClose() {
    _liveDataTimer?.cancel();
    super.onClose();
  }

  /// تهيئة بيانات محطة معروف الافتراضية بناءً على المخطط الفعلي
  void _initializeSubstationData() {
    switches.clear();
    lines66kV.clear();
    transformers.clear();
    cells11kVSection1.clear();
    cells11kVSection2.clear();
    cells11kVSection3.clear();

    // 1. مفاتيح وقاطع الـ 66kV Coupler و الـ TIE
    _registerSwitch(SwitchItem(
      id: 'CB_66_COUPLER',
      name: 'قاطع الكابلر CPLR (66kV)',
      tag: '[PCS-9710-TU1]MAAROUF_66_CPLR_CB',
      type: SwitchType.busCoupler,
      state: SwitchState.open,
      voltageLevel: '66kV',
    ));
    _registerSwitch(SwitchItem(
      id: 'DS_66_CPLR_1',
      name: 'سكينة كابلر 1 (الرجل اليسرى)',
      tag: '[PCS-9710-TU1]MAAROUF_66_CPLR_DS1',
      type: SwitchType.disconnector,
      state: SwitchState.open,
      voltageLevel: '66kV',
    ));
    _registerSwitch(SwitchItem(
      id: 'DS_66_CPLR_2',
      name: 'سكينة كابلر 2 (الرجل اليمنى)',
      tag: '[PCS-9710-TU1]MAAROUF_66_CPLR_DS2',
      type: SwitchType.disconnector,
      state: SwitchState.open,
      voltageLevel: '66kV',
    ));
    // مفاتيح الـ TIE الجانبية للبارتين
    _registerSwitch(SwitchItem(
      id: 'DS_66_TIE_1A',
      name: 'سكينة TIE بارة 1 يسار',
      tag: '[PCS-9710-TU1]MAAROUF_66_TIE_1A',
      type: SwitchType.disconnector,
      state: SwitchState.closed,
      voltageLevel: '66kV',
    ));
    _registerSwitch(SwitchItem(
      id: 'DS_66_TIE_2A',
      name: 'سكينة TIE بارة 2 يسار',
      tag: '[PCS-9710-TU1]MAAROUF_66_TIE_2A',
      type: SwitchType.disconnector,
      state: SwitchState.closed,
      voltageLevel: '66kV',
    ));
    _registerSwitch(SwitchItem(
      id: 'DS_66_TIE_1B',
      name: 'سكينة TIE بارة 1 يمين',
      tag: '[PCS-9710-TU1]MAAROUF_66_TIE_1B',
      type: SwitchType.disconnector,
      state: SwitchState.closed,
      voltageLevel: '66kV',
    ));
    _registerSwitch(SwitchItem(
      id: 'DS_66_TIE_2B',
      name: 'سكينة TIE بارة 2 يمين',
      tag: '[PCS-9710-TU1]MAAROUF_66_TIE_2B',
      type: SwitchType.disconnector,
      state: SwitchState.closed,
      voltageLevel: '66kV',
    ));

    // 2. خطوط الـ 66kV (AZBAKIA, SAYEDA1, NSABT3, NSABT1, NSABT2, SAYEDA2)
    final lineConfigs = [
      {
        'id': 'AZBAKIA',
        'name': 'الأزبكية',
        'code': 'AZBAKIA',
        'cable': '1 X 800 mm²',
        'mw': 0.0,
        'mvar': 0.1,
        'mva': 0.1,
        'a': 1.0,
        'bus': 'A'
      },
      {
        'id': 'SAYEDA1',
        'name': 'السيدة 1',
        'code': 'SAYEDA1',
        'cable': '',
        'mw': 12.1,
        'mvar': 3.3,
        'mva': 12.6,
        'a': 111.3,
        'bus': 'A'
      },
      {
        'id': 'NSABT3',
        'name': 'ن السبتية 3',
        'code': 'NSABT3',
        'cable': '',
        'mw': -20.1,
        'mvar': -6.8,
        'mva': 21.3,
        'a': 188.9,
        'bus': 'A'
      },
      {
        'id': 'NSABT1',
        'name': 'ن السبتية 1',
        'code': 'NSABT1',
        'cable': '',
        'mw': -19.2,
        'mvar': -10.1,
        'mva': 21.7,
        'a': 191.2,
        'bus': 'B'
      },
      {
        'id': 'NSABT2',
        'name': 'ن السبتية 2',
        'code': 'NSABT2',
        'cable': '1 X 800 mm²',
        'mw': 12.4,
        'mvar': -2.9,
        'mva': 12.7,
        'a': 197.3,
        'bus': 'B'
      },
      {
        'id': 'SAYEDA2',
        'name': 'السيدة 2',
        'code': 'SAYEDA2',
        'cable': '',
        'mw': 12.0,
        'mvar': 5.4,
        'mva': 13.2,
        'a': 113.8,
        'bus': 'B'
      },
    ];

    for (var cfg in lineConfigs) {
      final id = cfg['id'] as String;
      final cb = _registerSwitch(SwitchItem(
        id: 'CB_66_$id',
        name: 'قاطع $id 66kV',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_CB_52',
        type: SwitchType.circuitBreaker,
        state: SwitchState.closed,
        voltageLevel: '66kV',
      ));
      final lineDs = _registerSwitch(SwitchItem(
        id: 'DS_LINE_66_$id',
        name: 'سكينة خط $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_LINE_DS',
        type: SwitchType.disconnector,
        state: SwitchState.closed,
        voltageLevel: '66kV',
      ));
      final earthDs = _registerSwitch(SwitchItem(
        id: 'ES_66_$id',
        name: 'أرضي خط $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_ES',
        type: SwitchType.earthSwitch,
        state: SwitchState.open,
        voltageLevel: '66kV',
      ));
      final busDsA = _registerSwitch(SwitchItem(
        id: 'DS_BUS_A_$id',
        name: 'سكينة بارة A $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_BUS_DS_A',
        type: SwitchType.disconnector,
        state: SwitchState.closed,
        voltageLevel: '66kV',
      ));
      final busDsB = _registerSwitch(SwitchItem(
        id: 'DS_BUS_B_$id',
        name: 'سكينة بارة B $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_BUS_DS_B',
        type: SwitchType.disconnector,
        state: SwitchState.open,
        voltageLevel: '66kV',
      ));

      lines66kV.add(FeederBay(
        id: id,
        name: cfg['name'] as String,
        code: cfg['code'] as String,
        voltage: '66kV',
        cableSpec: cfg['cable'] as String,
        cb: cb,
        lineDs: lineDs,
        earthDs: earthDs,
        busDsA: busDsA,
        busDsB: busDsB,
        measurements: Measurements(
          mw: cfg['mw'] as double,
          mvar: cfg['mvar'] as double,
          mva: cfg['mva'] as double,
          currentA: cfg['a'] as double,
        ),
      ));
    }

    // 3. محولات القدرة (TR2, TR3, TR4)
    final trConfigs = [
      {
        'id': 'TR2',
        'name': 'TR2',
        'tap': 19,
        'dsA': SwitchState.closed, // على بارة 1 (BB1)
        'dsB': SwitchState.open, // على بارة 2 (BB2)
        'pri_mw': 15.0,
        'pri_mvar': 0.0,
        'pri_mva': 15.0,
        'pri_a': 412.0,
        'pri_pf': 1.00,
        'sec_mw': -15.0,
        'sec_mvar': 0.0,
        'sec_mva': 15.0,
        'sec_a': 412.0,
        'sec_pf': 1.0,
      },
      {
        'id': 'TR3',
        'name': 'TR3',
        'tap': 19,
        'dsA': SwitchState.open, // على بارة 1 (BB1)
        'dsB': SwitchState.closed, // على بارة 2 (BB2)
        'pri_mw': 8.7,
        'pri_mvar': 1.8,
        'pri_mva': 8.9,
        'pri_a': 79.4,
        'pri_pf': 0.98,
        'sec_mw': -8.7,
        'sec_mvar': -1.5,
        'sec_mva': 8.9,
        'sec_a': 475.0,
        'sec_pf': 0.98,
      },
      {
        'id': 'TR4',
        'name': 'TR4',
        'tap': 19,
        'dsA': SwitchState.closed, // على بارة 1 (BB1)
        'dsB': SwitchState.open, // على بارة 2 (BB2)
        'pri_mw': 7.6,
        'pri_mvar': 2.3,
        'pri_mva': 7.9,
        'pri_a': 72.0,
        'pri_pf': 0.96,
        'sec_mw': -4.8,
        'sec_mvar': -1.5,
        'sec_mva': 5.0,
        'sec_a': 410.0,
        'sec_pf': 0.95,
      },
    ];

    for (var cfg in trConfigs) {
      final id = cfg['id'] as String;
      final priCb = _registerSwitch(SwitchItem(
        id: 'CB_PRI_$id',
        name: 'قاطع ابتدائي $id (66kV)',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_PRI_CB',
        type: SwitchType.circuitBreaker,
        state: SwitchState.closed,
        voltageLevel: '66kV',
      ));
      final secCb = _registerSwitch(SwitchItem(
        id: 'CB_SEC_$id',
        name: 'قاطع ثانوي $id (11kV)',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_SEC_CB',
        type: SwitchType.circuitBreaker,
        state: SwitchState.closed,
        voltageLevel: '11kV',
      ));
      final busDsA = _registerSwitch(SwitchItem(
        id: 'DS_BUS_A_$id',
        name: 'سكينة بارة A محول $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_BUS_DS_A',
        type: SwitchType.disconnector,
        state: (cfg['dsA'] as SwitchState?) ?? SwitchState.closed,
        voltageLevel: '66kV',
      ));
      final busDsB = _registerSwitch(SwitchItem(
        id: 'DS_BUS_B_$id',
        name: 'سكينة بارة B محول $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_BUS_DS_B',
        type: SwitchType.disconnector,
        state: (cfg['dsB'] as SwitchState?) ?? SwitchState.open,
        voltageLevel: '66kV',
      ));
      final ngrDs = _registerSwitch(SwitchItem(
        id: 'DS_NGR_$id',
        name: 'سكينة NGR محول $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_NGR_DS',
        type: SwitchType.disconnector,
        state: SwitchState.closed,
        voltageLevel: '11kV',
      ));
      final ngrEs = _registerSwitch(SwitchItem(
        id: 'ES_NGR_$id',
        name: 'سكينة تأريض NGR محول $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_NGR_ES',
        type: SwitchType.earthSwitch,
        state: SwitchState.open,
        voltageLevel: '11kV',
      ));

      transformers.add(TransformerModel(
        id: id,
        name: cfg['name'] as String,
        specs: '66/23.5 KV 40 MVA',
        manufacturer: 'MACO',
        tapPosition: cfg['tap'] as int,
        primaryCb: priCb,
        secondaryCb: secCb,
        busDsA: busDsA,
        busDsB: busDsB,
        ngrDs: ngrDs,
        ngrEs: ngrEs,
        primaryMeasurements: Measurements(
          mw: cfg['pri_mw'] as double,
          mvar: cfg['pri_mvar'] as double,
          mva: cfg['pri_mva'] as double,
          currentA: cfg['pri_a'] as double,
          powerFactor: cfg['pri_pf'] as double,
        ),
        secondaryMeasurements: Measurements(
          mw: cfg['sec_mw'] as double,
          mvar: cfg['sec_mvar'] as double,
          mva: cfg['sec_mva'] as double,
          currentA: cfg['sec_a'] as double,
          powerFactor: cfg['sec_pf'] as double,
        ),
      ));
    }

    // 4. خلايا الـ 11kV - القسم 1 (BB2 - 14 خلية K01 حتى K14)
    final sec1Feeders = [
      {
        'name': 'BUS COUPLER (2-4)',
        'code': 'K01',
        'a': -0.3,
        'isCoupler': true
      },
      {'name': 'مكثف (2)', 'code': 'K02', 'a': 0.0, 'isCap': true, 'mvar': 0.0},
      {'name': 'البستان', 'code': 'K03', 'a': 119.4},
      {'name': 'المتحف الاسلامى', 'code': 'K04', 'a': 49.3},
      {'name': 'دخول محول 4', 'code': 'K05', 'a': 0.0, 'isOpen': false},
      {'name': 'الدوحة (1)', 'code': 'K06', 'a': 1.3},
      {'name': 'ملحق تجارى (2)', 'code': 'K07', 'a': 13.7},
      {'name': 'هيلتون رمسيس (2)', 'code': 'K08', 'a': 77.2},
      {'name': 'قصر النيل', 'code': 'K09', 'a': 39.7},
      {'name': 'محول مساعد (1)', 'code': 'K10', 'a': -0.2},
      {'name': 'جراج الاوبرا', 'code': 'K11', 'a': 133.0},
      {'name': 'موزع معروف', 'code': 'K12', 'a': 26.8},
      {'name': 'MEASUREMENT CELL(2)', 'code': 'K13', 'a': 0.0},
      {
        'name': 'BUS RISER (2-3)',
        'code': 'K14',
        'a': 0.0,
        'isRiser': true,
        'isOpen': true
      },
    ];

    for (var f in sec1Feeders) {
      cells11kVSection1.add(_create11kVFeeder(f, 'SEC1'));
    }

    // 5. خلايا الـ 11kV - القسم 2 (BB3 - 14 خلية K15 حتى K28)
    final sec2Feeders = [
      {
        'name': 'BUS COUPLER (2-3)',
        'code': 'K15',
        'a': -1.4,
        'isCoupler': true
      },
      {'name': 'MEASUREMENT CELL(3)', 'code': 'K16', 'a': 0.0},
      {'name': 'مكثف (3)', 'code': 'K17', 'a': 0.0, 'isCap': true, 'mvar': 0.0},
      {'name': 'توفيقية (1)', 'code': 'K18', 'a': 142.8},
      {'name': 'توفيقية (2)', 'code': 'K19', 'a': 136.3},
      {'name': 'التلفزيون', 'code': 'K20', 'a': 2.0},
      {'name': 'دخول محول 3', 'code': 'K21', 'a': 0.0, 'isOpen': false},
      {'name': 'مثلث ماسبيرو (2)', 'code': 'K22', 'a': 41.7},
      {'name': 'شامبليون', 'code': 'K23', 'a': 51.0},
      {'name': 'ملحق تجارى (1)', 'code': 'K24', 'a': 13.6},
      {'name': 'هيلتون رمسيس (1)', 'code': 'K25', 'a': 34.0},
      {'name': 'مثلث ماسبيرو (1)', 'code': 'K26', 'a': 42.5},
      {'name': 'الدوحة 2', 'code': 'K27', 'a': 11.1},
      {
        'name': 'BUS RISER (3-4)',
        'code': 'K28',
        'a': 0.0,
        'isRiser': true,
        'isOpen': true
      },
    ];

    for (var f in sec2Feeders) {
      cells11kVSection2.add(_create11kVFeeder(f, 'SEC2'));
    }

    // 6. خلايا الـ 11kV - القسم 3 (BB4 - 14 خلية K29 حتى K42)
    final sec3Feeders = [
      {
        'name': 'BUS COUPLER (3-4)',
        'code': 'K29',
        'a': -0.5,
        'isCoupler': true
      },
      {'name': 'طلعت حرب', 'code': 'K30', 'a': 72.7},
      {'name': 'الاستعلامات', 'code': 'K31', 'a': 77.6},
      {'name': 'الصالون الاخضر', 'code': 'K32', 'a': 83.1},
      {'name': 'محول مساعد (2)', 'code': 'K33', 'a': 1.2},
      {'name': 'مصلحة الكيميا', 'code': 'K34', 'a': 28.3},
      {'name': 'دخول محول 2', 'code': 'K35', 'a': 0.0, 'isOpen': false},
      {'name': 'الثورى (1)', 'code': 'K36', 'a': 29.2},
      {'name': 'الثورى (2)', 'code': 'K37', 'a': 28.9},
      {'name': 'تفريغ الادارة (1)', 'code': 'K38', 'a': 47.8},
      {'name': 'تفريغ الادارة (2)', 'code': 'K39', 'a': -255.6},
      {'name': 'مكثف (4)', 'code': 'K40', 'a': 0.0, 'isCap': true, 'mvar': 0.0},
      {'name': 'MEASUREMENT CELL (4)', 'code': 'K41', 'a': 0.0},
      {
        'name': 'BUS RISER (2-4)',
        'code': 'K42',
        'a': 0.0,
        'isRiser': true,
        'isOpen': true
      },
    ];

    for (var f in sec3Feeders) {
      cells11kVSection3.add(_create11kVFeeder(f, 'SEC3'));
    }
  }

  /// مساعد لإنشاء وتسجيل خلايا 11kV
  FeederBay _create11kVFeeder(Map<String, dynamic> data, String prefix) {
    final code = data['code'] as String;
    final name = data['name'] as String;
    final isOpen = data['isOpen'] == true;
    final id = '${prefix}_$code';

    final cb = _registerSwitch(SwitchItem(
      id: 'CB_11_$id',
      name: name.isNotEmpty ? 'قاطع $name ($code)' : 'قاطع $code',
      tag: '[PCS-9710-TU1]MAAROUF_11KV_${code}_CB',
      type: SwitchType.circuitBreaker,
      state: isOpen ? SwitchState.open : SwitchState.closed,
      voltageLevel: '11kV',
    ));

    final earth = _registerSwitch(SwitchItem(
      id: 'ES_11_$id',
      name: name.isNotEmpty ? 'أرضي $name ($code)' : 'أرضي $code',
      tag: '[PCS-9710-TU1]MAAROUF_11KV_${code}_ES',
      type: SwitchType.earthSwitch,
      state: SwitchState.open,
      voltageLevel: '11kV',
    ));

    return FeederBay(
      id: id,
      name: name,
      code: code,
      voltage: '11kV',
      cb: cb,
      earthDs: earth,
      measurements: Measurements(
        currentA: (data['a'] as num?)?.toDouble() ?? 0.0,
        mvar: (data['mvar'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  /// تسجيل المفتاح في الفهرس العام
  SwitchItem _registerSwitch(SwitchItem item) {
    switches[item.id] = item;
    return item;
  }

  /// 🔄 تبديل حالة المفتاح (Toggle State)
  void toggleSwitch(String switchId) {
    final current = switches[switchId];
    if (current == null) return;

    SwitchState nextState;
    if (current.state == SwitchState.closed) {
      nextState = SwitchState.open;
    } else {
      nextState = SwitchState.closed;
    }

    setSwitchState(switchId, nextState);
  }

  /// 🎯 تعيين حالة محددة للمفتاح
  void setSwitchState(String switchId, SwitchState newState) {
    final current = switches[switchId];
    if (current == null) return;

    final oldState = current.state;
    if (oldState == newState) return;

    current.state = newState;
    switches[switchId] = current.copyWith(state: newState);

    // مزامنة قاطع الخرج للمحول مع قاطع الدخول 11kV المطابق له
    if (switchId == 'CB_SEC_TR4' || switchId == 'CB_11_SEC1_K05') {
      final pair = switchId == 'CB_SEC_TR4' ? 'CB_11_SEC1_K05' : 'CB_SEC_TR4';
      final pItem = switches[pair];
      if (pItem != null && pItem.state != newState) {
        pItem.state = newState;
        switches[pair] = pItem.copyWith(state: newState);
      }
    } else if (switchId == 'CB_SEC_TR3' || switchId == 'CB_11_SEC2_K21') {
      final pair = switchId == 'CB_SEC_TR3' ? 'CB_11_SEC2_K21' : 'CB_SEC_TR3';
      final pItem = switches[pair];
      if (pItem != null && pItem.state != newState) {
        pItem.state = newState;
        switches[pair] = pItem.copyWith(state: newState);
      }
    } else if (switchId == 'CB_SEC_TR2' || switchId == 'CB_11_SEC3_K35') {
      final pair = switchId == 'CB_SEC_TR2' ? 'CB_11_SEC3_K35' : 'CB_SEC_TR2';
      final pItem = switches[pair];
      if (pItem != null && pItem.state != newState) {
        pItem.state = newState;
        switches[pair] = pItem.copyWith(state: newState);
      }
    }

    // تسجيل الحدث في الـ SOE Logger
    eventLogs.insert(
        0,
        EventLogItem(
          timestamp: DateTime.now(),
          switchName: current.name,
          switchTag: current.tag,
          oldState: oldState,
          newState: newState,
          message: 'تغيرت حالة ${current.name} إلى ${newState.arabicName}',
        ));

    // إشعار الواجهة بالتحديث
    switches.refresh();
    lines66kV.refresh();
    transformers.refresh();
    cells11kVSection1.refresh();
    cells11kVSection2.refresh();
    cells11kVSection3.refresh();
  }

  /// 🌐 تبديل وضع المحاكاة / الربط الحي
  void toggleSimulationMode(bool enabled) {
    isSimulationMode.value = enabled;
    if (enabled) {
      _liveDataTimer?.cancel();
      isConnectedToScada.value = false;
    } else {
      startLiveScadaStream();
    }
  }

  /// 📡 بدء سحب البيانات الحية من خادم FastAPI
  void startLiveScadaStream() {
    _liveDataTimer?.cancel();
    _fetchLiveScadaData();
    _liveDataTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchLiveScadaData();
    });
  }

  /// 📥 جلب البيانات وتحديث المفاتيح والقياسات
  Future<void> _fetchLiveScadaData() async {
    try {
      final response = await http.get(Uri.parse(apiBaseUrl.value)).timeout(
            const Duration(seconds: 2),
          );

      if (response.statusCode == 200) {
        isConnectedToScada.value = true;
        final dynamic data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          data.forEach((tag, payload) {
            if (payload is Map<String, dynamic>) {
              final val = payload['value'];
              final type = payload['type'];

              // إذا كانت إشارة حالة (SPS)
              if (type == 'SPS' || val == 0 || val == 1) {
                _updateSwitchFromScada(tag, val);
              }
              // إذا كانت قياسات (Measrmt)
              else if (type == 'Measrmt' && val is num) {
                _updateMeasurementFromScada(tag, val.toDouble());
              }
            }
          });
        }
      } else {
        isConnectedToScada.value = false;
      }
    } catch (e) {
      isConnectedToScada.value = false;
    }
  }

  void _updateSwitchFromScada(String tag, dynamic value) {
    for (var item in switches.values) {
      if (item.tag == tag || tag.contains(item.id)) {
        final state = (value == 1 || value == 1.0 || value == '1')
            ? SwitchState.closed
            : SwitchState.open;
        setSwitchState(item.id, state);
        break;
      }
    }
  }

  void _updateMeasurementFromScada(String tag, double value) {
    for (var line in lines66kV) {
      if (tag.contains(line.id)) {
        line.measurements.currentA = value;
        lines66kV.refresh();
        return;
      }
    }
  }
}
