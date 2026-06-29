import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_content_model.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';

class AssociationChatScreen extends ConsumerWidget {
  const AssociationChatScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  static const _avatarColors = [
    Color(0xFF2A4A6B),
    Color(0xFF2D7A4F),
    Color(0xFFB45309),
    Color(0xFFC0392B),
    Color(0xFF6B3FA0),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final async = ref.watch(associationChatsProvider(assoc.id));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          async.when(
            loading: () => ListView.builder(
              padding: EdgeInsets.fromLTRB(0, topPad + 64, 0, 24),
              itemCount: 4,
              itemBuilder: (_, __) => _ShimmerRow(colors: colors),
            ),
            error: (_, __) => Center(
              child: GestureDetector(
                onTap: () => ref.invalidate(associationChatsProvider),
                child: Text('Retry',
                    style: AppTypography.label.copyWith(
                        color: colors.goldPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
            data: (chats) => chats.isEmpty
                ? Center(
                    child: Text('No conversations yet',
                        style: AppTypography.body.copyWith(color: colors.ink600)))
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, topPad + 64, 0, 24),
                    itemCount: chats.length,
                    itemBuilder: (_, i) => _ChatRow(
                      chat: chats[i],
                      avatarColor: _avatarColors[i % _avatarColors.length],
                      colors: colors,
                      onTap: () => context.push(
                        RouteNames.associationChatThread
                            .replaceFirst(':id', assoc.id)
                            .replaceFirst(':chatId', chats[i].id),
                        extra: chats[i],
                      ),
                    ),
                  ),
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
                Text('Chat',
                    style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          height: 60,
          decoration: BoxDecoration(color: colors.surfaceCard, borderRadius: BorderRadius.circular(12)),
        ),
      );
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat, required this.avatarColor, required this.colors, required this.onTap});
  final AssociationChatModel chat;
  final Color avatarColor;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = chat.name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.lineSoft)),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(chat.name,
                    style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(chat.lastMessage,
                    style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 11),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(chat.time, style: AppTypography.caption.copyWith(color: colors.ink400, fontSize: 10)),
              if (chat.unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colors.goldPrimary),
                  child: Center(
                    child: Text(chat.unreadCount.toString(),
                        style: TextStyle(color: colors.ink900, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Chat thread screen ────────────────────────────────────────────────────────

class AssociationChatThreadScreen extends StatefulWidget {
  const AssociationChatThreadScreen({super.key, required this.chat});
  final AssociationChatModel chat;

  @override
  State<AssociationChatThreadScreen> createState() =>
      _AssociationChatThreadScreenState();
}

class _AssociationChatThreadScreenState
    extends State<AssociationChatThreadScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final _messages = <_Msg>[
    _Msg(text: 'Hi! I need Bali rates for July.', isMe: false, time: '10:28 AM'),
    _Msg(text: 'Sure! 6N/7D for 2 pax would be ₹82,000 per person including transfers.', isMe: true, time: '10:29 AM'),
    _Msg(text: 'Does that include 4-star hotel?', isMe: false, time: '10:30 AM'),
    _Msg(text: 'Yes, 4-star with breakfast. Want me to send the full itinerary?', isMe: true, time: '10:31 AM'),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isMe: true, time: 'Now'));
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topPad + 64),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _MsgBubble(msg: _messages[i], colors: colors),
                ),
              ),
              // Input bar
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  border: Border(top: BorderSide(color: colors.lineSoft)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: colors.surfacePrimary,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: colors.lineSoft),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Message…',
                            hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: colors.goldPrimary),
                        child: Icon(Icons.send_rounded, color: colors.ink900, size: 18),
                      ),
                    ),
                  ],
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
                Expanded(
                  child: Text(widget.chat.name,
                      style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  const _Msg({required this.text, required this.isMe, required this.time});
  final String text;
  final bool isMe;
  final String time;
}

class _MsgBubble extends StatelessWidget {
  const _MsgBubble({required this.msg, required this.colors});
  final _Msg msg;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          msg.isMe ? 60 : 20, 0, msg.isMe ? 20 : 60, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMe ? colors.ink900 : colors.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(msg.isMe ? 14 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 14),
          ),
          border: msg.isMe ? null : Border.all(color: colors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg.text,
                style: AppTypography.body.copyWith(
                    color: msg.isMe ? colors.surfacePrimary : colors.ink900,
                    fontSize: 13,
                    height: 1.45)),
            const SizedBox(height: 4),
            Text(msg.time,
                style: AppTypography.caption.copyWith(
                    color: msg.isMe
                        ? colors.surfacePrimary.withValues(alpha: 0.5)
                        : colors.ink400,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
