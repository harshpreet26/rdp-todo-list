// Import necessary packages and files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/providers/task_provider.dart';

// Define a stateful widget for the home page and constructor with optional key parameter
class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  // Override createState to return the state instance
  @override
  State<Home_Page> createState() => _Home_PageState();
}

// Define the state class for Home_Page and create textediting controller for task input
class _Home_PageState extends State<Home_Page> {
  final TextEditingController nameController = TextEditingController();

  // Override initState to perform initialization and call parent initstate 
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to run code after first frame is built and load tasks from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).LoadTasks();
    });
  }

  // Override build method to create the widget tree
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget as the root
    return Scaffold(
      // Set app bar properties, including background color and title
      // space children evenly along with the main axis and define children of the row
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Expanded widget to take available space and display logo image
            Expanded(
                child: Image.asset('assets/rdplogo.png', height: 80)),
            // Text widget for the app title to set text context, style, font style, size and color
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
      // Set body content as a column
      body: Column(
        // Children of the column
        children: [
          // Expanded widget to take available vertical space , allow scrolling for content, nested column for scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar widget for date selection and set calendar format to month view
                  TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    // Set initially focused day to current date set first and last available day
                    focusedDay: DateTime.now(),
                    firstDay: DateTime(2025),
                    lastDay: DateTime(2026),
                  ),
                  // Consumer widget to access task providerand builder function for the consumer
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      // Build task list using provider data which pass, remove the pass task and update the task function
                      return buildTaskItem(
                        taskProvider.tasks,
                        taskProvider.removeTask,
                        taskProvider.updateTask,
                      );
                    },
                  ),
                  // Another consumer for add task functionality which build, add task when button is pressed and clear the text field
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
      // Add empty drawer
      drawer: Drawer(),
    );
  }
}

// Build the section for adding tasks and return the container which set the background color for add task section
Widget buildAddTaskSection(nameController, addTask) {
  return Container(
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      // Children of the rowand expanded the widget for text field
      children: [
        Expanded(
          // Container for text field which include text field input, set maximum character limit, connect text controller
          // andset the decoration properties, label text, style of border
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
        // Button to add task
        ElevatedButton(onPressed: addTask, child: Text('Add Task')),
      ],
    ),
  );
}

// Widget that displays the task items on the UI and parameters for the function
Widget buildTaskItem(
  List<Task> tasks,
  Function(int) removeTasks,
  Function(int, bool) updateTask,
) {
  // Return a list view builder
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: tasks.length,
    itemBuilder: (context, index) {
      final task = tasks[index];
      final isEven = index % 2 == 0;

      // Return padding for each list tile 
      return Padding(
        padding: EdgeInsets.all(1.0),
        // Create list tile for each task which set shape with rounded corners and border radius
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // Alternate tile color based on index and leading icon choose the icon for completion staus 
          tileColor: isEven ? Colors.blue : Colors.green,
          leading: Icon(
            task.completed ? Icons.check_circle : Icons.circle_outlined,
          ),
          // set text context, style and add strikethrough if completed and font size
          title: Text(
            task.name,
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,
              fontSize: 22,
            ),
          ),
          // Trailing widgets for actions by setting minimum space and children of the trailing row
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checkbox for completion status which set the current value and handle change
              Checkbox(
                value: task.completed,
                onChanged: (value) => {updateTask(index, value!)},
              ),
              // add delete button for task and handle delete action
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