import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/features/campus/data/models/campus_models.dart';

void main() {
  group('DestSubCategory.fromJson', () {
    test('parses tblvideocats fields', () {
      final json = {'id': '10', 'videosubcat': 'Buddhist Circuit', 'image': 'https://a.com/img.jpg'};
      final d = DestSubCategory.fromJson(json);
      expect(d.id, '10');
      expect(d.label, 'Buddhist Circuit');
      expect(d.imageUrl, 'https://a.com/img.jpg');
    });
  });

  group('DestVideo.fromJson', () {
    test('parses all fields', () {
      final json = {
        'id': '5',
        'heading': 'Bodh Gaya Tour',
        'image': 'https://a.com/thumb.jpg',
        'video': 'https://youtu.be/xyz',
        'detail': 'Visit the Mahabodhi Temple',
        'place': 'Bihar',
      };
      final v = DestVideo.fromJson(json);
      expect(v.id, '5');
      expect(v.heading, 'Bodh Gaya Tour');
      expect(v.videoUrl, 'https://youtu.be/xyz');
      expect(v.place, 'Bihar');
    });
  });

  group('CampusCourseItem.fromJson', () {
    test('parses name and link', () {
      final json = {'id': '3', 'name': 'GST for Tour Ops', 'link': 'https://primegrowth.io/gst'};
      final c = CampusCourseItem.fromJson(json);
      expect(c.id, '3');
      expect(c.label, 'GST for Tour Ops');
      expect(c.link, 'https://primegrowth.io/gst');
    });
  });
}
