import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'package:new_travel/features/marketplace/data/models/tailor_made_request_model.dart';

void main() {
  test('parseMyPackages unwraps the [{"Packages": [...]}] backend shape', () {
    final deals = parseMyPackages([
      {
        'Packages': [
          {'_id': 'p1', 'dealName': 'Goa Escape', 'duration': '4D/3N'},
          {'_id': 'p2', 'dealName': 'Kerala Trip'},
        ]
      }
    ]);
    expect(deals.length, 2);
    expect(deals.first.dealName, 'Goa Escape');
  });

  test('parseMyPackages still handles flat and lowercase-wrapped lists', () {
    expect(
      parseMyPackages([
        {'_id': 'p1', 'dealName': 'Flat'}
      ]).single.dealName,
      'Flat',
    );
    expect(
      parseMyPackages({
        'data': [
          {'_id': 'p1', 'dealName': 'Wrapped'}
        ]
      }).single.dealName,
      'Wrapped',
    );
    expect(parseMyPackages(null), isEmpty);
  });

  test('TailorMadeRequest parses the backend response fields', () {
    final req = TailorMadeRequest.fromJson({
      '_id': 't1',
      'destination': 'KERALA',
      'travelDate': '2026-08-01',
      'adult': 2,
      'child': 1,
      'budget': 50000,
      'status': 'pending',
      'memberId': 'm1',
    });
    expect(req.id, 't1');
    expect(req.destination, 'KERALA');
    expect(req.adult, '2');
    expect(req.budget, '50000');
    expect(req.status, 'pending');
  });
}
