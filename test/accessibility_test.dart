import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/main.dart';
import 'package:truthlens/services/services.dart';

void main() {
  testWidgets(
    'phone layout supports enlarged text and the guide returns home',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        TruthLens(store: LocalStore(await SharedPreferences.getInstance())),
      );
      await tester.scrollUntilVisible(find.text('Skip / Try as Guest'), 150);
      await tester.tap(find.text('Skip / Try as Guest'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('How to Use'), 150);
      await tester.tap(find.text('How to Use'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Close guide'));
      await tester.pumpAndSettle();
      expect(find.text('TruthLens'), findsOneWidget);
      expect(find.byTooltip('Close guide'), findsNothing);
    },
  );
}
