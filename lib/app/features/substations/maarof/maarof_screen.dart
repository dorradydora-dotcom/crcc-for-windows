import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'maarof_models.dart';
import 'maarof_controller.dart';
import 'sld_canvas.dart';

/// 🏢 شاشة السينجل لاين دياجرام لمحطة معروف (MAAROUF 66/11 kV)
/// واجهة مراقبة وتحكم تفاعلية (SCADA / HMI) تتكيف تلقائياً مع شاشات الويندوز والموبايل
/// تدعم التكبير والسحب بالفأرة، اختصارات لوحة المفاتيح، واللمس
class MaarofSubstationScreen extends StatefulWidget {
  const MaarofSubstationScreen({super.key});

  @override
  State<MaarofSubstationScreen> createState() => _MaarofSubstationScreenState();
}

class _MaarofSubstationScreenState extends State<MaarofSubstationScreen> {
  late final MaarofController controller;
  late final TransformationController _transformationController;
  final ValueNotifier<bool> _isDragging = ValueNotifier<bool>(false);
  double _lastLayoutWidth = 0;
  double _lastLayoutHeight = 0;

  static const double _canvasW = 1600.0;
  static const double _canvasH = 1180.0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MaarofController());
    _transformationController = TransformationController();

    // 🔄 قفل الشاشة على الوضع الأفقي (Landscape) لأجهزة الموبايل فقط
    if (GetPlatform.isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    // 📐 احتساب مقياس ابتدائي فوري حتى لا يظهر المخطط ضخماً في الفريم الأول
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final size = view.physicalSize / view.devicePixelRatio;
      if (size.width > 0 && size.height > 0) {
        final double w = GetPlatform.isMobile
            ? (size.width > size.height ? size.width : size.height)
            : size.width;
        final double h = (GetPlatform.isMobile
                ? (size.width > size.height ? size.height : size.width)
                : size.height) -
            40.0;
        _fitDiagramToScreen(w, h);
      }
    } catch (_) {}
  }

  void _restoreOrientation() {
    // 🔄 استعادة أوضاع الشاشة الطبيعية للموبايل فقط
    if (GetPlatform.isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _handleExit(BuildContext context) {
    _restoreOrientation();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.back();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _isDragging.dispose();
    // 🔄 استعادة أوضاع الشاشة الطبيعية
    _restoreOrientation();
    super.dispose();
  }

  /// 📐 احتساب المقياس وتوسيط المخطط تلقائياً ليلائم الشاشة بالكامل بأصغر حجم مناسب
  void _fitDiagramToScreen(double viewportWidth, double viewportHeight) {
    if (viewportWidth <= 0 || viewportHeight <= 0) return;

    // هوامش مريحة لعرض كامل المحطة دون اقتصاص
    final double availW = viewportWidth - 32.0;
    final double availH = viewportHeight - 20.0;

    final double scaleX = availW / _canvasW;
    final double scaleY = availH / _canvasH;
    final double calculatedScale = (scaleX < scaleY ? scaleX : scaleY);
    final double finalScale = calculatedScale.clamp(0.10, 1.2);

    final double scaledW = _canvasW * finalScale;
    final double scaledH = _canvasH * finalScale;
    final double dx = (viewportWidth - scaledW) / 2.0;
    final double dy = (viewportHeight - scaledH) / 2.0;

    _transformationController.value =
        Matrix4.diagonal3Values(finalScale, finalScale, 1.0)
          ..setTranslationRaw(dx > 0 ? dx : 0.0, dy > 0 ? dy : 0.0, 0.0);
  }

  /// 🔍 تكبير المخطط خطوة واحدة
  void _zoomIn() {
    _zoomBy(1.20);
  }

  /// 🔍 تصغير المخطط خطوة واحدة
  void _zoomOut() {
    _zoomBy(0.833);
  }

  void _zoomBy(double factor) {
    if (_lastLayoutWidth <= 0 || _lastLayoutHeight <= 0) return;
    _zoomAt(factor, Offset(_lastLayoutWidth / 2.0, _lastLayoutHeight / 2.0));
  }

  void _zoomAt(double factor, Offset focalPoint) {
    final Matrix4 currentMatrix = _transformationController.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    final double targetScale = (currentScale * factor).clamp(0.10, 5.0);
    final double actualFactor = targetScale / currentScale;

    if ((actualFactor - 1.0).abs() < 0.001) return;

    final Matrix4 translationToCenter =
        Matrix4.translationValues(-focalPoint.dx, -focalPoint.dy, 0.0);
    final Matrix4 scaleMatrix =
        Matrix4.diagonal3Values(actualFactor, actualFactor, 1.0);
    final Matrix4 translationBack =
        Matrix4.translationValues(focalPoint.dx, focalPoint.dy, 0.0);

    final Matrix4 newMatrix =
        translationBack * scaleMatrix * translationToCenter * currentMatrix;
    _transformationController.value = newMatrix;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: Colors.black,
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
                    _fitDiagramToScreen(_lastLayoutWidth, _lastLayoutHeight);
                  }
                });
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isDragging,
                      builder: (context, isDragging, childWidget) {
                        return MouseRegion(
                          cursor: isDragging
                              ? SystemMouseCursors.grabbing
                              : SystemMouseCursors.grab,
                          child: childWidget,
                        );
                      },
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e) {
                          if (e.buttons == kPrimaryMouseButton) {
                            _isDragging.value = true;
                          }
                        },
                        onPointerUp: (_) {
                          _isDragging.value = false;
                        },
                        onPointerCancel: (_) {
                          _isDragging.value = false;
                        },
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            final double delta = pointerSignal.scrollDelta.dy;
                            if (delta != 0) {
                              final double factor = delta < 0 ? 1.15 : 0.87;
                              _zoomAt(factor, pointerSignal.localPosition);
                            }
                          }
                        },
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          minScale: 0.10,
                          maxScale: 5.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          panAxis: PanAxis.free,
                          interactionEndFrictionCoefficient: 0.005,
                          trackpadScrollCausesScale: true,
                          constrained: false,
                          child: MaarofSldCanvas(
                            onSoeTap: () => _showEventsDialog(context),
                            onNetTap: () => _showApiSettingsDialog(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 🎛️ شريط التحكم بالزووم الطافي (Floating Zoom Controller)
                  Positioned(
                    bottom: 12.h,
                    left: 14.w,
                    child: _buildFloatingZoomControls(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // ⌨️ دعم اختصارات لوحة المفاتيح في بيئة الويندوز / سطح المكتب
    if (!GetPlatform.isMobile) {
      content = CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              _handleExit(context),
          const SingleActivator(LogicalKeyboardKey.equal): _zoomIn,
          const SingleActivator(LogicalKeyboardKey.add): _zoomIn,
          const SingleActivator(LogicalKeyboardKey.numpadAdd): _zoomIn,
          const SingleActivator(LogicalKeyboardKey.minus): _zoomOut,
          const SingleActivator(LogicalKeyboardKey.numpadSubtract): _zoomOut,
          const SingleActivator(LogicalKeyboardKey.digit0): () =>
              _fitDiagramToScreen(_lastLayoutWidth, _lastLayoutHeight),
          const SingleActivator(LogicalKeyboardKey.numpad0): () =>
              _fitDiagramToScreen(_lastLayoutWidth, _lastLayoutHeight),
          const SingleActivator(LogicalKeyboardKey.home): () =>
              _fitDiagramToScreen(_lastLayoutWidth, _lastLayoutHeight),
        },
        child: Focus(
          autofocus: true,
          child: content,
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _restoreOrientation();
        }
      },
      child: content,
    );
  }

  /// 🎛️ شريط أزرار تكبير وتصغير المحطة العائم
  Widget _buildFloatingZoomControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0C101C).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر تكبير +
          _buildZoomButton(
            icon: Icons.add_rounded,
            tooltip: 'تكبير المحطة (+)',
            onPressed: _zoomIn,
          ),
          // زر تصغير -
          _buildZoomButton(
            icon: Icons.remove_rounded,
            tooltip: 'تصغير المحطة (-)',
            onPressed: _zoomOut,
          ),
          // فاصل رأسي
          Container(
            height: 16.h,
            width: 1,
            color: Colors.white24,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
          ),
          // زر ملاءمة وتوسيط كامل المحطة
          _buildZoomButton(
            icon: Icons.fullscreen_exit_rounded,
            tooltip: 'ملاءمة وتوسيط كامل المحطة',
            iconColor: Colors.cyanAccent,
            onPressed: () =>
                _fitDiagramToScreen(_lastLayoutWidth, _lastLayoutHeight),
          ),
          // نسبة التكبير الحالية
          AnimatedBuilder(
            animation: _transformationController,
            builder: (context, _) {
              final double scale =
                  _transformationController.value.getMaxScaleOnAxis();
              final int pct = (scale * 100).round();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.h),
      icon: Icon(icon, size: 16.sp, color: iconColor),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  /// 🔝 الهيدر العلوي لشاشة السكادا مع مفتاح المحاكاة وسجل الأحداث
  PreferredSizeWidget _buildScadaHeader(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0C0F1A),
      elevation: 1,
      toolbarHeight: 38.h,
      automaticallyImplyLeading: false,
      leadingWidth: 42.w,
      leading: IconButton(
        padding: EdgeInsets.zero,
        tooltip: 'خروج من محطة معروف (ESC)',
        icon: Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFFF2222).withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.65),
              width: 1.0,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 15.sp,
            color: const Color(0xFFFF5252),
          ),
        ),
        onPressed: () => _handleExit(context),
      ),
      titleSpacing: 0,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'معروف',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37),
              ),
            ),
            SizedBox(width: 8.w),
            Obx(() => Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isConnectedToScada.value
                        ? Colors.greenAccent
                        : (controller.isSimulationMode.value
                            ? Colors.cyanAccent
                            : Colors.orangeAccent),
                  ),
                )),
            SizedBox(width: 6.w),
            Text(
              'MAAROUF',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2.r),
              ),
              child: Text('Comm',
                  style: TextStyle(fontSize: 7.sp, color: Colors.white70)),
            ),
          ],
        ),
      ),
      actions: [
        // زر إظهار/إخفاء أكواد السكاكين والمفاتيح (Dev Mode)
        Obx(() => IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 26.w, minHeight: 26.h),
              icon: Icon(
                Icons.tag_rounded,
                size: 14.sp,
                color: controller.showDeviceCodes.value
                    ? const Color(0xFFFFD54F)
                    : Colors.white38,
              ),
              tooltip: controller.showDeviceCodes.value
                  ? 'إخفاء أكواد السكاكين والمفاتيح'
                  : 'إظهار أكواد السكاكين والمفاتيح (Dev Mode)',
              onPressed: () => controller.toggleDeviceCodes(),
            )),
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
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0F1A),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.65,
                    child: Switch(
                      value: controller.isSimulationMode.value,
                      activeTrackColor:
                          Colors.cyanAccent.withValues(alpha: 0.6),
                      inactiveThumbColor: Colors.greenAccent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => controller.toggleSimulationMode(val),
                    ),
                  ),
                  Text(
                    controller.isSimulationMode.value ? 'محاكاة' : 'بث حي',
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      color: controller.isSimulationMode.value
                          ? Colors.cyanAccent
                          : Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
            )),
        // زر إعدادات رابط الـ API مصغر
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 26.w, minHeight: 26.h),
          icon: Icon(Icons.settings, size: 13.sp, color: Colors.white70),
          tooltip: 'إعدادات الاتصال بالـ API',
          onPressed: () => _showApiSettingsDialog(context),
        ),
        SizedBox(width: 6.w),
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
