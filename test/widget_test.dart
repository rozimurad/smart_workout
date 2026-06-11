import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_antreman/main.dart';

void main() {
  testWidgets('Onboarding flow smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AkilliAntrenmanApp());

    // Verify that onboarding starts with the first step "Sana nasıl hitap edelim?".
    expect(find.text('Sana nasıl hitap edelim?'), findsOneWidget);
    expect(find.text('Devam Et'), findsOneWidget);
  });
}
