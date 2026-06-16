import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CampusScreen extends StatelessWidget {
  const CampusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        title: Text('Campus', style: AppTypography.titleMedium.copyWith(color: colors.ink900)),
        elevation: 0,
      ),
      body: Center(
        child: Text('Campus module placeholder', style: AppTypography.body.copyWith(color: colors.ink600)),
      ),
    );
  }
}
