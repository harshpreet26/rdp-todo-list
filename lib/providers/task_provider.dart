import 'package:myapp/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/task.dart';
import 'package:flutter/material.dart';

//create a task provider to manage state
class TaskProvider extends ChangeNotifier {
  final TaskService taskService = TaskService();
  List<Task> tasks = [];

  //populates task list /array with documents from database
  //notifies the root provider of stateful change
  Future<void> LoadTasks() async {
    tasks = await taskService.fetchTasks();
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    // check to see if name is not empty or null
    if (name.trim().isNotEmpty) {
      // add the trimmed task name to the database
      final id = await taskService.addTask(name.trim());
      //adding the task name to the local list of tasks held in memory
      tasks.add(Task(id: id, name: name, completed: false));
      notifyListeners();
    }
  }

  Future<void> updateTask(int index, bool completed) async {
    //uses array index to find tasks
    final task = tasks[index];
    //update the task collection in the database by id, using bool for completed
    await taskService.updateTask(task.id, completed);
    //updating the local task list
    tasks[index] = Task(id: task.id, name: task.name, completed: completed);
    notifyListeners();
  }

  Future<void> removeTask(int index) async {
    //uses array index to find tasks
    final task = tasks[index];
    //delete the task from the collection
    await taskService.deleteTask(task.id);
    //remote the task from the list in memory
    tasks.removeAt(index);
    notifyListeners();
  }
}