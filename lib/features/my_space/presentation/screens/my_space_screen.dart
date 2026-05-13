import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MySpaceScreen extends StatelessWidget {
  const MySpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view_rounded, size: 48, color: colors.ink400),
            const SizedBox(height: 12),
            Text(
              'My Space',
              style: AppTypography.displayMd.copyWith(color: colors.ink900),
            ),
            const SizedBox(height: 6),
            Text(
              'Coming soon',
              style: AppTypography.body.copyWith(color: colors.ink400),
            ),
          ],
        ),
      ),
    );
  }
}
