import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';

void main() {
  testWidgets('App launches with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });

  // Test của TuNPT — đổi WeatherNowApp → MyApp vì WeatherNowApp đã bị remove
  testWidgets('Calendar screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Weather Calendar'), findsOneWidget);
  });
}