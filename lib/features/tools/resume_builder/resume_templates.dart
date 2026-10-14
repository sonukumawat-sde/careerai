import 'package:flutter/material.dart';

/// Ek resume template ka data.
class ResumeTemplate {
  final String id; // 'jake', 'classic', 'modern', 'lato'
  final String name;
  final String description;
  final String previewAsset; // thumbnail image path
  final Color accentColor;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.previewAsset,
    required this.accentColor,
  });
}

/// 4 free templates.
const List<ResumeTemplate> kResumeTemplates = [
  ResumeTemplate(
    id: 'jake',
    name: 'Classic Pro',
    description: 'Clean single-column layout. Most popular ATS-friendly design.',
    previewAsset: 'assets/templates/jake.png',
    accentColor: Color(0xFF8B5CF6),
  ),
  ResumeTemplate(
    id: 'lato',
    name: 'Modern Sans',
    description: 'Contemporary design with a clean sans-serif font and icons.',
    previewAsset: 'assets/templates/lato.png',
    accentColor: Color(0xFF3B82F6),
  ),
  ResumeTemplate(
    id: 'modern',
    name: 'Executive',
    description: 'Professional layout with detailed sections and labels.',
    previewAsset: 'assets/templates/modern.png',
    accentColor: Color(0xFF22C55E),
  ),
  ResumeTemplate(
    id: 'classic',
    name: 'Elegant',
    description: 'Centered header with elegant styling and colored links.',
    previewAsset: 'assets/templates/classic.png',
    accentColor: Color(0xFFF59E0B),
  ),
];