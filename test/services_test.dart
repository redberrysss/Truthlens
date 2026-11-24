import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/services/services.dart';
import 'package:truthlens/models/check.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'rules find English and Malay scam cues without treating absence as authenticity',
    () {
      expect(
        messageSignals(
          'Urgent! Transfer money at https://bit.ly/test and send OTP',
        ),
        containsAll(['urgency', 'money', 'personal', 'short', 'link']),
      );
      expect(
        messageSignals('Bayar wang segera dan berikan kata laluan'),
        containsAll(['urgency', 'money', 'personal']),
      );
      expect(messageSignals('Hello family'), isEmpty);
    },
  );
  test('history stores minimum fields and can be deleted', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    final item = Check(
      id: 'one',
      date: DateTime(2026),
      verdict: Verdict.inconclusive,
    );
    await store.save([item]);
    expect(store.read().single.verdict, Verdict.inconclusive);
    expect(
      store.read().single.toJson().keys,
      unorderedEquals(['id', 'date', 'verdict', 'demo', 'message']),
    );
    await store.save([]);
    expect(store.read(), isEmpty);
  });
}
