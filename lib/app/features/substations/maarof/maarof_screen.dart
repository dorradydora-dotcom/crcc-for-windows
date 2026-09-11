import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'maarof_models.dart';
import 'maarof_controller.dart';
import 'sld_canvas.dart';

/// 🏢 شاشة السينجل لاين دياجرام لمحطة معروف (MAAROUF 66/11 kV)
/// تعمل بملء الشاشة في الوضع الأفقي (Landscape) بنمط المحاكيات والألعاب
class MaarofSubstationScreen extends StatefulWidget {
  const MaarofSubstationScreen({super.key});

  @override
  State<MaarofSubstationScreen> createState() => _MaarofSubstationScreenState();
}

class _MaarofSubstationScreenState extends State<MaarofSubstationScreen> {
  late final MaarofController controller;
  late final TransformationController _transformationController;
  double _lastLayoutWidth = 0;
  double _lastLayoutHeight = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MaarofController());
    _transformationController = TransformationController();

    // 🔄 قفل الشاشة على الوضع الأفقي (Landscape) بنمط شاشات المراقبة
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    // 🔄 استعادة أوضاع الشاشة الطبيعية
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  double _fitScale = 0.55;

  /// 📐 احتساب المقياس وتوسيط المخطط تلقائياً ليلائم الشاشة بالكامل بأصغر حجم مناسب
  void _fitDiagramToScreen(double viewportWidth, double viewportHeight) {
    if (viewportWidth <= 0 || viewportHeight <= 0) return;
    const double canvasW = 1350.0;
    const double canvasH = 590.0;

    final double scaleX = viewportWidth / canvasW;
    final double scaleY = viewportHeight / canvasH;
    final double calculatedScale = (scaleX < scaleY ? scaleX : scaleY) * 0.98;
    final double finalScale = calculatedScale.clamp(0.1, 2.0);

    if (_fitScale != finalScale && mounted) {
      setState(() {
        _fitScale = finalScale;
      });
    }

    final double dx = (viewportWidth - canvasW * finalScale) / 2;
    final double dy = (viewportHeight - canvasH * finalScale) / 2;

    _transformationController.value = Matrix4.diagonal3Values(finalScale, finalScale, 1.0)
      ..setTranslationRaw(dx > 0 ? dx : 0.0, dy > 0 ? dy : 0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B12),
      appBar: _buildScadaHeader(context),
      body: SafeArea(
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if ((_lastLayoutWidth != constraints.maxWidth ||
                      _lastLayoutHeight != constraints.maxHeight) &&
                  constraints.maxWidth > 0 &&
                  constraints.maxHeight > 0) {
                _lastLayoutWidth = constraints.maxWidth;
                _lastLayoutHeight = constraints.maxHeight;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _fitDiagramToScreen(
                        _lastLayoutWidth, _lastLayoutHeight);
                  }
                });
              }

              return InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                minScale: _fitScale * 0.95,
                maxScale: 5.0,
                constrained: false,
                child: MaarofSldCanvas(),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 🔝 الهيدر العلوي بنمط شاشات الـ SCADA العريضة بحجم مدمج وأنيق
  PreferredSizeWidget _buildScadaHeader(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF141724),
      elevation: 2,
      toolbarHeight: 36.h,
      automaticallyImplyLeading: true,
      titleSpacing: 0,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أرقام التليفونات الداخلية جهة اليسار
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0D18),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('IP-TEL1: 111400 | IP-TEL2: 211400',
                      style: TextStyle(
                          fontSize: 6.5.sp,
                          color: Colors.white70,
                          fontFamily: 'monospace')),
                  Text('H-Line: 907018 | EXT: 25753272',
                      style: TextStyle(
                          fontSize: 6.5.sp,
                          color: Colors.white70,
                          fontFamily: 'monospace')),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // اسم المحطة ولمبة الاتصال في المنتصف
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'معروف',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.isConnectedToScada.value
                                ? Colors.greenAccent
                                : (controller.isSimulationMode.value
                                    ? Colors.cyanAccent
                                    : Colors.orangeAccent),
                            boxShadow: [
                              BoxShadow(
                                color: controller.isConnectedToScada.value
                                    ? Colors.greenAccent.withAlpha(180)
                                    : Colors.cyanAccent.withAlpha(180),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        )),
                    SizedBox(width: 4.w),
                    Text(
                      'MAAROUF',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Text('Comm',
                          style: TextStyle(
                              fontSize: 6.5.sp, color: Colors.white70)),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(width: 8.w),

            // أرقام الطوارئ والموبايل جهة اليمين
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0D18),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('O : 01206640387',
                      style: TextStyle(
                          fontSize: 6.5.sp,
                          color: Colors.orangeAccent,
                          fontFamily: 'monospace')),
                  Text('O : 01206640457',
                      style: TextStyle(
                          fontSize: 6.5.sp,
                          color: Colors.orangeAccent,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // زر سجل الأحداث والعمليات SOE مصغر
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 26.w, minHeight: 26.h),
          icon: Icon(Icons.receipt_long_rounded,
              size: 13.sp, color: Colors.amberAccent),
          tooltip: 'سجل الأحداث والعمليات (SOE)',
          onPressed: () => _showEventsDialog(context),
        ),
        // مفتاح تبديل وضع المحاكاة / الربط الحي مصغر
        Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0F1A),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white12, width: 0.6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.55,
                    child: Switch(
                      value: controller.isSimulationMode.value,
                      activeTrackColor: Colors.cyanAccent.withAlpha(160),
                      inactiveThumbColor: Colors.greenAccent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => controller.toggleSimulationMode(val),
                    ),
                  ),
                  Text(
                    controller.isSimulationMode.value ? 'محاكاة' : 'بث حي',
                    style: TextStyle(
                      fontSize: 7.5.sp,
                      color: controller.isSimulationMode.value
                          ? Colors.cyanAccent
                          : Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 3.w),
                ],
              ),
            )),
        // زر ضبط وتصغير العرض لملء الشاشة وتوسيط المحطة مصغر
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 26.w, minHeight: 26.h),
          icon: Icon(Icons.fullscreen_exit_rounded,
              size: 14.sp, color: Colors.cyanAccent),
          tooltip: 'إعادة ضبط وتوسيط المحطة',
          onPressed: () =>
              _fitDiagramToScreen(_lastLayoutWidth, _lastLayoutHeight),
        ),
        // زر إعدادات رابط الـ API مصغر
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 26.w, minHeight: 26.h),
          icon: Icon(Icons.settings, size: 12.sp, color: Colors.white70),
          tooltip: 'إعدادات الاتصال بالـ API',
          onPressed: () => _showApiSettingsDialog(context),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  /// 📋 نافذة عرض سجل الأحداث (SOE Log Dialog)
  void _showEventsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF181B29),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Container(
          width: 550.w,
          height: 380.h,
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('سجل الأحداث والعمليات (SOE / Events Logger)',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white54, size: 16.sp),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: Obx(() {
                  if (controller.eventLogs.isEmpty) {
                    return Center(
                      child: Text('لا توجد عمليات مسجلة حتى الآن.',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 10.sp)),
                    );
                  }
                  return ListView.separated(
                    itemCount: controller.eventLogs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, idx) {
                      final log = controller.eventLogs[idx];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 6.h, horizontal: 4.w),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(log.timestamp),
                              style: TextStyle(
                                  fontSize: 8.5.sp,
                                  color: Colors.white54,
                                  fontFamily: 'monospace'),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(log.message,
                                  style: TextStyle(
                                      fontSize: 9.5.sp,
                                      color: log.newState.color)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ⚙️ نافذة تعديل عنوان الـ API
  void _showApiSettingsDialog(BuildContext context) {
    final textController =
        TextEditingController(text: controller.apiBaseUrl.value);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        title: Text('إعدادات الاتصال بسيرفر الإسكادا',
            style: TextStyle(color: Colors.white, fontSize: 12.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل رابط الـ Endpoint الخاص بخادم الـ FastAPI لجلب القراءات اللحظية:',
              style: TextStyle(color: Colors.white70, fontSize: 9.5.sp),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: textController,
              style: TextStyle(
                  color: Colors.cyanAccent,
                  fontFamily: 'monospace',
                  fontSize: 10.sp),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF141724),
                border: OutlineInputBorder(),
                hintText: 'http://127.0.0.1:8000/api/v1/telemetry/live',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء',
                style: TextStyle(color: Colors.white54, fontSize: 10.sp)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () {
              controller.apiBaseUrl.value = textController.text.trim();
              Navigator.of(context).pop();
              Get.snackbar('تم الحفظ', 'تم تحديث رابط الـ API بنجاح',
                  backgroundColor: const Color(0xFF1E2235),
                  colorText: Colors.white);
            },
            child: Text('حفظ وتطبيق',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp)),
          )
        ],
      ),
    );
  }
}
