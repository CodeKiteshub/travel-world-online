import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_item.freezed.dart';
part 'news_item.g.dart';

@freezed
class NewsItem with _$NewsItem {
  const factory NewsItem({
    required String image,
    required String category,
    required String title,
    required String src,
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json) => _$NewsItemFromJson(json);
}
