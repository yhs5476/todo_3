import 'package:get/get.dart';
import 'package:todo/db/db_helper.dart';
import 'package:todo/models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async {
    int result = await DBHelper.insert(task);
    await getTasks(); // 작업 추가 후 목록 갱신
    return result;
  }

  Future<void> getTasks() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
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
