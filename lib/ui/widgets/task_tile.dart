// Flutter 머티리얼 디자인 위젯을 사용하기 위한 패키지
import 'package:flutter/material.dart';
// Google 폰트를 사용하기 위한 패키지
import 'package:google_fonts/google_fonts.dart';
// 화면 크기 관련 설정을 위한 파일
import 'package:todo/ui/size_config.dart';
// 앱의 테마 정보(색상 등)를 포함한 파일
import 'package:todo/ui/theme.dart';
// 할일(Task) 모델 클래스 임포트
import '../../models/task.dart';

/// 할일 항목을 표시하는 타일 위젯
/// 할일 목록에서 각 항목을 표시하기 위한 커스텀 위젯
class TaskTile extends StatelessWidget {
  // 생성자: 할일 객체를 받아 타일을 생성함
  const TaskTile(this.task, {Key? key}) : super(key: key);

  // 표시할 할일 객체
  final Task task;

  // 위젯 빌드 메소드 오버라이드
  // 타일 UI를 구성하는 부분
  @override
  Widget build(BuildContext context) {
    // 바깥쪽 컨테이너 - 타일의 외부 레이아웃 정의
    return Container(
      // 좌우 패딩 설정 - 화면 방향에 따라 다른 값 적용
      padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(
              SizeConfig.orientation == Orientation.landscape ? 4 : 20)),
      // 타일 너비 - 가로 모드일 경우 화면의 절반, 세로 모드일 경우 화면 전체 너비
      width: SizeConfig.orientation == Orientation.landscape
          ? SizeConfig.screenWidth / 2
          : SizeConfig.screenWidth,
      // 타일 하단 여백 설정
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      // 내부 컨테이너 - 실제 타일 디자인을 포함
      child: Container(
        // 모든 방향으로 12의 패딩 적용
        padding: const EdgeInsets.all(12.0),
        // 타일 디자인 설정
        decoration: BoxDecoration(
            // 모서리를 16 픽셀 반경으로 둥근 처리
            borderRadius: BorderRadius.circular(16),
            // 할일의 색상 값에 따라 배경색 설정
            color: _getBGCLR(task.color)),
        // 타일 내부 콘텐츠를 가로로 배치
        child: Row(
          children: [
            // 할일 내용 영역 - 가능한 공간을 모두 차지
            Expanded(
              // 내용이 너무 길 경우 스크롤 가능하도록 설정
              child: SingleChildScrollView(
                // 할일 내용을 세로로 배치
                child: Column(
                  // 텍스트를 왼쪽에 정렬
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 할일 제목 텍스트
                    Text(
                      // 할일 모델에서 제목 값 가져오기
                      task.title!,
                      // Google Lato 폰트 적용
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                        // 텍스트 색상: 흰색
                        color: Colors.white,
                        // 폰트 크기: 16
                        fontSize: 16,
                        // 굵게 표시
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                    // 제목과 시간 사이의 여백
                    const SizedBox(
                      height: 12,
                    ),
                    // 시간 정보를 표시하는 행
                    Row(
                      // 중앙 수직 정렬
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 시계 아이콘
                        Icon(
                          Icons.access_time_rounded,
                          // 아이콘 색상: 밝은 회색
                          color: Colors.grey[200],
                          // 아이콘 크기: 18
                          size: 18,
                        ),
                        // 아이콘과 텍스트 사이 여백
                        const SizedBox(
                          width: 12,
                        ),
                        // 시간 표시 텍스트
                        Text(
                          // 시작 시간과 종료 시간을 하이픈으로 연결하여 표시
                          '${task.startTime} - ${task.endTime}',
                          // Google Lato 폰트 적용
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                            // 텍스트 색상: 밝은 회색
                            color: Colors.grey[100],
                            // 폰트 크기: 10 (작게 표시)
                            fontSize: 10,
                          )),
                        ),
                      ],
                    ),
                    // 시간과 메모 사이의 여백
                    const SizedBox(
                      height: 12,
                    ),
                    // 할일 메모/내용 텍스트
                    Text(
                      // 할일 모델에서 메모 값 가져오기
                      task.note!,
                      // Google Lato 폰트 적용
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                        // 텍스트 색상: 밝은 회색
                        color: Colors.grey[100],
                        // 폰트 크기: 15
                        fontSize: 15,
                      )),
                    ),
                  ],
                ),
              ),
            ),
            // 수직 구분선 - 할일 내용과 상태 표시를 분리
            Container(
              // 좌우 여백 설정
              margin: const EdgeInsets.symmetric(horizontal: 10),
              // 구분선 높이: 60
              height: 60,
              // 구분선 두께: 0.5
              width: 0.5,
              // 구분선 색상: 회색에 투명도 적용
              color: Colors.grey[200]!.withOpacity(0.7),
            ),
            // 할일 상태 표시 (완료 여부)
            RotatedBox(
              // 텍스트를 90도 회전하여 세로로 표시 (3번 회전 = 270도)
              quarterTurns: 3,
              child: Text(
                // 할일 완료 여부에 따라 다른 텍스트 표시
                task.isCompleted == 0 ? 'TODO' : 'Completed',
                // Google Lato 폰트 적용
                style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                  // 텍스트 색상: 흰색
                  color: Colors.white,
                  // 폰트 크기: 10 (작게 표시)
                  fontSize: 10,
                  // 굵게 표시
                  fontWeight: FontWeight.bold,
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 할일의 색상 값에 따라 적절한 배경색을 반환하는 메소드
  _getBGCLR(int? color) {
    // 색상 값에 따라 다른 색상 반환
    switch (color) {
      case 0:
        // 파란색 계열
        return bluishClr;
      case 1:
        // 분홍색 계열
        return pinkClr;
      case 2:
        // 주황색 계열
        return orangeClr;
      default:
        // 기본값은 파란색 계열
        return bluishClr;
    }
  }
}
