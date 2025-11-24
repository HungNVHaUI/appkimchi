import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({super.key});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  String log = "";

  void addLog(String text) {
    setState(() => log += "$text\n");
  }

  /// TEST WRITE
  Future<void> testWrite() async {
    addLog("🔵 Bắt đầu ghi dữ liệu...");

    try {
      await FirebaseFirestore.instance.collection("test").add({
        "time": DateTime.now().toIso8601String(),
        "message": "Hello Firestore!"
      });

      addLog("🟢 Ghi thành công!");
    } catch (e) {
      addLog("🔴 Lỗi ghi: $e");
    }
  }

  /// TEST READ
  Future<void> testRead() async {
    addLog("🔵 Đọc dữ liệu...");

    try {
      final snap = await FirebaseFirestore.instance
          .collection("test_collection")
          .orderBy("time", descending: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        addLog("⚠ Không có dữ liệu để đọc!");
      } else {
        addLog("🟢 Đọc thành công: ${snap.docs.first.data()}");
      }
    } catch (e) {
      addLog("🔴 Lỗi đọc: $e");
    }
  }

  /// TEST CONNECTIVITY
  Future<void> testConnection() async {
    addLog("🔵 Kiểm tra kết nối Firestore...");

    try {
      await FirebaseFirestore.instance.collection("test_connection").get();
      addLog("🟢 Kết nối OK");
    } catch (e) {
      addLog("🔴 Lỗi kết nối: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firestore Test Tool")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: testConnection,
              child: const Text("Test Firestore Connection"),
            ),
            ElevatedButton(
              onPressed: testWrite,
              child: const Text("Test Write"),
            ),
            ElevatedButton(
              onPressed: testRead,
              child: const Text("Test Read"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  log,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



