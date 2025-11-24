import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:ghi_no/test.dart';

import 'app.dart';
import 'firebase_options.dart'; // file từ flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Chạy app
  runApp(const App());
  //runApp(const MaterialApp(home: FirestoreTestScreen(),));//test connect firebase

}
