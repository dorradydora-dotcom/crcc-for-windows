import 'dart:ui';
import 'package:amiraly/app/common/widgets/black_edges_overlay.dart';
import 'package:amiraly/app/common/widgets/headlinetext.dart';
import 'package:amiraly/app/features/auth/homepage/homepage.dart';
import 'package:amiraly/app/util/constant/constants.dart';
import 'package:amiraly/app/util/validators/validator_helper.dart';
import 'package:amiraly/core/services/auth_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amiraly/core/widgets/electric_loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // استخدام nullable مؤقتاً
  LoginControllerImp? _loginController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // تسجيل الـ Controller إذا لم يكن مسجلاً
    if (!Get.isRegistered<LoginControllerImp>()) {
      Get.put(LoginControllerImp());
    }
    _loginController = Get.find<LoginControllerImp>();
  }

  // دالة مساعدة للحصول على الـ Controller بأمان
  LoginControllerImp get loginController {
    if (_loginController == null) {
      _initializeController();
    }
    return _loginController!;
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // التأكد من التهيئة قبل البناء
    if (_loginController == null) {
      _initializeController();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            const LogBackGroung(),
            _buildLoginForm(),
            _buildDeveloperInfo(),
            _buildMinistryLogo(),
            _buildAdditionalLogo1(),
            _buildAdditionalLogo2(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Positioned.fill(
      child: Form(
        key: _formKey,
        child: LayoutBuilder(builder: (context, constraints) {
          final bool isDesktop =
              !GetPlatform.isMobile || constraints.maxWidth > 700;
          final double formMaxWidth = isDesktop ? 430.0 : double.infinity;

          return Align(
            alignment: Alignment.topRight,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: isDesktop ? 24.h : 20.h,
                right: isDesktop ? 32.w : 16.w,
                left: isDesktop ? 0 : 16.w,
                bottom: 24.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formMaxWidth),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF071424).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color:
                              const Color(0xFF00E5FF).withValues(alpha: 0.20),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeaderText(),
                          SizedBox(height: 4.h),
                          _buildDivider(),
                          SizedBox(height: 6.h),
                          _buildCompanyTexts(),
                          SizedBox(height: 18.h),
                          _buildEmailField(),
                          SizedBox(height: 12.h),
                          _buildPasswordField(),
                          SizedBox(height: 20.h),
                          _buildLoginButton(constraints),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeaderText() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 50),
      child: Align(
        alignment: Alignment.centerRight,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextLine(
                text: 'تسـجيل الدخـول',
                color: Colors.white,
                fontWeight: FF.B,
                fontSize: 18.sp,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  Iconsax.flash5,
                  color: const Color(0xFF00E5FF),
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: 1.5,
        width: 140.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00E5FF),
              const Color(0xFF00E5FF).withValues(alpha: 0.3),
              Colors.transparent,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 900),
          delay: const Duration(milliseconds: 100),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextLine(
              text: 'الشركة المصرية لنقل الكهرباء',
              color: const Color(0xFFFF6B6B),
              fontWeight: FF.B,
              fontSize: 11.5.sp,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        FadeInDown(
          duration: const Duration(milliseconds: 900),
          delay: const Duration(milliseconds: 180),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextLine(
              text: 'برنامج التحكم الاقليمى للقاهرة الكبرى',
              color: const Color(0xFF00E5FF),
              fontWeight: FF.B,
              fontSize: 13.sp,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        FadeInDown(
          duration: const Duration(milliseconds: 900),
          delay: const Duration(milliseconds: 260),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextLine(
              text: 'مـركز التحكم الاقليمى',
              color: const Color(0xFFFFE082),
              fontWeight: FF.B,
              fontSize: 10.5.sp,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: CustomTextFormFieldlogin(
        focusNode: _emailFocusNode,
        valid: (val) => validInput(val!, 5, 30, 'email'),
        hinttext: 'Enter your mail',
        icon: Icons.alternate_email_rounded,
        labelText: 'Email',
        mycontroller: loginController.email,
        keyboardType: TextInputType.emailAddress,
        obscureText: false,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _emailFocusNode.unfocus();
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 100),
      child: CustomTextFormFieldlogin(
        focusNode: _passwordFocusNode,
        valid: (val) => validInput(val!, 7, 30, 'password'),
        hinttext: 'Enter password',
        icon: Icons.lock_outline_rounded,
        labelText: 'Password',
        mycontroller: loginController.password,
        obscureText: true,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          _passwordFocusNode.unfocus();
          if (_formKey.currentState!.validate()) {
            loginController.loginAction(
              loginController.email.text,
              loginController.password.text,
              _formKey,
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginButton(BoxConstraints constraints) {
    return Center(
      child: Obx(() => FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: LoginButton(
              buttonHeight: 38.h,
              isLoading: loginController.isLoading.value,
              onPressed: () => loginController.loginAction(
                loginController.email.text,
                loginController.password.text,
                _formKey,
              ),
              buttonwidth: 180.w,
            ),
          )),
    );
  }

  Widget _buildDeveloperInfo() {
    return Positioned(
      bottom: 16.h,
      left: 18.w,
      child: FadeInLeft(
        duration: const Duration(milliseconds: 1500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF040D1A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.6,
                ),
              ),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'P',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            TextSpan(
                              text: 'owered ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: 'b',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            TextSpan(
                              text: 'y',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextLine(
                        text: 'د/محمود عصمت : وزير الكهرباء و الطاقة المتجددة',
                        color: Colors.cyanAccent,
                        fontFamily: Appfontstring.ChangaLight,
                        fontSize: 11.5.sp,
                        fontWeight: FF.B,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextLine(
                        text: 'م/منى رزق : رئيسـة الشركة المصرية للنقل',
                        color: const Color.fromARGB(255, 140, 225, 240),
                        fontFamily: Appfontstring.ChangaLight,
                        fontSize: 9.5.sp,
                        fontWeight: FF.B,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextLine(
                        text: 'م/محمد رياض : العضو المتفرغ للمنطقة الشمالية',
                        color: const Color.fromARGB(255, 140, 225, 240),
                        fontFamily: Appfontstring.ChangaLight,
                        fontSize: 9.5.sp,
                        fontWeight: FF.B,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'برمجة و تصميم : ',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                                fontFamily: Appfontstring.ChangaLight,
                              ),
                            ),
                            TextSpan(
                              text: 'م/ امير محمود بدوى',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: Appfontstring.ChangaLight,
                              ),
                            ),
                          ],
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinistryLogo() {
    return Positioned(
      bottom: 16.h,
      right: 18.w,
      child: FadeInUp(
        duration: const Duration(milliseconds: 1000),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF040D1A).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSingleLogo(AppimageString.minisrty),
                  SizedBox(width: 8.w),
                  _buildSingleLogo(AppimageString.qq),
                  SizedBox(width: 8.w),
                  _buildSingleLogo(AppimageString.aaa),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleLogo(String assetPath) {
    return Container(
      height: 30.h,
      width: 38.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.6,
        ),
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget _buildAdditionalLogo1() => const SizedBox.shrink();

  Widget _buildAdditionalLogo2() => const SizedBox.shrink();
}

abstract class LoginController extends GetxController {
  Future<void> gotohomepage();
  Future<String?> saveTokenToUserTable({
    required String email,
    required String authToken,
    String? fcmToken,
  });
  Future<void> loginAction(
    String email,
    String password,
    GlobalKey<FormState> formKey,
  );
}

class LoginControllerImp extends LoginController {
  // الحل: التهيئة الفورية بدون late
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  AuthService get authservice => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    AppLogger.logInfo('LoginController initialized');
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    AppLogger.logInfo('LoginController disposed');
    super.onClose();
  }

  @override
  Future<void> gotohomepage() async {
    Get.offAll(() => const HomePage());
  }

  @override
  Future<String?> saveTokenToUserTable({
    required String email,
    required String authToken,
    String? fcmToken,
  }) async {
    final supabase = Supabase.instance.client;
    const tables = [
      AppConstants.tableUserCrcc,
      AppConstants.tableUserStations,
      'user_others',
      'user_cm',
      AppConstants.tableUserTop
    ];
    String? updatedTable;

    for (final table in tables) {
      try {
        final response = await supabase
            .from(table)
            .select('id')
            .eq('user_email', email.trim())
            .limit(1);

        if (response.isNotEmpty) {
          final Map<String, dynamic> updateMap = {};

          if (fcmToken != null && fcmToken.isNotEmpty) {
            updateMap['user_token'] = fcmToken;
          }

          if (updateMap.isNotEmpty) {
            await supabase
                .from(table)
                .update(updateMap)
                .eq('user_email', email.trim());
          }

          updatedTable = table;
          break;
        }
      } catch (e) {
        AppLogger.logWarning('Error updating table $table: $e');
        continue;
      }
    }

    return updatedTable;
  }

  @override
  Future<void> loginAction(
    String email,
    String password,
    GlobalKey<FormState> formKey,
  ) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      errorMessage.value = '';

      try {
        final session = await authservice.login(
          context: Get.context!,
          email: email.trim(),
          password: password,
        );

        if (session == null) {
          throw Exception('فشل تسجيل الدخول: بيانات غير صحيحة');
        }

        final authToken = session.accessToken;
        if (authToken.isEmpty) {
          throw Exception('لم يتم إنشاء رمز المصادقة');
        }

        String? fcmToken;
        if (GetPlatform.isMobile) {
          try {
            final messaging = FirebaseMessaging.instance;
            final NotificationSettings settings =
                await messaging.requestPermission(
              alert: true,
              badge: true,
              sound: true,
              provisional: false,
            );

            if (settings.authorizationStatus ==
                AuthorizationStatus.authorized) {
              fcmToken = await messaging.getToken();
              AppLogger.logInfo(
                  'FCM Token obtained: ${fcmToken?.substring(0, 10)}...');
            } else {
              AppLogger.logWarning('Notifications not authorized');
            }
          } catch (e) {
            AppLogger.logError('Failed to get FCM token', e);
          }
        }

        final updatedTable = await saveTokenToUserTable(
          email: email.trim(),
          authToken: authToken,
          fcmToken: fcmToken,
        );

        if (updatedTable != null) {
          AppLogger.logSuccess(
              'User logged in successfully. Table: $updatedTable');

          if (fcmToken != null) {
            Get.snackbar(
              'نجاح',
              'تم حفظ البيانات بنجاح',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            );
          }

          await Future.delayed(const Duration(milliseconds: 500));
          // إزالة Get.delete لتفادي مشكلة dispose قبل انتهاء الانتقال
          await gotohomepage();
        } else {
          AppLogger.logWarning('User found but token not saved to any table');
          await gotohomepage();
        }
      } catch (e) {
        errorMessage.value = e.toString();
        AppLogger.logError('Login failed', e);

        Get.snackbar(
          'خطأ',
          'فشل تسجيل الدخول: ${e.toString().replaceAll('Exception: ', '')}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}

class LogBackGroung extends StatelessWidget {
  const LogBackGroung({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // خلفية داكنة متناسقة مع ألوان سماء الصورة
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF040B14),
                Color(0xFF081A2A),
                Color(0xFF0F2B44),
                Color(0xFF03070D),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // عرض الصورة مع الحفاظ التام على أبعادها وتفاصيلها بدقة فائقة
        Image.asset(
          AppimageString.loginOption1,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
        // حواف سوداء محيطية ناعمة للصورة
        const BlackEdgesOverlay(),
      ],
    );
  }
}

class CustomTextFormFieldlogin extends StatefulWidget {
  final String hinttext;
  final IconData icon;
  final bool? obscureText;
  final String labelText;
  final TextEditingController? mycontroller;
  final String? Function(String?)? valid;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;

  const CustomTextFormFieldlogin({
    super.key,
    required this.hinttext,
    required this.icon,
    required this.labelText,
    required this.mycontroller,
    this.valid,
    required this.keyboardType,
    this.obscureText,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  CustomTextFormFieldloginState createState() =>
      CustomTextFormFieldloginState();
}

class CustomTextFormFieldloginState extends State<CustomTextFormFieldlogin> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? false;
  }

  void toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mycontroller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      validator: widget.valid,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(
        color: Colors.white,
        fontSize: 13.sp,
        fontFamily: Appfontstring.ChangaLight,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.icon,
          color: const Color(0xFF00E5FF),
          size: 20.sp,
        ),
        suffixIcon: widget.obscureText == true
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white70,
                  size: 20.sp,
                ),
                onPressed: toggleObscureText,
                splashRadius: 20.r,
              )
            : null,
        alignLabelWithHint: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        hintText: widget.hinttext,
        hintStyle: TextStyle(
          color: Colors.white38,
          fontSize: 12.sp,
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: const Color(0xFF64D2FF),
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w600,
          fontFamily: Appfontstring.ChangaLight,
        ),
        filled: true,
        fillColor: const Color(0xFF05101E).withValues(alpha: 0.22),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.16),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF00E5FF),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFFF5252),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFFF5252),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({
    super.key,
    required this.buttonHeight,
    required this.isLoading,
    required this.buttonwidth,
    this.onPressed,
  });

  final double buttonHeight;
  final double buttonwidth;
  final bool isLoading;
  final void Function()? onPressed;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _rippleProgress;

  @override
  void initState() {
    super.initState();
    // نبضة هادئة وراقية تتكرر دورياً كل 5 ثواني
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // توهج موجي هادئ يتسع بنعومة ويتلاشى في محيط الزر دون تحريك أي نص أو أيقونة (~1.4 ثانية)
    _rippleProgress = CurvedAnimation(
      parent: _pulseController,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double rVal = widget.isLoading ? 0.0 : _rippleProgress.value;
        final bool isRippling =
            !widget.isLoading && _pulseController.value <= 0.28;
        final double rippleAlpha = isRippling ? (1.0 - rVal) * 0.65 : 0.0;
        final double rippleSpread = isRippling ? rVal * 8.0 : 0.0;
        final double rippleBlur = isRippling ? 8.0 + (rVal * 18.0) : 10.0;
        final BorderRadius pillRadius =
            BorderRadius.circular(widget.buttonHeight / 2);

        return Container(
          width: widget.buttonwidth,
          height: widget.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: pillRadius,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00E5FF),
                Color(0xFF0066FF),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              // وهج ارتكاز ناعم ثابت
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              // هالة النبضة الهادئة تتسع في محيط الزر كل 5 ثواني دون أي حركة للنصوص أو الأيقونة
              if (isRippling)
                BoxShadow(
                  color:
                      const Color(0xFF00E5FF).withValues(alpha: rippleAlpha),
                  blurRadius: rippleBlur,
                  spreadRadius: rippleSpread,
                  offset: Offset.zero,
                ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: pillRadius,
              ),
              padding: EdgeInsets.zero,
            ),
            child: widget.isLoading
                ? const ElectricLoadingIndicator(
                    size: 20, color: Colors.white)
                : Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'تسـجيـل الـدخـول',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: Appfontstring.ChangaLight,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Iconsax.login_1,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
