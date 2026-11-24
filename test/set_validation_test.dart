import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_app/models/set_validation.dart';

void main() {
  test('zero load is valid, negative and non finite loads are rejected', () {
    expect(SetValidation.validWeight(0), isTrue);
    expect(SetValidation.validWeight(20.5), isTrue);
    expect(SetValidation.validWeight(-1), isFalse);
    expect(SetValidation.validWeight(double.nan), isFalse);
  });

  test('performed repetitions must be positive integers', () {
    expect(SetValidation.validRepetitions(10), isTrue);
    expect(SetValidation.validRepetitions(0), isFalse);
    expect(SetValidation.validRepetitions(-1), isFalse);
    expect(int.tryParse('1.5'), isNull);
    expect(int.tryParse(''), isNull);
  });
}
