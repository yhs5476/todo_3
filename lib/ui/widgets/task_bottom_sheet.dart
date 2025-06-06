// 바텀 시트 위젯 - 할 일 항목 관리를 위한 바텀 시트
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/theme.dart';

class TaskBottomSheet {
  // 할 일 항목 터치 시 표시되는 바텀 시트 메소드 - 할 일 관리 옵션 표시
  static void showBottomSheet(
      BuildContext context, Task task, TaskController taskController) {
    // 화면 크기에 따라 적절한 패딩 계산
    final double horizontalPadding = SizeConfig.screenWidth * 0.05; // 화면 너비의 5%

    // GetX를 사용하여 바텀 시트 표시
    Get.bottomSheet(
      Container(
        // 상단 모서리 둥글게 처리
        decoration: BoxDecoration(
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        // 내부 패딩 설정
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16,
        ),
        // 자동으로 내용에 맞게 크기 조정 (고정 높이 대신)
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞게 조정
          children: [
            // 바텀 시트 상단 핸들 부분
            Container(
              height: 5,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
            const SizedBox(height: 20),

            // 할 일이 완료된 상태일 경우 '할 일 완료' 버튼 표시하지 않음
            task.isCompleted == 1
                ? const SizedBox.shrink()
                : _buildBottomSheetButton(
                    label: '할 일 완료',
                    onTap: () {
                      // 할 일을 완료 상태로 변경
                      taskController.markTaskAsCompleted(task.id!);
                      // 바텀 시트 닫기
                      Get.back();
                    },
                    clr: primaryClr,
                    icon: Icons.check_circle_outline,
                  ),

            // '할 일 삭제' 버튼 - 완료 여부와 관계없이 표시
            _buildBottomSheetButton(
              label: '할 일 삭제',
              onTap: () {
                // 할 일 삭제 처리
                taskController.deleteTasks(task);
                // 바텀 시트 닫기
                Get.back();
              },
              clr: Colors.red[300]!,
              icon: Icons.delete_outline,
            ),

            // 구분선 - 더 세련되고 아름다운 디자인
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 기본 구분선
                  Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Get.isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                          Get.isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // 가운데 작은 원
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? darkHeaderClr : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: Get.isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // '취소' 버튼
            _buildBottomSheetButton(
              label: '취소',
              onTap: () {
                // 바텀 시트 닫기
                Get.back();
              },
              clr: primaryClr,
              isClose: true,
              icon: Icons.close,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true, // 스크롤 가능하도록 설정
      isDismissible: true, // 바깥 영역 터치 시 닫기 가능
      enableDrag: true, // 드래그로 닫기 가능
    );
  }

  // 바텀 시트에 표시되는 버튼 생성 메소드
  static Widget _buildBottomSheetButton({
    required String label, // 버튼에 표시될 텍스트
    required Function() onTap, // 버튼 클릭 시 실행될 함수
    required Color clr, // 버튼 색상
    bool isClose = false, // 취소 버튼 여부 (기본값: false)
    IconData? icon, // 버튼 아이콘 (옵션)
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            // 버튼 높이 - 약간 줄임
            height: 56,
            // 버튼 너비 - 컨테이너 크기에 맞춤
            width: double.infinity,
            decoration: BoxDecoration(
              // 버튼 테두리 설정
              border: Border.all(
                width: 1.5, // 테두리 두께 줄임
                color: isClose
                    ? Get.isDarkMode // 취소 버튼일 경우 테마에 따라 회색 계열 사용
                        ? Colors.grey[600]! // 다크 모드일 때 진한 회색
                        : Colors.grey[300]! // 라이트 모드일 때 연한 회색
                    : clr, // 일반 버튼은 전달받은 색상 사용
              ),
              // 버튼 모서리 둥글게 설정
              borderRadius: BorderRadius.circular(16),
              // 버튼 배경색 설정 - 취소 버튼은 투명, 일반 버튼은 전달받은 색상
              color: isClose ? Colors.transparent : clr,
            ),
            // 버튼 내부 텍스트와 아이콘 배치
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘이 있는 경우에만 표시
                if (icon != null)
                  Icon(
                    icon,
                    color: isClose
                        ? (Get.isDarkMode ? Colors.white : Colors.black87)
                        : Colors.white,
                    size: 20,
                  ),
                // 아이콘과 텍스트 사이 간격
                if (icon != null) const SizedBox(width: 8),
                // 버튼 텍스트
                Text(
                  label,
                  style: isClose
                      ? titleStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )
                      : titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
