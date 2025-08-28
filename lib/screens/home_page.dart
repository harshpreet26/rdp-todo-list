import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/providers/task_provider.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
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
            Expanded(child: Image.asset('assets/rdplogo.png', height: 80)),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    focusedDay: DateTime.now(),
                    firstDay: DateTime(2025),
                    lastDay: DateTime(2026),
                  ),
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      return buildTaskItem(
                        taskProvider.tasks,
                        taskProvider.removeTask,
                        taskProvider.updateTask,
                      );
                    },
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
            ),
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

//Widget that displays the task items on the UI
Widget buildTaskItem(
  List<Task> tasks,
  Function(int) removeTasks,
  Function(int, bool) updateTask,
) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: tasks.length,
    itemBuilder: (context, index) {
      final task = tasks[index];
      final isEven = index % 2 == 0;

      return Padding(
        padding: EdgeInsets.all(1.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: isEven ? Colors.blue : Colors.green,
          leading: Icon(
            task.completed ? Icons.check_circle : Icons.circle_outlined,
          ),
          title: Text(
            task.name,
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,
              fontSize: 22,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (value) => {updateTask(index, value!)},
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => removeTasks(index),
              ),
            ],
          ),
        ),
      );
    },
  );
}
