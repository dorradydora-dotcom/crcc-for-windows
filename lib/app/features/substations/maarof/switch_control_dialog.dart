import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'maarof_models.dart';
import 'maarof_controller.dart';

/// 🕹️ نافذة التحكم التفاعلية بالمفتاح / القاطع
class SwitchControlDialog extends StatelessWidget {
  final SwitchItem switchItem;
  final MaarofController controller = Get.find<MaarofController>();

  SwitchControlDialog({super.key, required this.switchItem});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B1E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(16.r),
        child: Obx(() {
          final current = controller.switches[switchItem.id] ?? switchItem;
          final state = current.state;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الهيدر مع أيقونة وزر الإغلاق
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: state.color.withAlpha(40),
                          shape: BoxShape.circle,
                          border: Border.all(color: state.color, width: 1.5),
                        ),
                        child: Icon(
                          _getIconForType(current.type),
                          color: state.color,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'محطة معروف | ${current.voltageLevel ?? ""}',
                            style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white54, size: 16.sp),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 16),

              // كارت معلومات الإسكادا والتاج
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF121522),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SCADA Tag Reference:',
                        style: TextStyle(color: Colors.white38, fontSize: 8.5.sp)),
                    SizedBox(height: 2.h),
                    Text(
                      current.tag,
                      style: TextStyle(
                        color: const Color(0xFF00E5FF),
                        fontSize: 9.sp,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الحالة التشغيلية:',
                            style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: state.color.withAlpha(50),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: state.color),
                          ),
                          child: Text(
                            state.arabicName,
                            style: TextStyle(
                              color: state.color,
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),
              Text(
                'أوامر التحكم والتشغيل (Actions):',
                style: TextStyle(color: Colors.white70, fontSize: 10.5.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),

              // أزرار التحكم
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                      ),
                      onPressed: state == SwitchState.closed
                          ? null
                          : () {
                              controller.setSwitchState(current.id, SwitchState.closed);
                            },
                      icon: Icon(Icons.flash_on, size: 14.sp),
                      label: Text('توصيل (CLOSE)', style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                      ),
                      onPressed: state == SwitchState.open
                          ? null
                          : () {
                              controller.setSwitchState(current.id, SwitchState.open);
                            },
                      icon: Icon(Icons.flash_off, size: 14.sp),
                      label: Text('فصل (OPEN)', style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFD600),
                  side: const BorderSide(color: Color(0xFFFFD600)),
                  padding: EdgeInsets.symmetric(vertical: 7.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                ),
                onPressed: () {
                  controller.setSwitchState(current.id, SwitchState.trip);
                },
                icon: Icon(Icons.warning_amber_rounded, size: 14.sp),
                label: Text('محاكاة عطل وتريب (Simulate TRIP)',
                    style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }),
      ),
    );
  }

  IconData _getIconForType(SwitchType type) {
    switch (type) {
      case SwitchType.circuitBreaker:
        return Icons.crop_square_sharp;
      case SwitchType.disconnector:
        return Icons.linear_scale;
      case SwitchType.earthSwitch:
        return Icons.vertical_align_bottom;
      case SwitchType.busCoupler:
        return Icons.sync_alt;
    }
  }
}
