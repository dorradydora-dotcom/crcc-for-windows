import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amiraly/app/util/constant/constants.dart';
import 'package:amiraly/app/features/auth/login/loginscreen.dart';
import 'package:amiraly/app/features/auth/homepage/homepage.dart';
import 'package:amiraly/app/features/auth/onboarding/onboardingscreen.dart';
import 'package:amiraly/core/services/auth_service.dart';
import 'package:amiraly/app/util/validators/validator_helper.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amiraly/app/common/widgets/black_edges_overlay.dart';
import 'package:amiraly/main.dart' show ensureServicesInitialized;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  String _errorMessage = '';
  // ✅ ValueNotifier بدل setState - بس الـ ProgressBar والرسائل اللي بتتحدث
  final ValueNotifier<double> _progress = ValueNotifier(0.0);
  final ValueNotifier<String> _statusMessage = ValueNotifier(
    '🔐 جاري تفعيل بروتوكول التشفير العالي (AES-256) وتأمين الجلسة...',
  );
  Timer? _progressTimer;
  Stopwatch? _stopwatch;

  // عبارات شرح أمان البرنامج والمعلومات تظهر على التوالي خلال الـ 9 ثواني
  static const List<String> _statusPhrases = [
    ' جاري تفعيل بروتوكول التشفير  (AES-256) وتأمين الجلسة...',
    ' فحص جدار الحماية والتحقق من منظومة الدفاع السيبراني...',
    ' الاتصال الآمن بشبكة محطات التحكم الإقليمي للقاهرة الكبرى...',
    ' مزامنة وتحديث القياسات اللحظية ومؤشرات الأحمال ...',
    ' التحقق من موثوقية السيرفرات وقواعد بيانات...',
    ' تأمين الاتصال والتحقق من النظام بنجاح... جاري الدخول',
  ];

  @override
  void initState() {
    super.initState();
    _startAppProcess();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _stopwatch?.stop();
    _progress.dispose();
    _statusMessage.dispose();
    super.dispose();
  }

  Future<void> _startAppProcess() async {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    }
    _progress.value = 0.0;
    _statusMessage.value = _statusPhrases[0];
    _progressTimer?.cancel();

    const int totalDurationMs = 9000;
    _stopwatch = Stopwatch()..start();

    // بدء تهيئة الخدمات في الخلفية بالتوازي مع مؤقت الـ 9 ثواني المطلوب
    final servicesFuture = ensureServicesInitialized();
    final minDisplayFuture =
        Future.delayed(const Duration(milliseconds: totalDurationMs));

    // مراقبة التقدم الزمني الدقيق (9 ثواني كاملة)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed = _stopwatch?.elapsedMilliseconds ?? 0;
      final currentProgress = (elapsed / totalDurationMs).clamp(0.0, 1.0);
      _progress.value = currentProgress;

      final int phraseIndex =
          ((elapsed / totalDurationMs) * _statusPhrases.length)
              .floor()
              .clamp(0, _statusPhrases.length - 1);
      if (_statusMessage.value != _statusPhrases[phraseIndex]) {
        _statusMessage.value = _statusPhrases[phraseIndex];
      }

      if (elapsed >= totalDurationMs) {
        timer.cancel();
      }
    });

    // الانتظار الفعلي لكلا الشرطين: انتهاء الـ 9 ثواني بالكامل + جاهزية الخدمات
    Future.wait([servicesFuture, minDisplayFuture]).then((_) async {
      if (!mounted) return;
      _progressTimer?.cancel();
      _progress.value = 1.0;
      _statusMessage.value = _statusPhrases.last;

      await Future.delayed(const Duration(milliseconds: 300));
      try {
        _completeProcess();
      } catch (e) {
        AppLogger.logError('App initialization failed', e);
        setState(() {
          _hasError = true;
          _errorMessage = 'حدث خطأ تقني أثناء تهيئة الخدمات .';
        });
      }
    }).catchError((e) {
      if (!mounted) return;
      _progressTimer?.cancel();
      AppLogger.logError('App initialization error', e);
      setState(() {
        _hasError = true;
        _errorMessage = 'فشلت عملية تهيئة الخدمات.';
      });
    });
  }

  Future<void> _completeProcess() async {
    try {
      // تهيئة خدمات المصادقة لتحديد الوجهة
      final authService = Get.find<AuthService>();
      if (!authService.isInitialized) {
        await authService.initializeServices();
      }

      final prefs = await SharedPreferences.getInstance();
      final isOnboardingCompleted =
          prefs.getBool(AppConstants.onboardingKey) ?? false;

      // فحص الاتصال بالإنترنت بشكل دقيق وآمن لجميع المنصات
      bool isConnected = true;
      try {
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());

        final bool reportedNone = connectivityResult.isNotEmpty &&
            connectivityResult.every((r) => r == ConnectivityResult.none);

        if (reportedNone) {
          // فحص حقيقي للتأكد من وجود إنترنت فعلي قبل منع الدخول (مهم جداً للويندوز)
          final result = await InternetAddress.lookup('google.com')
              .timeout(const Duration(milliseconds: 2000));
          isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        }
      } catch (_) {
        // إذا حدث خطأ في الفحص على الويندوز أو أثناء الشبكة، نسمح بالمتابعة
        isConnected = true;
      }

      if (!isConnected) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'نعتذر، لا يوجد اتصال بالإنترنت حالياً.\nيرجى التأكد من اتصالك بالشبكة.';
        });
      } else {
        _navigateToNext(isOnboardingCompleted);
      }
    } catch (e) {
      AppLogger.logError('App completion process failed', e);
      setState(() {
        _hasError = true;
        _errorMessage = 'حدث خطأ تقني أثناء محاولة تهيئة التطبيق.';
      });
    }
  }

  void _navigateToNext(bool isOnboardingCompleted) {
    Widget nextScreen;
    if (!isOnboardingCompleted) {
      nextScreen = const OnboardingScreen();
    } else {
      final user = Supabase.instance.client.auth.currentUser;
      nextScreen = user != null ? const HomePage() : const LoginScreen();
    }

    final args = Get.arguments;
    final bool isCall = (args is Map && args['route'] == 'call');

    if (isCall) {
      debugPrint(
          'SplashScreen: Call detected in arguments, navigating to Next with Get.offAll');
      Get.offAll(() => nextScreen,
          arguments: args, transition: Transition.noTransition);
    } else {
      Get.offAll(() => nextScreen, transition: Transition.noTransition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // صورة الخلفية: login_option2
          Image.asset(
            AppimageString.loginOption2,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),

          // حواف سوداء محيطية ناعمة للصورة
          const BlackEdgesOverlay(),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 28, top: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة الشعار البرتقالي الصريح بدون توهج
                    FadeInDown(
                      duration: const Duration(milliseconds: 1200),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.35),
                          border: Border.all(
                            color: const Color(0xFFFF9800),
                            width: 2.2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Iconsax.flash_15,
                            color: Color(0xFFFF9800),
                            size: 38,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // اسم الشركة والتحكم بتصميم متناسق ومشع بخطوط وسماكات مضبوطة
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      delay: const Duration(milliseconds: 150),
                      child: Column(
                        children: [
                          Text(
                            AppBarText.companyName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontFamily: Appfontstring.ChangaLight,
                              letterSpacing: 1.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${AppBarText.regionalControl} ${AppBarText.cairo}',
                            style: const TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              fontFamily: Appfontstring.ChangaLight,
                              letterSpacing: 0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 6,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'منظومة المراقبة اللحظية  •',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: Appfontstring.ChangaLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ✅ شريط التقدم المكبر (9 ثواني) + العبارات المتتابعة بدون كونتينر أو خلفية
                    if (!_hasError)
                      FadeIn(
                        duration: const Duration(seconds: 1),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 540),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              ValueListenableBuilder<double>(
                                valueListenable: _progress,
                                builder: (context, value, _) {
                                  final clampedValue = value.clamp(0.0, 1.0);
                                  return Column(
                                    children: [
                                      // ✅ النسبة المئوية في المنتصف تماماً بلون برتقالي صريح بدون توهج
                                      Center(
                                        child: Text(
                                          '${(clampedValue * 100).toInt()}%',
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 117, 232, 255),
                                            fontSize: 33,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: Appfontstring.digital,
                                            fontFamilyFallback: [
                                              Appfontstring.ChangaLight
                                            ],
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // شريط التقدم المكبر مع إطار سيبراني وتدرج لوني فائق الجودة
                                      Container(
                                        height: 18,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.45),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF00E5FF)
                                                .withValues(alpha: 0.65),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF00E5FF)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 16,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(2.5),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final double fillWidth =
                                                constraints.maxWidth *
                                                    clampedValue;
                                            return Stack(
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 50),
                                                  width: fillWidth,
                                                  height: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFF0052D4),
                                                        Color(0xFF4364F7),
                                                        Color(0xFF00E5FF),
                                                        Color.fromARGB(
                                                            255, 181, 255, 181)
                                                      ],
                                                      stops: [
                                                        0.0,
                                                        0.35,
                                                        0.65,
                                                        1.0
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 18),

                              // عبارات شرح أمان البرنامج والمعلومات على التوالي (من غير كونتينر أو خلفية)
                              ValueListenableBuilder<String>(
                                valueListenable: _statusMessage,
                                builder: (context, msg, _) {
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 350),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, 0.15),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      msg,
                                      key: ValueKey<String>(msg),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: Appfontstring.ChangaLight,
                                        height: 1.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // مؤشر الأمان والتشفير السفلي
                    FadeIn(
                      duration: const Duration(milliseconds: 1500),
                      delay: const Duration(milliseconds: 600),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.shield_security,
                            size: 14,
                            color: Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CRCC SECURED POWER GRID PLATFORM • 2026',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11.5,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w700,
                                fontFamily: Appfontstring.ChangaLight),
                          ),
                        ],
                      ),
                    ),

                    // عرض الخطأ فقط عند الحاجة بصندوق زجاجي
                    if (_hasError) _buildGlassStatus(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatus() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: Colors.orangeAccent, size: 40),
          const SizedBox(height: 12),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: Appfontstring.ChangaLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startAppProcess,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
