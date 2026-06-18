import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DestSubSubCategoryScreen extends StatelessWidget {
  const DestSubSubCategoryScreen({
    super.key,
    required this.catId,
    required this.subCatId,
  });

  final String catId;
  final String subCatId;

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
          'Sub-category $subCatId',
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
          'Stub — $catId / $subCatId',
          style: TextStyle(color: colors.ink600),
        ),
      ),
    );
  }
}
