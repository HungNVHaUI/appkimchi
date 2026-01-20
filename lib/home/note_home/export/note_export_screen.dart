import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../note_detail_controller.dart';
import 'note_export_view.dart';

class NoteExportScreen extends StatefulWidget {
  final NoteDetailController controller;

  const NoteExportScreen({super.key, required this.controller});

  @override
  State<NoteExportScreen> createState() => _NoteExportScreenState();
}

class _NoteExportScreenState extends State<NoteExportScreen> {
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _waitAndCapture();
  }

  Future<void> _waitAndCapture() async {
    /// Đợi frame đầu
    await WidgetsBinding.instance.endOfFrame;

    /// Đợi thêm 1 frame nữa (RẤT QUAN TRỌNG)
    await Future.delayed(const Duration(milliseconds: 50));

    if (!mounted) return;

    final boundary =
    _captureKey.currentContext?.findRenderObject()
    as RenderRepaintBoundary?;

    if (boundary == null || boundary.debugNeedsPaint) {
      /// Nếu chưa paint xong → đợi thêm
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final ui.Image image =
    await boundary!.toImage(pixelRatio: 3);

    final byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);

    if (!mounted) return;
    Navigator.of(context).pop(byteData!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _captureKey,
          child: NoteExportView(controller: widget.controller),
        ),
      ),

    );
  }
}


