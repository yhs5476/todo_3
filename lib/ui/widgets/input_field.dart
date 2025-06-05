// Flutter 기본 Material 디자인 관련 라이브러리
import 'package:flutter/material.dart';
// GetX 라이브러리 - 상태 관리 및 컨텍스트 없이 테마에 접근할 수 있게 해줌
import 'package:get/get.dart';

// 화면 크기 관련 설정 파일
import '../size_config.dart';
// 앱 테마 스타일 정의 파일
import '../theme.dart';

/// 사용자 입력을 받기 위한 커스텀 입력 필드 위젯
/// 제목, 힌트 텍스트를 표시하고 선택적으로 추가 위젯(예: 날짜 선택기)을 포함할 수 있음
class InputField extends StatelessWidget {
  /// InputField 생성자
  /// @param title: 입력 필드 위에 표시될 제목
  /// @param hint: 입력 필드 내부에 표시될 힌트 텍스트
  /// @param controller: 텍스트 입력값을 제어하는 컨트롤러(선택)
  /// @param widget: 입력 필드 오른쪽에 표시될 추가 위젯(선택), 주로 날짜/시간 선택기에 사용
  const InputField({
    Key? key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
  }) : super(key: key);

  final String title; // 입력 필드 상단에 표시될 제목
  final String hint; // 입력 필드 내부에 표시될 힌트 텍스트
  final TextEditingController? controller; // 입력값 제어를 위한 컨트롤러
  final Widget? widget; // 입력 필드 오른쪽에 표시될 추가 위젯(옵션)

  /// 위젯 빌드 메서드
  /// 제목과 테두리가 있는 입력 필드를 구성
  @override
  Widget build(BuildContext context) {
    // 화면 크기에 맞게 위젯 크기를 조정하기 위해 SizeConfig 초기화
    SizeConfig().init(context);
    // 입력 필드의 전체 컨테이너 반환
    return Container(
      margin: const EdgeInsets.only(top: 16), // 상단 여백 설정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 입력 필드 위에 표시되는 제목 텍스트
          Text(
            title,
            style: titleStyle, // theme.dart에서 정의된 제목 스타일 적용
          ),
          // 입력 필드를 위한 컨테이너
          Container(
            margin: const EdgeInsets.only(top: 8), // 제목과의 간격
            padding: const EdgeInsets.only(left: 14), // 왼쪽 패딩
            width: SizeConfig.screenWidth, // 화면 너비에 맞춤
            height: 52, // 고정 높이
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                border: Border.all(
                  color: Colors.grey, // 테두리 색상
                )),
            // 입력 필드와 추가 위젯을 가로로 배치
            child: Row(
              children: [
                // 텍스트 입력 영역이 사용 가능한 공간을 모두 차지하도록 Expanded 사용
                Expanded(
                    child: TextFormField(
                  controller: controller, // 입력값 제어를 위한 컨트롤러
                  autofocus: false, // 자동 포커스 해제
                  readOnly: widget != null
                      ? true
                      : false, // 추가 위젯이 있으면 읽기 전용으로 설정(날짜 선택기 등에 사용)
                  style: subTitleStyle, // 입력 텍스트 스타일
                  // 다크모드에 따라 커서 색상 변경
                  cursorColor:
                      Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
                  // 입력 필드 꾸미기
                  decoration: InputDecoration(
                    hintText: hint, // 힌트 텍스트 설정
                    hintStyle: subTitleStyle, // 힌트 텍스트 스타일
                    // 활성화된 상태의 밑줄 테두리 스타일 설정
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      // ignore: deprecated_member_use
                      color: context
                          .theme.scaffoldBackgroundColor, // 배경색과 같게 해서 밑줄을 숨김
                    )),
                    // 포커스된 상태의 밑줄 테두리 스타일 설정
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      // ignore: deprecated_member_use
                      color: context
                          .theme.scaffoldBackgroundColor, // 배경색과 같게 해서 밑줄을 숨김
                      width: 0, // 테두리 너비를 0으로 설정
                    )),
                  ),
                )),
                // 추가 위젯이 제공된 경우 표시(예: 날짜 선택기), 없으면 빈 컨테이너 표시
                widget ?? Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
