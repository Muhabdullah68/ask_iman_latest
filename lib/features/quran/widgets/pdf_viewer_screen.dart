import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:io';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String? url;
  final String? localPath;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.url,
    this.localPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: localPath != null && File(localPath!).existsSync()
          ? SfPdfViewer.file(File(localPath!))
          : url != null
              ? SfPdfViewer.network(url!)
              : const Center(child: Text('No PDF source available')),
    );
  }
}
