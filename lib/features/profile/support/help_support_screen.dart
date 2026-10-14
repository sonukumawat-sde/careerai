import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_gradients.dart';
import 'faq_data.dart';

/// Help & Support — FAQs (search + categories + expand) + contact actions.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _category = 'All';
  String _search = '';
  int? _expandedIndex;

  // Support contacts (launch pe asli daal dena)
  static const _supportEmail = 'support@careerai.app';
  static const _supportPhone = '919999999999'; // WhatsApp number

  List<FaqItem> get _filtered {
    return allFaqs.where((f) {
      final matchCategory = _category == 'All' || f.category == _category;
      final matchSearch = _search.isEmpty ||
          f.question.toLowerCase().contains(_search.toLowerCase()) ||
          f.answer.toLowerCase().contains(_search.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  Future<void> _emailSupport() async {
    final uri = Uri.parse(
        'mailto:$_supportEmail?subject=CareerAI Support Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsappSupport() async {
    final uri = Uri.parse('https://wa.me/$_supportPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          // ---- Hero ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppBrand.violet.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How can we help?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Search our FAQs or contact our support team.',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: Color(0xFF94A3B8), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          decoration: const InputDecoration(
                            hintText: 'Search for help...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---- Contact options ----
          Row(
            children: [
              Expanded(
                child: _contactCard(
                  Icons.mail_outline,
                  'Email Us',
                  'Get a reply in 24h',
                  AppBrand.violet,
                  _emailSupport,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _contactCard(
                  Icons.chat_bubble_outline,
                  'WhatsApp',
                  'Chat with us',
                  const Color(0xFF22C55E),
                  _whatsappSupport,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Category chips ----
          const Text('Frequently Asked Questions',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: faqCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = faqCategories[i];
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() {
                    _category = cat;
                    _expandedIndex = null;
                  }),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: selected ? AppGradients.buttonGradient : null,
                      color: selected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ---- FAQs (expandable) ----
          if (faqs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off,
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
                        size: 44),
                    const SizedBox(height: 12),
                    const Text('No results found',
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else
            ...faqs.asMap().entries.map((entry) {
              final i = entry.key;
              final faq = entry.value;
              final expanded = _expandedIndex == i;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: expanded
                        ? AppBrand.violet.withValues(alpha: 0.3)
                        : const Color(0xFFEEF1F5),
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(
                          () => _expandedIndex = expanded ? null : i),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(faq.question,
                                  style: TextStyle(
                                      color: expanded
                                          ? AppBrand.violet
                                          : const Color(0xFF0F172A),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: expanded
                                  ? AppBrand.violet
                                  : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(faq.answer,
                              style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13.5,
                                  height: 1.5)),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _contactCard(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}