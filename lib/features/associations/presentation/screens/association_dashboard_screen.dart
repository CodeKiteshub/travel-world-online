import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_model.dart';
import '../providers/association_session_provider.dart';

const _tileBlue = Color(0xFFE8EEF5);
const _tileBlueText = Color(0xFF2A4A6B);

class AssociationDashboardScreen extends ConsumerStatefulWidget {
  const AssociationDashboardScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationDashboardScreen> createState() =>
      _AssociationDashboardScreenState();
}

class _AssociationDashboardScreenState
    extends ConsumerState<AssociationDashboardScreen> {
  YoutubePlayerController? _yt;

  static const _defaultVideoId = 'dQw4w9WgXcQ';

  @override
  void initState() {
    super.initState();
    _initYt(_defaultVideoId);
  }

  void _initYt(String videoId) {
    _yt = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: true,
        loop: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _yt?.dispose();
    super.dispose();
  }

  String _sub(String route) => route.replaceFirst(':id', widget.assoc.id);

  void _confirmLogout(BuildContext context, AppColorScheme colors) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign out of ${widget.assoc.name}?',
          style: AppTypography.body.copyWith(
            color: colors.ink900,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.label.copyWith(color: colors.ink600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(associationSessionProvider.notifier)
                  .logout(widget.assoc.id);
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              context.go(RouteNames.associations);
            },
            child: Text('Sign Out',
                style: AppTypography.label
                    .copyWith(color: colors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(0, topPad + 64, 0, 32),
            children: [
              // ── Live TV banner
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _yt == null
                        ? _LivePlaceholder(colors: colors)
                        : YoutubePlayer(
                            controller: _yt!,
                            showVideoProgressIndicator: true,
                            onReady: () {},
                          ),
                  ),
                ),
              ),

              // ── Network Deals (full-width card)
              _FullCard(
                icon: Icons.local_offer_outlined,
                iconBg: _tileBlue,
                iconColor: _tileBlueText,
                title: 'Network Deals',
                preview: 'Browse packages, hotels & transport',
                countLabel: 'active',
                onTap: () => context.push(_sub(RouteNames.associationDeals),
                    extra: widget.assoc),
                colors: colors,
              ),

              // ── Circulars (full-width card)
              _FullCard(
                icon: Icons.description_outlined,
                iconBg: colors.error.withValues(alpha: 0.12),
                iconColor: colors.error,
                title: 'Circulars',
                preview: 'Latest advisories & notices',
                countLabel: 'new',
                onTap: () => context.push(_sub(RouteNames.associationCirculars),
                    extra: widget.assoc),
                colors: colors,
              ),

              // ── Updates + Chat (2-column)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _HalfCard(
                        icon: Icons.notifications_none_rounded,
                        iconBg: colors.success.withValues(alpha: 0.12),
                        iconColor: colors.success,
                        title: 'Updates',
                        preview: 'Latest from your association',
                        onTap: () => context.push(
                            _sub(RouteNames.associationUpdates),
                            extra: widget.assoc),
                        colors: colors,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HalfCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconBg: colors.goldPrimary.withValues(alpha: 0.15),
                        iconColor: colors.goldPrimary,
                        title: 'Chat',
                        preview: 'Member conversations',
                        onTap: () => context.push(
                            _sub(RouteNames.associationChat),
                            extra: widget.assoc),
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Jobs + Directory (2-column)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _HalfCard(
                        icon: Icons.work_outline_rounded,
                        iconBg: colors.warning.withValues(alpha: 0.12),
                        iconColor: colors.warning,
                        title: 'Jobs',
                        preview: 'Openings & postings',
                        onTap: () => context.push(
                            _sub(RouteNames.associationJobs),
                            extra: widget.assoc),
                        colors: colors,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HalfCard(
                        icon: Icons.people_outline_rounded,
                        iconBg: _tileBlue,
                        iconColor: _tileBlueText,
                        title: 'Directory',
                        preview: 'Find members',
                        onTap: () => context.push(
                            _sub(RouteNames.associationDirectory),
                            extra: widget.assoc),
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Cab Network + Admin Cab (2-column)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _HalfCard(
                        icon: Icons.airport_shuttle_outlined,
                        iconBg: colors.success.withValues(alpha: 0.12),
                        iconColor: colors.success,
                        title: 'Cab Network',
                        preview: 'Available drivers',
                        onTap: () => context.push(
                            _sub(RouteNames.associationCabs),
                            extra: widget.assoc),
                        colors: colors,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HalfCard(
                        icon: Icons.settings_outlined,
                        iconBg: colors.surfaceTertiary,
                        iconColor: colors.ink600,
                        title: 'Admin Cab',
                        preview: 'Manage fleet',
                        onTap: () => context.push(
                            _sub(RouteNames.associationAdminCabs),
                            extra: widget.assoc),
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── App bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    // canPop guard: the dashboard can be the stack root
                    // (deep link), where pop() throws.
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go(RouteNames.associations),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceCard,
                        border: Border.all(color: colors.lineSoft),
                      ),
                      child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.assoc.name,
                      style: AppTypography.displayMd.copyWith(
                        color: colors.ink900,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _confirmLogout(context, colors),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.error,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE',
                            style: AppTypography.overline.copyWith(
                              color: colors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full-width content-preview card ──────────────────────────────────────────

class _FullCard extends StatelessWidget {
  const _FullCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.preview,
    required this.countLabel,
    required this.onTap,
    required this.colors,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String preview;
  final String countLabel;
  final VoidCallback onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: colors.ink900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    style: AppTypography.caption.copyWith(
                      color: colors.ink600,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.ink400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Half-width card ───────────────────────────────────────────────────────────

class _HalfCard extends StatelessWidget {
  const _HalfCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.preview,
    required this.onTap,
    required this.colors,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String preview;
  final VoidCallback onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.body.copyWith(
                color: colors.ink900,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              preview,
              style: AppTypography.caption.copyWith(
                color: colors.ink600,
                fontSize: 11,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live TV placeholder (when youtube fails / no videoId) ────────────────────

class _LivePlaceholder extends StatelessWidget {
  const _LivePlaceholder({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1B2A), Color(0xFF1A3850)],
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.play_circle_outline_rounded,
              color: Colors.white54, size: 52),
        ),
        Positioned(
          top: 12, left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xE6C0392B), // rgba(192,57,43,.9)
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(),
                SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      );
}
