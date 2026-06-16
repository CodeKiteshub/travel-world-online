import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

enum SpaceChipStyle { success, warning, error, info }

class SpaceSubAppBar extends StatelessWidget {
  const SpaceSubAppBar({
    super.key,
    required this.title,
    required this.topPad,
    required this.colors,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final double topPad;
  final AppColorScheme colors;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: colors.surfacePrimary,
        padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceCard,
                  border: Border.all(color: colors.lineSoft),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: colors.ink900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: colors.ink900,
                ),
              ),
            ),
            if (actionIcon != null)
              GestureDetector(
                onTap: onAction,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceCard,
                    border: Border.all(color: colors.lineSoft),
                  ),
                  child: Center(
                    child: Icon(
                      actionIcon,
                      size: 18,
                      color: colors.ink900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SpaceFilterPills extends StatelessWidget {
  const SpaceFilterPills({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
    required this.colors,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isActive = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? colors.ink900 : Colors.transparent,
                border: Border.all(
                  color: isActive ? colors.ink900 : colors.lineSoft,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? colors.surfacePrimary : colors.ink600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SpaceStatusChip extends StatelessWidget {
  const SpaceStatusChip({
    super.key,
    required this.label,
    required this.style,
    required this.colors,
  });

  final String label;
  final SpaceChipStyle style;
  final AppColorScheme colors;

  Color _dotColor() {
    switch (style) {
      case SpaceChipStyle.success:
        return colors.success;
      case SpaceChipStyle.warning:
        return colors.warning;
      case SpaceChipStyle.error:
        return colors.error;
      case SpaceChipStyle.info:
        return const Color(0xFF2A4A6B);
    }
  }

  Color _bgColor() {
    switch (style) {
      case SpaceChipStyle.success:
        return colors.success.withValues(alpha: 0.12);
      case SpaceChipStyle.warning:
        return colors.warning.withValues(alpha: 0.12);
      case SpaceChipStyle.error:
        return colors.error.withValues(alpha: 0.12);
      case SpaceChipStyle.info:
        return const Color(0xFFE8EEF5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dot = _dotColor();
    final bg = _bgColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: dot,
              letterSpacing: 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
