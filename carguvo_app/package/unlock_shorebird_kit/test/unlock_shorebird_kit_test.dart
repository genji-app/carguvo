import 'package:flutter_test/flutter_test.dart';
import 'package:unlock_shorebird_kit/unlock_shorebird_kit.dart';

void main() {
  test('UpdateFlowStatus exposes expected terminal states', () {
    const UpdateFlowStatus upToDate = UpdateFlowStatus.upToDate;
    const UpdateFlowStatus restart = UpdateFlowStatus.restartRequired;
    expect(upToDate, isNot(restart));
  });
}
