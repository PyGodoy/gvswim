import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/pages/HomePage.dart';

void main() {
  testWidgets('Teste inicial do contador', (WidgetTester tester) async {
    // Construa o app e acione um frame.
    await tester.pumpWidget(const HomePageWidget());

    // Verifique se o contador começa em 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Toque no ícone '+' e acione um frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifique se o contador incrementou.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
