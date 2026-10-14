import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../services/supabase_service.dart';
import 'profile_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Edit Profile — naam, phone, bio edit karo (real, database me save).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _avatarUrl;
  File? _pickedImage;
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final result = await ProfileService.getProfile();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
    (data) => setState(() {
        _nameController.text = (data['full_name'] ?? '').toString();
        _phoneController.text = (data['phone'] ?? '').toString();
        _bioController.text = (data['bio'] ?? '').toString();
        _avatarUrl = (data['avatar_url'] ?? '').toString();
        if (_avatarUrl!.isEmpty) _avatarUrl = null;
        _loading = false;
      }),
    );
  }

Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _pickedImage = File(picked.path);
      _uploadingPhoto = true;
    });

    final result = await ProfileService.uploadAvatar(File(picked.path));
    if (!mounted) return;
    setState(() => _uploadingPhoto = false);
    result.match(
      (failure) => _showMsg(failure.message, false),
      (url) {
        setState(() => _avatarUrl = url);
        _showMsg('Photo updated!', true);
      },
    );
  }
  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ProfileService.updateProfile({
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    result.match(
      (failure) => _showMsg(failure.message, false),
      (_) {
        _showMsg('Profile updated!', true);
        Navigator.pop(context);
      },
    );
  }

  void _showMsg(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppBrand.violet : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = SupabaseService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                // Avatar
               Center(
                  child: GestureDetector(
                    onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppGradients.buttonGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppBrand.violet.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _uploadingPhoto
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : _pickedImage != null
                                  ? Image.file(_pickedImage!,
                                      fit: BoxFit.cover)
                                  : (_avatarUrl != null
                                      ? Image.network(
                                          _avatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _initial(),
                                        )
                                      : _initial()),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFEEF1F5), width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: AppBrand.violet, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                _label('Full Name'),
                _field(_nameController, 'Enter your name', Icons.person_outline),
                const SizedBox(height: 18),

                _label('Email'),
                _field(
                  TextEditingController(text: email),
                  '',
                  Icons.mail_outline,
                  enabled: false,
                ),
                const SizedBox(height: 18),

                _label('Phone'),
                _field(_phoneController, 'Enter phone number',
                    Icons.phone_outlined,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 18),

                _label('Bio'),
                _field(_bioController, 'Tell us about yourself...',
                    Icons.edit_outlined,
                    maxLines: 3),
                const SizedBox(height: 32),

                // Save button
                GestureDetector(
                  onTap: _saving ? null : _save,
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
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Save Changes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
  Widget _initial() {
    return Center(
      child: Text(
        _nameController.text.isNotEmpty
            ? _nameController.text[0].toUpperCase()
            : 'U',
        style: const TextStyle(
            color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _field(TextEditingController controller, String hint, IconData icon,
      {bool enabled = true,
      TextInputType? keyboard,
      int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}