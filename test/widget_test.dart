import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/main.dart';
import 'package:truthlens/services/services.dart';

void main() {
  testWidgets('guest can navigate and change essential UI to Malay', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      TruthLens(store: LocalStore(await SharedPreferences.getInstance())),
    );
    await tester.ensureVisible(find.text('Skip / Try as Guest'));
    await tester.tap(find.text('Skip / Try as Guest'));
    await tester.pumpAndSettle();
    expect(find.text('Upload or Select Photo'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<bool>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bahasa Melayu').last);
    await tester.pumpAndSettle();
    expect(find.text('Tetapan'), findsWidgets);
    await tester.tap(find.text('Utama'));
    await tester.pumpAndSettle();
    expect(find.text('Muat Naik atau Pilih Foto'), findsOneWidget);
  });
}
