// Flutter 머티리얼 디자인 위젯을 사용하기 위한 패키지 임포트
import 'package:flutter/material.dart';
// 앱의 테마 정보(색상 등)를 포함한 파일 임포트
import 'package:todo/ui/theme.dart';

/// 재사용 가능한 커스텀 버튼 위젯
/// 앱 전체에서 일관된 디자인의 버튼을 사용하기 위해 만들어진 컴포넌트
class MyButton extends StatelessWidget {
  // 버튼 생성자
  // label: 버튼에 표시될 텍스트
  // onTap: 버튼 클릭시 실행될 콜백 함수
  const MyButton({Key? key, required this.label, required this.onTap})
      : super(key: key);

  // 버튼에 표시될 텍스트
  final String label;
  // 버튼 클릭시 실행될 함수
  final Function() onTap;

  // 위젯 빌드 메소드 오버라이드
  // 실제 버튼 UI를 구성하는 부분
  @override
  Widget build(BuildContext context) {
    // GestureDetector를 사용하여 탭 이벤트 감지
    return GestureDetector(
      onTap: onTap,
      // Container를 사용하여 버튼의 크기와 모양을 정의
      child: Container(
        // 내부 콘텐츠를 중앙 정렬
        alignment: Alignment.center,
        // 버튼의 너비: 100
        width: 100,
        // 버튼의 높이: 45
        height: 45,
        // 버튼 스타일 정의
        decoration: BoxDecoration(
          // 둥근 모서리 (반지름: 10)
          borderRadius: BorderRadius.circular(10),
          // 버튼 배경색으로 테마에서 정의된 주요 색상 사용
          color: primaryClr,
        ),
        // 버튼 내부 텍스트 위젯
        child: Text(
          // 전달받은 라벨 텍스트
          label,
          // 텍스트 스타일 설정
          style: const TextStyle(
            // 텍스트 색상: 흰색
            color: Colors.white,
          ),
          // 텍스트 중앙 정렬
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
