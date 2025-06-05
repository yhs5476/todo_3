import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo/services/auth_service.dart'; // AuthService 추가
import 'package:todo/ui/pages/home_page.dart';
import 'package:todo/ui/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // AuthService 사용
  final AuthService _authService = Get.find<AuthService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already signed in
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    // 로그인 상태 확인 시 짧은 지연 추가 (Firebase Auth 상태 정확히 확인하기 위함)
    await Future.delayed(const Duration(milliseconds: 500));
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is already signed in, navigate to HomePage
      Get.off(() => const HomePage(), transition: Transition.fadeIn);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // AuthService를 통한 구글 로그인 처리
      final User? user = await _authService.signInWithGoogle();

      if (user != null) {
        // 사용자 로그인 성공
        Get.snackbar(
          "로그인 성공",
          "${user.displayName}님 환영합니다",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        
        // 홈페이지로 이동 (페이드 인 효과 추가)
        // 짧은 지연 추가로 Firebase Auth 상태 업데이트 보장
        await Future.delayed(const Duration(milliseconds: 500));
        Get.off(() => const HomePage(), transition: Transition.fadeIn);
      }
    } catch (e) {
      Get.snackbar(
        "로그인 실패",
        "오류가 발생했습니다: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? darkGreyClr : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon and Title
                Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Get.isDarkMode ? Colors.white : primaryClr,
                ),
                const SizedBox(height: 20),
                Text(
                  "할 일 관리",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode ? Colors.white : darkGreyClr,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Welcome Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "시작하려면 Google 계정으로 로그인하세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                
                // Google Sign In Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                        label: const Text(
                          "Google로 로그인",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryClr,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _signInWithGoogle,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
