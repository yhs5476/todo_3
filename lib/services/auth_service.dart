// 인증 관련 패키지 및 모듈 가져오기
import 'package:firebase_auth/firebase_auth.dart';  // Firebase 인증 기능
import 'package:flutter/material.dart';  // 머티리얼 디자인 컴포넌트
import 'package:google_sign_in/google_sign_in.dart';  // 구글 로그인 기능
import 'package:get/get.dart';  // GetX 상태관리 패키지

// 사용자 인증 관리 서비스 클래스
class AuthService extends GetxController {
  // 싱글톤 패턴을 이용한 인스턴스 접근
  static AuthService get instance => Get.find();
  
  // Firebase 인증 관리 객체 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 구글 로그인 관리 객체 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // 현재 로그인한 사용자 정보 (반응형 변수)
  final Rx<User?> currentUser = Rx<User?>(null);

  // 초기화 시 실행되는 메소드
  @override
  void onInit() {
    super.onInit();
    // 현재 사용자 정보 가져오기
    currentUser.value = _auth.currentUser;
    
    // 인증 상태 변경 이벤트를 결합하여 사용자 정보 업데이트
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });
  }

  // 사용자 로그인 상태 확인 가능한 속성
  bool get isLoggedIn => currentUser.value != null;

  // 구글 계정으로 로그인하는 메소드
  Future<User?> signInWithGoogle() async {
    try {
      // 이미 로그인되어 있을 경우 기존 사용자 반환
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }
      
      // 구글 로그인 팝업 창 표시 및 로그인 요청
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        return null;
      }

      // 구글로부터 인증 정보 받기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase에서 사용할 인증 정보 생성
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,  // 액세스 토큰
        idToken: googleAuth.idToken,  // ID 토큰
      );

      // 구글 인증 정보로 Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // 로그인 성공 시 상태 업데이트를 확실히 하기 위해 짜길 딜레이 추가
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 사용자 정보 로그 출력 (디버깅용)
      print("구글 로그인 성공: ${userCredential.user?.displayName}");
      
      // 사용자 정보 반환
      return userCredential.user;
    } catch (e) {
      // 오류 발생 시 사용자에게 오류 메시지 표시
      Get.snackbar(
        "로그인 실패",
        "오류가 발생했습니다: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return null;
    }
  }

  // 로그아웃 처리를 위한 메소드
  Future<void> signOut() async {
    try {
      // 구글 계정 로그아웃
      await _googleSignIn.signOut();
      
      // Firebase 로그아웃
      await _auth.signOut();
    } catch (e) {
      // 로그아웃 실패 시 오류 메시지 표시
      Get.snackbar(
        "로그아웃 실패", 
        "오류가 발생했습니다: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
