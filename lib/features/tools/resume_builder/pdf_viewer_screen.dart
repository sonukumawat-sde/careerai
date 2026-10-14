import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_gradients.dart';

/// In-app PDF viewer — resume PDF app ke andar dikhao + download + share.
class PdfViewerScreen extends StatefulWidget {
  final File file;
  final String title;
  const PdfViewerScreen({
    super.key,
    required this.file,
    this.title = 'Resume Preview',
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _downloading = false;

  /// PDF ko phone ke public storage me copy karo (real download).
  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final fileName =
          'CareerAI_Resume_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Android: Downloads folder try karo, warna external storage
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final savePath = '${dir!.path}/$fileName';
      await widget.file.copy(savePath);

      if (!mounted) return;
      setState(() => _downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to Downloads: $fileName'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(savePath),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloading = false);
      // Fallback — external app me kholo
      await OpenFilex.open(widget.file.path);
    }
  }

  Future<void> _share() async {
    try {
      await Share.shareXFiles([XFile(widget.file.path)],
          text: 'My resume from CareerAI');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _share,
          ),
        ],
      ),
      body: PDFView(
        filePath: widget.file.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        color: const Color(0xFF0F172A),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: _downloading ? null : _download,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: AppGradients.buttonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _downloading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Download to Phone',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}