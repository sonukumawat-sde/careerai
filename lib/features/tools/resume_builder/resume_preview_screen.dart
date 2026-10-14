import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/premium/premium_service.dart';
import '../../../core/premium/premium_widgets.dart';
import 'resume_builder_data.dart';
import 'templates/template_selection_screen.dart';
import 'resume_pdf_service.dart';
import 'pdf_viewer_screen.dart';

/// Resume Preview — chosen template ke hisaab se design + download.
class ResumePreviewScreen extends StatefulWidget {
  final ResumeData data;
  final String templateId;

  const ResumePreviewScreen({
    super.key,
    required this.data,
    this.templateId = 'modern',
  });

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  ResumeTemplate get _template => resumeTemplates.firstWhere(
        (t) => t.id == widget.templateId,
        orElse: () => resumeTemplates.first,
      );

  Future<void> _download() async {
    // Premium gating — 3 free downloads
    final canUse = await PremiumService.canUse(
        'resume_builder', FeatureLimits.resumeBuilder);
    if (!canUse) {
      if (!mounted) return;
      showPremiumLock(
        context,
        feature: 'Resume Builder',
        benefits: const [
          'Unlimited resume downloads',
          '10+ premium industry templates',
          'AI-powered content writing',
          'Advanced ATS optimization',
        ],
      );
      return;
    }

    // Loading dialog dikhao
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('Generating your resume...',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );

    // PDF banao (server se, chosen template)
    final file =
        await ResumePdfService.generatePdf(widget.data, widget.templateId);

    if (!mounted) return;
    Navigator.pop(context); // loading band

    if (file != null) {
      // Usage record + in-app PDF viewer khol
      await PremiumService.recordUsage('resume_builder');
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            file: file,
            title: '${_template.name} Resume',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Could not generate PDF. Please check your internet and try again.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _template.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: Text('${_template.name} Template'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          // Resume paper
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _buildTemplate(color),
          ),
          const SizedBox(height: 24),

          // Download button
          GestureDetector(
            onTap: _download,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.buttonGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppBrand.violet.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Download PDF',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Template ke hisaab se design.
  Widget _buildTemplate(Color color) {
    switch (widget.templateId) {
      case 'professional':
        return _professionalTemplate(color);
      case 'minimal':
        return _minimalTemplate(color);
      default:
        return _modernTemplate(color);
    }
  }

  // ---- MODERN: bold gradient header ----
  Widget _modernTemplate(Color color) {
    final d = widget.data;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              Text(d.fullName.isEmpty ? 'Your Name' : d.fullName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (d.email.isNotEmpty) _contact(Icons.mail, d.email, true),
                  if (d.phone.isNotEmpty) _contact(Icons.phone, d.phone, true),
                  if (d.location.isNotEmpty)
                    _contact(Icons.location_on, d.location, true),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _body(color),
        ),
      ],
    );
  }

  // ---- PROFESSIONAL: side accent, formal ----
  Widget _professionalTemplate(Color color) {
    final d = widget.data;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.fullName.isEmpty ? 'Your Name' : d.fullName,
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Container(height: 3, width: 60, color: color),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              if (d.email.isNotEmpty) _contact(Icons.mail, d.email, false),
              if (d.phone.isNotEmpty) _contact(Icons.phone, d.phone, false),
              if (d.location.isNotEmpty)
                _contact(Icons.location_on, d.location, false),
            ],
          ),
          const SizedBox(height: 20),
          _body(color),
        ],
      ),
    );
  }

  // ---- MINIMAL: clean, centered ----
  Widget _minimalTemplate(Color color) {
    final d = widget.data;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(d.fullName.isEmpty ? 'Your Name' : d.fullName,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              if (d.email.isNotEmpty) _contact(Icons.mail, d.email, false),
              if (d.phone.isNotEmpty) _contact(Icons.phone, d.phone, false),
              if (d.location.isNotEmpty)
                _contact(Icons.location_on, d.location, false),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: _body(color)),
        ],
      ),
    );
  }

  // ---- Common body (summary, experience, education, skills) ----
  Widget _body(Color color) {
    final d = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (d.summary.isNotEmpty) ...[
          _sectionTitle('SUMMARY', color),
          const SizedBox(height: 6),
          Text(d.summary,
              style: const TextStyle(
                  color: Color(0xFF475569), fontSize: 12.5, height: 1.6)),
          const SizedBox(height: 18),
        ],
        if (d.experiences.isNotEmpty) ...[
          _sectionTitle('EXPERIENCE', color),
          const SizedBox(height: 10),
          ...d.experiences.map((e) => _expEntry(e, color)),
          const SizedBox(height: 8),
        ],
        if (d.educations.isNotEmpty) ...[
          _sectionTitle('EDUCATION', color),
          const SizedBox(height: 10),
          ...d.educations.map((e) => _eduEntry(e, color)),
          const SizedBox(height: 8),
        ],
        if (d.skills.isNotEmpty) ...[
          _sectionTitle('SKILLS', color),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: d.skills
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _contact(IconData icon, String text, bool white) {
    final c = white ? Colors.white70 : const Color(0xFF64748B);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: c, size: 12),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: c, fontSize: 11)),
      ],
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        const SizedBox(height: 3),
        Container(height: 2, width: 36, color: color),
      ],
    );
  }

  Widget _expEntry(Experience exp, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exp.jobTitle.isEmpty ? 'Job Title' : exp.jobTitle,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Row(
            children: [
              Text(exp.company,
                  style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              if (exp.duration.isNotEmpty)
                Text('  ·  ${exp.duration}',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
          if (exp.description.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(exp.description,
                style: const TextStyle(
                    color: Color(0xFF475569), fontSize: 12, height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _eduEntry(Education edu, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(edu.degree.isEmpty ? 'Degree' : edu.degree,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Row(
            children: [
              Text(edu.institution,
                  style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              if (edu.year.isNotEmpty)
                Text('  ·  ${edu.year}',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}