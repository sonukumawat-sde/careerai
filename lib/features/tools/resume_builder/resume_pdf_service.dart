import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'resume_builder_data.dart';
import 'latex_generator.dart';

/// Resume PDF banao — LaTeX server se.
class ResumePdfService {
  // Tera Render server URL
  static const String _serverUrl =
      'https://careerai-latex-server.onrender.com/compile';

  /// User data -> LaTeX -> server -> PDF file (local path).
  /// Returns: PDF file ka local path, ya null (fail).
 static Future<File?> generatePdf(ResumeData data, String templateId) async {
    try {
      // 1. Data se LaTeX code banao (chosen template)
      final latexCode = LatexGenerator.generate(data, templateId);

      // 2. Server ko bhejo
      final response = await http
          .post(
            Uri.parse(_serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: '{"latex": ${_jsonEscape(latexCode)}}',
          )
          .timeout(const Duration(seconds: 90));

      // 3. PDF mila?
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final fileName =
            'resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        // Error - server ne PDF nahi bheja
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// LaTeX string ko JSON-safe banao.
  static String _jsonEscape(String text) {
    final escaped = text
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
    return '"$escaped"';
  }
}