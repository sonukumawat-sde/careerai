import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_gradients.dart';
import '../../features/home/home_provider.dart';

/// Reusable user avatar — photo ho to photo, warna naam ka initial.
/// Home aur Profile dono me same. Photo change ho to dono jagah update.
class UserAvatar extends ConsumerWidget {
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    this.radius = 20,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarAsync = ref.watch(avatarUrlProvider);
    final nameAsync = ref.watch(userNameProvider);

   final url = avatarAsync.value;
    // Photo hai to photo dikhao
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppBrand.violet.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(url),
      );
    }

    // Warna naam ka initial
    final name = nameAsync.value ?? 'U';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppBrand.violet.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: AppBrand.violet,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}