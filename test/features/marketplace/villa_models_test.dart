import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'package:new_travel/features/marketplace/data/models/villa_rate_model.dart';
import 'package:new_travel/features/marketplace/data/models/villa_rate_plan_model.dart';

void main() {
  // Field shapes below mirror the live /api/elivaas/rates responses.
  test('VillaRateModel uses priceAmount when quotes is null (suggestion mode)',
      () {
    final model = VillaRateModel.fromJson({
      'id': 'prop_cZ4qruFe1bRy82',
      'name': 'Aanandam Villas',
      'city': 'Delhi NCR',
      'quotes': null,
      'priceAmount': 10002,
    });
    expect(model.amount, 10002);
  });

  test('VillaRateModel parses string amounts', () {
    final model = VillaRateModel.fromJson({
      'id': 'p1',
      'name': 'Villa',
      'quotes': null,
      'priceAmount': '10002',
    });
    expect(model.amount, 10002);
  });

  test('VillaRateModel prefers per-night quote amount when quotes exist', () {
    final model = VillaRateModel.fromJson({
      'id': 'p1',
      'name': 'Villa',
      'priceAmount': 10002,
      'quotes': [
        {'quoteId': 'q1', 'netPerNightAmountAfterTax': 4544},
      ],
    });
    expect(model.amount, 4544);
  });

  test('VillaRateModel parses location, soldOut, and topAmenities', () {
    final model = VillaRateModel.fromJson({
      'id': 'p1',
      'name': 'Villa',
      'city': 'Delhi NCR',
      'location': 'Sonipat',
      'state': 'Delhi',
      'streetLine': 'Khewat No. 134, Sonipat',
      'soldOut': true,
      'topAmenities': [
        {'name': 'Private patio'},
        {'name': 'Wifi'},
        {'name': ''},
      ],
      'quotes': null,
      'priceAmount': 5000,
    });
    expect(model.fullLocation, 'Sonipat, Delhi NCR');
    expect(model.streetLine, 'Khewat No. 134, Sonipat');
    expect(model.soldOut, true);
    expect(model.topAmenities, ['Private patio', 'Wifi']);
  });

  test('buildVillaBookingBody matches old-app shape', () {
    final body = buildVillaBookingBody(
      quoteId: 'quot_1',
      guestName: 'Rakesh Kumar Sharma',
      guestEmail: 'r@x.com',
      guestPhone: '9999999999',
      transactionId: 'pay_abc',
      paidAmountRupees: 9088,
    );
    expect(body['quoteId'], 'quot_1');
    expect(body['bookingStatus'], 'CONFIRMED');
    final guest = body['guest'] as Map<String, dynamic>;
    expect(guest['firstName'], 'Rakesh');
    expect(guest['lastName'], 'Kumar Sharma');
    expect(guest['email'], 'r@x.com');
    final payment = body['payment'] as Map<String, dynamic>;
    expect(payment['provider'], 'Razorpay');
    expect(payment['transactionId'], 'pay_abc');
    expect(payment['amount'], 9088);
  });

  test('buildVillaBookingBody handles single-word names like old app', () {
    final body = buildVillaBookingBody(
      quoteId: 'q',
      guestName: 'Rakesh',
      guestEmail: 'r@x.com',
      guestPhone: '9',
      transactionId: 't',
      paidAmountRupees: 1,
    );
    final guest = body['guest'] as Map<String, dynamic>;
    expect(guest['firstName'], 'Rakesh');
    expect(guest['lastName'], 'Rakesh');
  });

  test('VillaRatePlanModel charges netAfterTax only (deposit excluded)', () {
    final plan = VillaRatePlanModel.fromJson({
      'id': 'q1',
      'ratePlanCode': 'ep',
      'netAmountAfterTax': 9088,
      'securityDeposit': 5000,
    });
    expect(plan.payableInPaise, 908800);
  });

  test('VillaRatePlanModel parses real quote keys', () {
    final plan = VillaRatePlanModel.fromJson({
      'id': 'quot_NJGpxCPG0bYjde',
      'ratePlanCode': 'ep',
      'ratePlanDTO': {'displayName': 'Property only', 'name': 'EP'},
      'netAmountBeforeTax': 8656,
      'gstAmount': 432,
      'netAmountAfterTax': 9088,
      'numberOfNights': 2,
      'numberOfGuests': 2,
    });
    expect(plan.id, 'quot_NJGpxCPG0bYjde');
    expect(plan.displayName, 'Property only');
    expect(plan.netBeforeTax, 8656);
    expect(plan.gstAmount, 432);
    expect(plan.netAfterTax, 9088);
    expect(plan.numberOfNights, 2);
  });
}
