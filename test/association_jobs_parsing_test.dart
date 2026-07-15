import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/features/associations/data/models/association_content_model.dart';

void main() {
  test('job post parses backend shape', () {
    final j = AssociationJobModel.fromJson({
      '_id': 'j1',
      'associationId': 'a1',
      'memberId': 'm1',
      'jobTitle': 'Tour Manager',
      'companyName': 'Acme Travels',
      'jobDescription': 'Lead group tours',
      'location': 'Mumbai',
      'companyWebsite': 'https://acme.example',
      'createdAt': '2026-07-01T10:00:00.000Z',
    });
    expect(j.id, 'j1');
    expect(j.title, 'Tour Manager');
    expect(j.company, 'Acme Travels');
    expect(j.description, 'Lead group tours');
    expect(j.location, 'Mumbai');
    expect(j.website, 'https://acme.example');
  });

  test('applicant parses backend shape', () {
    final a = AssociationJobApplicantModel.fromJson({
      '_id': 'ap1',
      'JobPostId': 'j1',
      'fullname': 'Priya Sharma',
      'email': 'priya@example.com',
      'mobile': '9876543210',
      'currentCTC': '6 LPA',
      'expectedCTC': '8 LPA',
      'cvFile': ['https://cdn.example/cv.pdf'],
      'createdAt': '2026-07-02T10:00:00.000Z',
    });
    expect(a.fullname, 'Priya Sharma');
    expect(a.currentCtc, '6 LPA');
    expect(a.expectedCtc, '8 LPA');
    expect(a.cvUrls, ['https://cdn.example/cv.pdf']);
  });

  test('applicant handles missing cvFile', () {
    final a = AssociationJobApplicantModel.fromJson({'_id': 'ap2'});
    expect(a.cvUrls, isEmpty);
  });
}
