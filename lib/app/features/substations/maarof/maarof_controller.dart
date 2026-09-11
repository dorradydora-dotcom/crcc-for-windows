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
  final RxDouble bus1AVoltage = 63.96.obs;
  final RxDouble bus2AVoltage = 63.59.obs;
  final RxDouble bus1BVoltage = 64.19.obs;
  final RxDouble bus2BVoltage = 64.29.obs;

  // ⚡ قضبان التوزيع 11kV
  final RxDouble bus2Voltage = 10.55.obs;
  final RxDouble bus3Voltage = 10.61.obs;
  final RxDouble bus4Voltage = 10.50.obs;

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
      {'id': 'AZBAKIA', 'name': 'AZBAKIA', 'code': 'K40', 'cable': '1 X 800 mm²', 'mw': 0.0, 'mvar': 0.1, 'mva': 0.1, 'a': 2.0, 'bus': 'A'},
      {'id': 'SAYEDA1', 'name': 'SAYEDA1', 'code': 'K41', 'cable': '', 'mw': 13.0, 'mvar': 3.4, 'mva': 13.5, 'a': 122.7, 'bus': 'A'},
      {'id': 'NSABT3', 'name': 'NSABT3', 'code': 'K42', 'cable': '', 'mw': -23.8, 'mvar': -7.6, 'mva': 25.0, 'a': 227.0, 'bus': 'A'},
      {'id': 'NSABT1', 'name': 'NSABT1', 'code': 'K43', 'cable': '', 'mw': -22.5, 'mvar': -11.6, 'mva': 25.4, 'a': 228.4, 'bus': 'B'},
      {'id': 'NSABT2', 'name': 'NSABT2', 'code': 'K44', 'cable': '1 X 800 mm²', 'mw': 0.0, 'mvar': 0.0, 'mva': 0.0, 'a': 231.2, 'bus': 'B'},
      {'id': 'SAYEDA2', 'name': 'SAYEDA2', 'code': 'K45', 'cable': '', 'mw': 0.0, 'mvar': 0.0, 'mva': 14.1, 'a': 123.0, 'bus': 'B'},
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
        'pri_mw': 9.4, 'pri_mvar': 2.8, 'pri_mva': 9.8, 'pri_a': 88.7, 'pri_pf': 0.99,
        'sec_mw': -8.9, 'sec_mvar': -1.4, 'sec_mva': 9.1, 'sec_a': 542.5, 'sec_pf': 1.0,
      },
      {
        'id': 'TR3',
        'name': 'TR3',
        'tap': 19,
        'pri_mw': 11.0, 'pri_mvar': 2.4, 'pri_mva': 11.4, 'pri_a': 102.0, 'pri_pf': 0.98,
        'sec_mw': -11.0, 'sec_mvar': -1.9, 'sec_mva': 11.1, 'sec_a': 615.0, 'sec_pf': 0.99,
      },
      {
        'id': 'TR4',
        'name': 'TR4',
        'tap': 19,
        'pri_mw': 10.9, 'pri_mvar': 3.1, 'pri_mva': 11.4, 'pri_a': 108.1, 'pri_pf': 0.98,
        'sec_mw': -7.0, 'sec_mvar': -2.0, 'sec_mva': 7.2, 'sec_a': 402.5, 'sec_pf': 0.98,
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
        state: SwitchState.closed,
        voltageLevel: '66kV',
      ));
      final busDsB = _registerSwitch(SwitchItem(
        id: 'DS_BUS_B_$id',
        name: 'سكينة بارة B محول $id',
        tag: '[PCS-9710-TU1]MAAROUF_${id}_BUS_DS_B',
        type: SwitchType.disconnector,
        state: SwitchState.open,
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
        specs: '66/11KV 25MVA',
        manufacturer: 'Maco',
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

    // 4. خلايا الـ 11kV - القسم 1 (BB2 - اليسار)
    final sec1Feeders = [
      {'name': 'BUS COUPLER (2-4)', 'code': 'K01', 'a': 0.0, 'isCoupler': true},
      {'name': 'ثبات (2)', 'code': 'K02', 'a': 110.0},
      {'name': 'الجلاء الجديد', 'code': 'K03', 'a': 74.0},
      {'name': 'المحكمة', 'code': 'K04', 'a': 15.0},
      {'name': 'خروج كشك الفلكى', 'code': 'K05', 'a': 98.0},
      {'name': 'خروج كشك هدى شعراوى (1)', 'code': 'K06', 'a': 105.0},
      {'name': 'سينما ميامى', 'code': 'K07', 'a': 55.0},
      {'name': 'هدى شعراوى (2)', 'code': 'K08', 'a': 45.0},
      {'name': 'مسرح الهوسابير', 'code': 'K09', 'a': 82.0},
      {'name': 'MEASUREMENT CELL (1)', 'code': 'K10', 'a': 0.0, 'isCap': true, 'mvar': 1.6},
      {'name': 'BUS RISER (1-3)', 'code': 'K11', 'a': 0.0, 'isRiser': true},
    ];

    for (var f in sec1Feeders) {
      cells11kVSection1.add(_create11kVFeeder(f, 'SEC1'));
    }

    // 5. خلايا الـ 11kV - القسم 2 (BB3 - الوسط)
    final sec2Feeders = [
      {'name': 'BUS COUPLER (1-3)', 'code': 'K20', 'a': 0.0, 'isCoupler': true},
      {'name': 'MEASUREMENT CELL (3)', 'code': 'K21', 'a': 0.0, 'isCap': true, 'mvar': 1.6},
      {'name': 'فرنسية (1)', 'code': 'K22', 'a': 110.0},
      {'name': 'فرنسية (2)', 'code': 'K23', 'a': 152.0},
      {'name': 'كشك سليم', 'code': 'K24', 'a': 105.0},
      {'name': 'كشك رشدى', 'code': 'K25', 'a': 2.0},
      {'name': 'طلمبات مياه شبرا', 'code': 'K26', 'a': 88.0},
      {'name': 'عمارة المحامين (2)', 'code': 'K27', 'a': 74.7},
      {'name': 'طلمبات رمسيس و الجلاء (2)', 'code': 'K28', 'a': 58.0},
      {'name': 'طلمبات رمسيس و الجلاء (1)', 'code': 'K29', 'a': 115.0},
    ];

    for (var f in sec2Feeders) {
      cells11kVSection2.add(_create11kVFeeder(f, 'SEC2'));
    }

    // 6. خلايا الـ 11kV - القسم 3 (BB4 - اليمين)
    final sec3Feeders = [
      {'name': 'BUS RISER (3-4)', 'code': 'K30', 'a': 0.0, 'isRiser': true},
      {'name': 'BUS COUPLER (3-4)', 'code': 'K31', 'a': 0.0, 'isCoupler': true},
      {'name': 'الشركات', 'code': 'K32', 'a': 115.0},
      {'name': 'الصرف المغطى', 'code': 'K33', 'a': 130.0},
      {'name': 'المعهد الفنى', 'code': 'K34', 'a': 150.0},
      {'name': 'البوستة', 'code': 'K35', 'a': 47.0},
      {'name': 'سنترال الأوبرا', 'code': 'K36', 'a': 31.0},
      {'name': 'سينما كايرو', 'code': 'K37', 'a': 31.0},
      {'name': 'الفردوس (2)', 'code': 'K38', 'a': 45.0},
      {'name': 'الفردوس (1)', 'code': 'K39', 'a': 220.0},
      {'name': 'كشك 23', 'code': 'K40', 'a': 205.0},
      {'name': 'خروج كشك الفردوس (1)', 'code': 'K41', 'a': 68.0},
      {'name': 'خروج كشك الفردوس (2)', 'code': 'K42', 'a': 0.0, 'isCap': true, 'mvar': 6.0},
      {'name': 'MEASUREMENT CELL (4)', 'code': 'K43', 'a': 0.0},
      {'name': 'BUS RISER (2-4)', 'code': 'K44', 'a': 0.0, 'isRiser': true},
    ];

    for (var f in sec3Feeders) {
      cells11kVSection3.add(_create11kVFeeder(f, 'SEC3'));
    }
  }

  /// مساعد لإنشاء وتسجيل خلايا 11kV
  FeederBay _create11kVFeeder(Map<String, dynamic> data, String prefix) {
    final code = data['code'] as String;
    final name = data['name'] as String;
    final id = '${prefix}_$code';

    final cb = _registerSwitch(SwitchItem(
      id: 'CB_11_$id',
      name: 'قاطع $name ($code)',
      tag: '[PCS-9710-TU1]MAAROUF_11KV_${code}_CB',
      type: SwitchType.circuitBreaker,
      state: SwitchState.closed,
      voltageLevel: '11kV',
    ));

    final earth = _registerSwitch(SwitchItem(
      id: 'ES_11_$id',
      name: 'أرضي $name ($code)',
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

    // تسجيل الحدث في الـ SOE Logger
    eventLogs.insert(0, EventLogItem(
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
