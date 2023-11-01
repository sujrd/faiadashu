import 'package:faiadashu_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('check every questionnaire type is available', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SDC Demo Scroller'), findsOneWidget);

    final item = find.byKey(const Key('SDC Demo Scroller'));
    await tester.tap(item);
    await tester.pumpAndSettle();

    expect(find.text('SDC Demo Survey'), findsOneWidget);

    final questions = find.byKey(const Key('questionnaire-response-item'));
    expect(questions.evaluate().length, 5); // 28

    final displayFind = find.text('We hope this will only take you a minute!');
    expect(displayFind, findsOneWidget);

    final textFind = find.text('Enter your First Name');
    expect(textFind, findsOneWidget);
    final stringFiller = find.byKey(const Key('string-answer-filler'));
    expect(
      tester.firstWidget(stringFiller).key,
      const Key('string-answer-filler'),
    );
    await tester.enterText(stringFiller.first, 'Test');
    final textFormField =
        stringFiller.first.evaluate().single.widget as TextFormField;
    expect(textFormField.controller!.text, 'Test');
    await tester.pumpAndSettle();
  });
}
