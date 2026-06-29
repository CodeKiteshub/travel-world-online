import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../../home/data/models/article_model.dart';

final _newsDatasourceProvider = Provider<NewsRemoteDatasource>(
  (ref) => NewsRemoteDatasource(ref.watch(dioProvider)),
);

class NewsFeedState {
  const NewsFeedState({
    required this.articles,
    required this.currentPage,
    required this.isLoading,
    required this.hasMore,
    required this.selectedCategory, // null = All
    this.error,
  });

  final List<Article> articles;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? selectedCategory;
  final String? error;

  NewsFeedState copyWith({
    List<Article>? articles,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? selectedCategory,
    String? error,
    bool clearError = false,
  }) =>
      NewsFeedState(
        articles: articles ?? this.articles,
        currentPage: currentPage ?? this.currentPage,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        error: clearError ? null : (error ?? this.error),
      );
}

class NewsFeedNotifier extends StateNotifier<NewsFeedState> {
  NewsFeedNotifier(this._datasource)
      : super(const NewsFeedState(
          articles: [],
          currentPage: 0,
          isLoading: false,
          hasMore: true,
          selectedCategory: null,
        )) {
    loadMore();
  }

  final NewsRemoteDatasource _datasource;

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final isFreshLoad = state.currentPage == 0;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final nextPage = state.currentPage + 1;
      final List<Article> fetched;

      if (state.selectedCategory == null) {
        fetched = await _datasource.fetchNews(page: nextPage);
      } else {
        fetched = await _datasource.fetchNewsByCategory(
          state.selectedCategory!,
          page: nextPage,
        );
      }

      state = state.copyWith(
        articles: isFreshLoad ? fetched : [...state.articles, ...fetched],
        currentPage: nextPage,
        isLoading: false,
        hasMore: fetched.length >= NewsRemoteDatasource.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String? categoryId) {
    if (categoryId == state.selectedCategory) return;
    // Keep stale articles visible so the screen doesn't go blank during load
    state = NewsFeedState(
      articles: state.articles,
      currentPage: 0,
      isLoading: false,
      hasMore: true,
      selectedCategory: categoryId,
    );
    loadMore();
  }
}

final newsFeedProvider =
    StateNotifierProvider<NewsFeedNotifier, NewsFeedState>(
  (ref) => NewsFeedNotifier(ref.watch(_newsDatasourceProvider)),
);
