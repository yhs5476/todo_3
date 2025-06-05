// 필요한 패키지 및 테마 가져오기
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';

// 알림 화면 위젯 - 사용자에게 알림 세부 정보를 표시하는 화면
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key, required this.payload}) : super(key: key);

  // 알림에서 전달된 페이로드 데이터 (제목|내용|날짜 형식)
  final String payload;

  @override
  // ignore: library_private_types_in_public_api
  // 상태 객체 생성
  _NotificationScreenState createState() => _NotificationScreenState();
}

// 알림 화면의 상태를 관리하는 클래스
class _NotificationScreenState extends State<NotificationScreen> {
  // 알림 데이터를 저장할 변수
  String _payload = '';

  // 위젯이 처음 생성될 때 호출되는 초기화 메서드
  @override
  void initState() {
    super.initState();
    // 위젯에서 전달받은 페이로드 데이터를 상태 변수에 저장
    _payload = widget.payload;
  }

  // UI를 구성하는 메서드
  @override
  Widget build(BuildContext context) {
    // 전체 화면 구조 정의
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: context.theme.scaffoldBackgroundColor,
      // 상단 앱바 구성
      appBar: AppBar(
        // 뒤로가기 버튼
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        elevation: 0,
        // ignore: deprecated_member_use
        backgroundColor: context.theme.scaffoldBackgroundColor,
        // 앱바 제목 - 알림의 제목을 표시
        title: Text(
          _payload.toString().split('|')[0],
          style: TextStyle(color: Get.isDarkMode ? Colors.white : darkGreyClr),
        ),
        centerTitle: true,
      ),
      // 본문 영역 - SafeArea로 시스템 UI와 겹치지 않게 처리
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            // 인사말과 알림 안내 텍스트
            Column(
              children: [
                Text(
                  '안녕하세요, 사용자님',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Get.isDarkMode ? Colors.white : darkGreyClr),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '새로운 알림이 있습니다',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Get.isDarkMode ? Colors.grey[100] : darkGreyClr),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // 알림 세부 정보를 보여주는 확장 가능한 컨테이너
            Expanded(
              // 알림 내용을 담는 스타일이 적용된 컨테이너
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30), color: primaryClr),
                // 내용이 많을 경우 스크롤 가능하도록 설정
                child: SingleChildScrollView(
                  // 알림 세부 정보를 세로로 배치
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.text_format,
                            size: 35,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '제목',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // 알림 제목 표시 - 페이로드의 첫 번째 부분
                      Text(
                        _payload.toString().split('|')[0],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // 내용 섹션 헤더
                      const Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 35,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '내용',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // 알림 내용 표시 - 페이로드의 두 번째 부분
                      Text(
                        _payload.toString().split('|')[1],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // 날짜 섹션 헤더
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 35,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '날짜',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // 알림 날짜 표시 - 페이로드의 세 번째 부분
                      Text(
                        _payload.toString().split('|')[2],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
