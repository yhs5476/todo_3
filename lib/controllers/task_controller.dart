import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/db/db_helper.dart';
import 'package:todo/models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = <Task>[].obs;
  // 현재 선택된 날짜를 추적하는 변수
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  Future<int> addTask({Task? task}) async {
    int result = await DBHelper.insert(task);
    await getTasks(); // 작업 추가 후 목록 갱신
    return result;
  }

  Future<void> getTasks() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }
  
  // 특정 날짜의 할일만 가져오는 메소드
  Future<void> getTasksByDate(DateTime date) async {
    // 날짜 형식 변환 (yMd)
    String formattedDate = DateFormat.yMd().format(date);
    
    // 선택된 날짜 업데이트
    selectedDate.value = date;
    
    // DB에서 해당 날짜의 할일 가져오기
    final List<Map<String, dynamic>> tasks = await DBHelper.queryByDate(formattedDate);
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
    
    print('필터링된 할일 개수: ${taskList.length}');
  }

  void deleteTasks(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }

  void deleteAllTasks() async {
    await DBHelper.deleteAll();
    getTasks();
  }

  void markTaskAsCompleted(int id) async {
    await DBHelper.update(id);
    getTasks();
  }
}
