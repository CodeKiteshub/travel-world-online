import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DestinationSpecialistScreen extends StatelessWidget {
  const DestinationSpecialistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Destination Specialist',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.ink900,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Destination Specialist — coming',
          style: TextStyle(color: colors.ink600),
        ),
      ),
    );
  }
}
