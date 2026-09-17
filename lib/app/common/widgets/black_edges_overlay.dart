import 'package:flutter/material.dart';

/// ويدجت تظليل حواف الصورة باللون الأسود (Cinematic Vignette & Edge Shading)
/// يترك وسط الصورة واضحاً ونقياً بنسبة 100% مع تلاشي ناعم وتدريجي
/// إلى اللون الأسود في كافة الحواف الأربعة (أعلى، أسفل، يمين، يسار) والزوايا.
class BlackEdgesOverlay extends StatelessWidget {
  const BlackEdgesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. تدرج الحواف العلوية والسفلية
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.50),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.50),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.08, 0.22, 0.78, 0.92, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // 2. تدرج الحواف الجانبية (يمين ويسار)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.90),
                    Colors.black.withValues(alpha: 0.40),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.40),
                    Colors.black.withValues(alpha: 0.90),
                  ],
                  stops: const [0.0, 0.06, 0.18, 0.82, 0.94, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // 3. تدرج بيضاوي للأركان والزوايا (Vignette)
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.05,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x55000000),
                    Color(0xCC000000),
                    Colors.black,
                  ],
                  stops: [0.0, 0.45, 0.72, 0.90, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
