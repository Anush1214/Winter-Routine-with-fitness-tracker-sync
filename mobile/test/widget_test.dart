import 'package:flutter_test/flutter_test.dart';
import 'package:winter_arc_mobile/main.dart';

void main() {
  testWidgets('Winter Arc Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const WinterArcMobileApp());
    expect(find.text('WINTER ARC PROTOCOL'), findsWidgets);
  });
}
