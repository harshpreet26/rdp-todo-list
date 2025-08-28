import 'package:flutter/material.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:myapp/providers/task_provider.dart';

void main() async {
  //initialize widget bindings
  WidgetsFlutterBinding.ensureInitialized();
  //Initialize Firebase with the platform
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (Context) => TaskProvider(),
      child: const MaterialApp(home: Home_Page()),
    );
  }
}
