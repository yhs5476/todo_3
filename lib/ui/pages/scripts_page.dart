import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/script_controller.dart';
import 'package:todo/models/script_model.dart';
import 'package:todo/ui/pages/add_speech_to_text.dart';
import 'package:todo/ui/theme.dart';

class ScriptsPage extends StatelessWidget {
  ScriptsPage({Key? key}) : super(key: key);

  final ScriptController _scriptController = Get.find<ScriptController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 스크립트', style: headingStyle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryClr),
          onPressed: () => Get.back(),
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (_scriptController.scripts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_alt_outlined, size: 90, color: primaryClr.withValues(alpha: 0.5)),
                const SizedBox(height: 20),
                Text(
                  '저장된 스크립트가 없습니다.\n새 스크립트를 추가해보세요!',
                  textAlign: TextAlign.center,
                  style: subHeadingStyle,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: _scriptController.scripts.length,
          itemBuilder: (context, index) {
            Script script = _scriptController.scripts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(script.title, style: titleStyle.copyWith(fontSize: 18)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      script.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: subHeadingStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '생성일: ${DateFormat.yMd("ko_KR").add_jm().format(script.createdAt)}',
                      style: subHeadingStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: 스크립트 상세 보기 기능 구현 (예: 새 페이지 또는 다이얼로그)
                  Get.defaultDialog(
                    title: script.title,
                    content: SingleChildScrollView(child: Text(script.content)),
                    titleStyle: titleStyle,
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                  onPressed: () {
                    Get.defaultDialog(
                      title: '스크립트 삭제',
                      middleText: '"${script.title}" 스크립트를 정말 삭제하시겠습니까?',
                      textConfirm: '삭제',
                      textCancel: '취소',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        _scriptController.deleteScript(script.id);
                        Get.back(); // 다이얼로그 닫기
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryClr,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Get.to(() => const AddSpeechToTextPage());
          if (result != null && result is Map<String, String>) {
            String? title = result['title'];
            String? content = result['content'];
            if (title != null && content != null && title.isNotEmpty && content.isNotEmpty) {
              _scriptController.addScript(title, content);
            } else {
              Get.snackbar('저장 실패', '스크립트 제목 또는 내용이 비어있습니다.', snackPosition: SnackPosition.BOTTOM);
            }
          } else {
            print('AddSpeechToTextPage에서 결과가 없거나 형식이 다릅니다.');
          }
        },
      ),
    );
  }
}
