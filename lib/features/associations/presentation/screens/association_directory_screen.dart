import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_content_model.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';

class AssociationDirectoryScreen extends ConsumerStatefulWidget {
  const AssociationDirectoryScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationDirectoryScreen> createState() =>
      _AssociationDirectoryScreenState();
}

class _AssociationDirectoryScreenState
    extends ConsumerState<AssociationDirectoryScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  static const _avatarColors = [
    Color(0xFF2A4A6B),
    Color(0xFF2D7A4F),
    Color(0xFFB45309),
    Color(0xFFC0392B),
    Color(0xFF6B3FA0),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final async = ref.watch(associationMembersProvider(
      (assocId: widget.assoc.id, query: _query),
    ));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(0, topPad + 64, 0, 24),
            children: [
              _SearchBar(ctrl: _ctrl, colors: colors,
                  onChanged: (v) => setState(() => _query = v)),
              async.when(
                loading: () => Column(
                  children: List.generate(6, (_) => _ShimmerRow(colors: colors)),
                ),
                error: (_, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: GestureDetector(
                      onTap: () => ref.invalidate(associationMembersProvider),
                      child: Text('Retry',
                          style: AppTypography.label.copyWith(
                              color: colors.goldPrimary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                data: (members) => members.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                            _query.isEmpty ? 'Search for members' : 'No members found',
                            style: AppTypography.body.copyWith(color: colors.ink600),
                          ),
                        ),
                      )
                    : Column(
                        children: members
                            .asMap()
                            .entries
                            .map((e) => _MemberRow(
                                  member: e.value,
                                  avatarColor: _avatarColors[e.key % _avatarColors.length],
                                  isLast: e.key == members.length - 1,
                                  colors: colors,
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceCard, border: Border.all(color: colors.lineSoft)),
                    child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Member Directory',
                    style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.avatarColor,
    required this.isLast,
    required this.colors,
  });
  final AssociationMemberModel member;
  final Color avatarColor;
  final bool isLast;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final initials = member.name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: colors.lineSoft)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(member.name,
                  style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w600)),
              if (member.role != null || member.city != null)
                Text(
                  [member.role, member.city].whereType<String>().join(' · '),
                  style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 11),
                ),
            ]),
          ),
          if (member.phone != null)
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('tel:${member.phone}')),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.call_outlined, color: colors.success, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.ctrl, required this.colors, required this.onChanged});
  final TextEditingController ctrl;
  final AppColorScheme colors;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 18, color: colors.ink400),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: ctrl,
            onChanged: onChanged,
            style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by name…',
              hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ]),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: colors.surfaceTertiary,
        highlightColor: colors.surfaceCard,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          height: 56,
          decoration: BoxDecoration(color: colors.surfaceCard, borderRadius: BorderRadius.circular(12)),
        ),
      );
}
