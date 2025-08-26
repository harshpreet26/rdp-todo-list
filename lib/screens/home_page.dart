import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
class TaskProvider extends ChangeNotifier {}

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => Home_PageState();
}

class Home_PageState extends State<Home_Page> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Hello'));
  }
}
