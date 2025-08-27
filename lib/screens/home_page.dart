import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

//blueprint for task
class Task {
  final String id;
  final String name;
  final bool completed;

  Task({required this.id, required this.name, required this.completed});

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'] ?? '',
      completed: data['completed'] ?? false,
    );
  }
}

//Define a Task Service to handle Firestone operations
class TaskService {
  //Firestore instance in an alias
  final FirebaseFirestore db = FirebaseFirestore.instance;

  //Future that returns a list of tasks using factory method defined in task class
  Future<List<Task>> fetchTasks() async {
    //call get to retrieve all of the documents inside the collection
    final snapshot = await db.collection('tasks').orderBy('timestamp').get();
    //snapshot of all documents is being mapped to factory object template
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList();
  }

  //another asynchronous future to add a task to the firestore
  Future<String> addTask(String name) async {
    final newTask = {
      'name': name,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    };
    final docRef = await db.collection('tasks').add(newTask);
    return docRef.id;
  }

  //update task future
  Future<void> updateTask(String id, bool completed) async {
    await db.collection('tasks').doc(id).update({'completed': completed});
  }

  //Future is going to delete task
  Future<void> deleteTask(String id) async {
    await db.collection('tasks').doc(id).delete();
  }
}

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

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => Home_PageState();
}

class Home_PageState extends State<Home_Page> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).LoadTasks();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: Image.asset('assets/rdplogo.png')),
            const Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.month,
            focusedDay: DateTime.now(),
            firstDay: DateTime(2025),
            lastDay: DateTime(2026),
          ),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return buildAddTaskSection(nameController, () async {
                await taskProvider.addTask(nameController.text);
                nameController.clear();
              });
            },
          ),
        ],
      ),
      drawer: Drawer(),
    );
  }
}

//Build the section for adding tasks
Widget buildAddTaskSection(nameController, addTask) {
  return Container(
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      children: [
        Expanded(
          child: Container(
            child: TextField(
              maxLength: 32,
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Add Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        ElevatedButton(onPressed: addTask, child: Text('Add Task')),
      ],
    ),
  );
}
