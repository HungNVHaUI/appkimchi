import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:ghi_no/test.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'navigation_menu.dart'; // file từ flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(NavigationController(), permanent: true);
  // Chạy app
  runApp(const App());
  //runApp(const MaterialApp(home: FirestoreTestScreen(),));//test connect firebase

}