import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/ppp_model.dart';

class PppYoutubePlayerScreen extends StatefulWidget {
  const PppYoutubePlayerScreen({
    super.key,
    required this.videos,
    required this.initialVideo,
  });

  final List<PppVideo> videos;
  final PppVideo initialVideo;

  @override
  State<PppYoutubePlayerScreen> createState() => _PppYoutubePlayerScreenState();
}

class _PppYoutubePlayerScreenState extends State<PppYoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  late PppVideo _current;

  List<PppVideo> get _playlist => widget.videos
      .where((v) => v.youtubeVideoId.isNotEmpty)
      .toList();

  @override
  void initState() {
    super.initState();
    _current = widget.initialVideo;
    _controller = YoutubePlayerController(
      initialVideoId: widget.initialVideo.youtubeVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play(PppVideo video) {
    final id = video.youtubeVideoId;
    if (id.isEmpty || id == _current.youtubeVideoId) return;
    setState(() => _current = video);
    _controller.load(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
        showVideoProgressIndicator: true,
        progressIndicatorColor: colors.goldPrimary,
        progressColors: ProgressBarColors(
          playedColor: colors.goldPrimary,
          handleColor: colors.goldPrimary,
        ),
      ),
      builder: (context, player) {
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
              'Videos',
              style: AppTypography.titleMedium.copyWith(color: colors.ink900),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              player,
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                  itemCount: _playlist.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: colors.lineSoft,
                  ),
                  itemBuilder: (_, i) {
                    final video = _playlist[i];
                    final playing =
                        video.youtubeVideoId == _current.youtubeVideoId;
                    return _PppPlaylistTile(
                      video: video,
                      playing: playing,
                      colors: colors,
                      onTap: () => _play(video),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PppPlaylistTile extends StatelessWidget {
  const _PppPlaylistTile({
    required this.video,
    required this.playing,
    required this.colors,
    required this.onTap,
  });

  final PppVideo video;
  final bool playing;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: playing
          ? colors.goldPrimary.withValues(alpha: 0.14)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 128,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      video.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: video.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  ColoredBox(color: colors.navyDeep),
                            )
                          : ColoredBox(color: colors.navyDeep),
                      if (!playing)
                        Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: colors.navyDeep,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  video.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: playing ? colors.goldPrimary : colors.ink900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
