import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PPPScreen extends StatelessWidget {
  const PPPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        title: Text('PPP', style: AppTypography.titleMedium.copyWith(color: colors.ink900)),
        elevation: 0,
      ),
      body: Center(
        child: Text('PPP module placeholder', style: AppTypography.body.copyWith(color: colors.ink600)),
      ),
    );
  }
}
