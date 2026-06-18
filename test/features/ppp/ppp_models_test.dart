import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/features/ppp/data/models/ppp_model.dart';

void main() {
  group('PppPolicyFull.fromJson', () {
    test('parses all fields', () {
      final json = {'_id': 'p1', 'policyName': 'Eco Policy', 'policyDetails': '<p>Details</p>'};
      final p = PppPolicyFull.fromJson(json);
      expect(p.id, 'p1');
      expect(p.policyName, 'Eco Policy');
      expect(p.policyDetails, '<p>Details</p>');
    });
  });

  group('PppInvestFull.fromJson', () {
    test('parses all fields', () {
      final json = {'_id': 'i1', 'opportunityName': 'Hotel Inv', 'opportunityDetails': '<p>Invest</p>'};
      final i = PppInvestFull.fromJson(json);
      expect(i.id, 'i1');
      expect(i.opportunityName, 'Hotel Inv');
      expect(i.opportunityDetails, '<p>Invest</p>');
    });
  });

  group('PppVideo.fromJson', () {
    test('parses video url and title', () {
      final json = {'_id': 'v1', 'video': 'https://youtu.be/abc', 'title': 'Intro'};
      final v = PppVideo.fromJson(json);
      expect(v.id, 'v1');
      expect(v.videoUrl, 'https://youtu.be/abc');
      expect(v.title, 'Intro');
    });
  });

  group('PppImage.fromJson', () {
    test('parses image list', () {
      final json = {'_id': 'img1', 'image': ['https://a.com/1.jpg', 'https://a.com/2.jpg']};
      final img = PppImage.fromJson(json);
      expect(img.id, 'img1');
      expect(img.imageUrls.length, 2);
    });
  });

  group('PppPdf.fromJson', () {
    test('parses pdf fields', () {
      final json = {
        '_id': 'pdf1',
        'pdf': ['https://a.com/file.pdf'],
        'thumbnail': 'https://a.com/thumb.jpg',
        'name': 'Brochure',
        'description': 'Our annual brochure',
      };
      final pdf = PppPdf.fromJson(json);
      expect(pdf.id, 'pdf1');
      expect(pdf.pdfUrls.first, 'https://a.com/file.pdf');
      expect(pdf.name, 'Brochure');
    });
  });
}
