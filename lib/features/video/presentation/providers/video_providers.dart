import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/video_remote_datasource.dart';
import '../../data/models/video_models.dart';

final _videoDatasourceProvider = Provider<VideoRemoteDatasource>(
  (ref) => VideoRemoteDatasource(ref.watch(dioProvider)),
);

class VideoFeedState {
  const VideoFeedState({
    required this.items,
    required this.currentPage,
    required this.isLoading,
    required this.hasMore,
    required this.selectedCategory,
    this.error,
  });

  final List<VideoItem> items;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String selectedCategory; // 'news' | 'interviews' | 'destinations'
  final String? error;

  VideoFeedState copyWith({
    List<VideoItem>? items,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? selectedCategory,
    String? error,
    bool clearError = false,
  }) =>
      VideoFeedState(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        error: clearError ? null : (error ?? this.error),
      );
}

class VideoFeedNotifier extends StateNotifier<VideoFeedState> {
  VideoFeedNotifier(this._datasource)
      : super(const VideoFeedState(
          items: [],
          currentPage: 0,
          isLoading: false,
          hasMore: true,
          selectedCategory: 'news',
        )) {
    loadMore();
  }

  final VideoRemoteDatasource _datasource;

  void setCategory(String category) {
    if (category == state.selectedCategory) return;
    state = VideoFeedState(
      items: state.items,
      currentPage: 0,
      isLoading: false,
      hasMore: true,
      selectedCategory: category,
    );
    loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final isFreshLoad = state.currentPage == 0;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final nextPage = state.currentPage + 1;
      final fetched = await _datasource.fetchVideos(
        category: state.selectedCategory,
        page: nextPage,
      );
      state = state.copyWith(
        items: isFreshLoad ? fetched : [...state.items, ...fetched],
        currentPage: nextPage,
        isLoading: false,
        hasMore: fetched.length >= VideoRemoteDatasource.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final videoFeedProvider =
    StateNotifierProvider<VideoFeedNotifier, VideoFeedState>(
  (ref) => VideoFeedNotifier(ref.watch(_videoDatasourceProvider)),
);
