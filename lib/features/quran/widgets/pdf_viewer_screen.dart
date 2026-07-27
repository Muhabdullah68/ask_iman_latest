import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:io';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String? url;
  final String? localPath;
  final String? assetPath;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.url,
    this.localPath,
    this.assetPath,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  void initState() {
    super.initState();
    // Force portrait mode when PDF viewer is opened
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Revert to original orientations when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget pdfViewer = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryDark),
          SizedBox(height: 16),
          Text('Loading PDF...', style: TextStyle(fontFamily: 'Cairo')),
        ],
      ),
    );

    if (widget.assetPath != null) {
      try {
        pdfViewer = SfPdfViewer.asset(
          widget.assetPath!,
          initialScrollOffset: const Offset(0, 0),
          pageLayoutMode: PdfPageLayoutMode.continuous,
          scrollDirection: PdfScrollDirection.vertical,
        );
      } catch (e) {
        debugPrint('Error loading asset PDF: $e');
        pdfViewer = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load PDF',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text('$e'),
            ],
          ),
        );
      }
    } else if (widget.localPath != null &&
        File(widget.localPath!).existsSync()) {
      pdfViewer = SfPdfViewer.file(
        File(widget.localPath!),
        initialScrollOffset: const Offset(0, 0),
        pageLayoutMode: PdfPageLayoutMode.continuous,
        scrollDirection: PdfScrollDirection.vertical,
      );
    } else if (widget.url != null) {
      pdfViewer = SfPdfViewer.network(
        widget.url!,
        initialScrollOffset: const Offset(0, 0),
        pageLayoutMode: PdfPageLayoutMode.continuous,
        scrollDirection: PdfScrollDirection.vertical,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: pdfViewer,
    );
  }
}
