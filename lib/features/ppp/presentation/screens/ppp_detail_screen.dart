import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ppp_model.dart';

class PPPDetailScreen extends StatelessWidget {
  const PPPDetailScreen({super.key, required this.id, this.item});
  final String id;
  final PppItem? item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(item?.name ?? id,
            style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700,
                fontSize: 18, color: colors.ink900)),
      ),
      body: Center(child: Text('PPP Detail — $id',
          style: TextStyle(color: colors.ink600))),
    );
  }
}
