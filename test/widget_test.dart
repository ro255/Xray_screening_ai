import 'package:diesease_ai_app/app.dart';
import 'package:diesease_ai_app/core/app_language.dart';
import 'package:diesease_ai_app/core/app_providers.dart';
import 'package:diesease_ai_app/core/setting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('English is the default and bottom navigation works', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      withAppProviders(
        settings: Settings(preferences),
        languageController: AppLanguageController(preferences: preferences),
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your health matters.'), findsOneWidget);
    expect(find.text('Screening services'), findsOneWidget);

    await tester.tap(find.text('Screening'));
    await tester.pumpAndSettle();
    expect(find.text('Patient reference number'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Your health matters.'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Server URL'), findsNothing);

    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();
    expect(find.text('Lugha'), findsOneWidget);
  });
}
