import 'package:flutter/material.dart';

/// حالة المهمة الكهربائية (قاطع، سكينة، أرضي)
enum SwitchState {
  closed, // موصل / مغلق (أحمر)
  open,   // مفصول / مفتوح (أخضر)
  trip,   // عطل / تريب (أصفر)
  unknown // غير معروف / انقطاع إشارة
}

extension SwitchStateExtension on SwitchState {
  String get arabicName {
    switch (this) {
      case SwitchState.closed:
        return 'موصل (CLOSED)';
      case SwitchState.open:
        return 'مفصول (OPEN)';
      case SwitchState.trip:
        return 'تريب / عطل (TRIP)';
      case SwitchState.unknown:
        return 'غير معروف';
    }
  }

  Color get color {
    switch (this) {
      case SwitchState.closed:
        return const Color(0xFFFF3333); // أحمر القياسي للتشغيل المكهرب
      case SwitchState.open:
        return const Color(0xFF00E676); // أخضر للمفصول الآمن
      case SwitchState.trip:
        return const Color(0xFFFFD600); // أصفر للإنذار والتريب
      case SwitchState.unknown:
        return Colors.grey;
    }
  }
}

/// نوع المهمة الكهربائية
enum SwitchType {
  circuitBreaker, // قاطع تيار (CB)
  disconnector,   // سكينة عزل (DS)
  earthSwitch,    // سكينة تأريض (ES)
  busCoupler      // قاطع ربط قضبان
}

/// عنصر مفتاح أو قاطع في الـ SLD
class SwitchItem {
  final String id;
  final String name;
  final String tag;
  final SwitchType type;
  SwitchState state;
  final String? bayId;
  final String? voltageLevel; // 66kV أو 11kV

  SwitchItem({
    required this.id,
    required this.name,
    required this.tag,
    required this.type,
    this.state = SwitchState.closed,
    this.bayId,
    this.voltageLevel,
  });

  SwitchItem copyWith({SwitchState? state}) {
    return SwitchItem(
      id: id,
      name: name,
      tag: tag,
      type: type,
      state: state ?? this.state,
      bayId: bayId,
      voltageLevel: voltageLevel,
    );
  }
}

/// قياسات الطاقة والجهد والتيار
class Measurements {
  double mw;
  double mvar;
  double mva;
  double currentA;
  double? currentPhaseR;
  double? currentPhaseS;
  double? currentPhaseT;
  double? powerFactor;
  double? voltageKv;

  Measurements({
    this.mw = 0.0,
    this.mvar = 0.0,
    this.mva = 0.0,
    this.currentA = 0.0,
    this.currentPhaseR,
    this.currentPhaseS,
    this.currentPhaseT,
    this.powerFactor,
    this.voltageKv,
  });
}

/// نموذج خلية أو خط (Feeder / Bay)
class FeederBay {
  final String id;
  final String name;
  final String code; // مثل K45, K48
  final String voltage; // 66kV أو 11kV
  final String cableSpec; // مثل 1x800 mm2
  final SwitchItem cb; // قاطع الدائرة الرئيسي
  final SwitchItem? lineDs; // سكينة الخط
  final SwitchItem? earthDs; // سكينة التأريض
  final SwitchItem? busDsA; // سكينة بارة 1
  final SwitchItem? busDsB; // سكينة بارة 2
  Measurements measurements;

  FeederBay({
    required this.id,
    required this.name,
    required this.code,
    required this.voltage,
    this.cableSpec = '',
    required this.cb,
    this.lineDs,
    this.earthDs,
    this.busDsA,
    this.busDsB,
    required this.measurements,
  });
}

/// نموذج محول القدرة (Power Transformer)
class TransformerModel {
  final String id;
  final String name; // TR2, TR3, TR4
  final String specs; // 66/11KV 25MVA
  final String manufacturer; // Maco
  int tapPosition; // 19 TAP
  final SwitchItem primaryCb; // قاطع جهة 66kV
  final SwitchItem secondaryCb; // قاطع جهة 11kV
  final SwitchItem? busDsA;
  final SwitchItem? busDsB;
  final SwitchItem? ngrDs;
  final SwitchItem? ngrEs;
  Measurements primaryMeasurements;
  Measurements secondaryMeasurements;

  TransformerModel({
    required this.id,
    required this.name,
    required this.specs,
    required this.manufacturer,
    this.tapPosition = 19,
    required this.primaryCb,
    required this.secondaryCb,
    this.busDsA,
    this.busDsB,
    this.ngrDs,
    this.ngrEs,
    required this.primaryMeasurements,
    required this.secondaryMeasurements,
  });
}

/// سجل أحداث وتشغيل المفاتيح (SOE / Sequence of Events)
class EventLogItem {
  final DateTime timestamp;
  final String switchName;
  final String switchTag;
  final SwitchState oldState;
  final SwitchState newState;
  final String message;

  EventLogItem({
    required this.timestamp,
    required this.switchName,
    required this.switchTag,
    required this.oldState,
    required this.newState,
    required this.message,
  });
}
