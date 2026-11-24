part of 'app.dart';

extension _GuideFlow on _AppState {
  void guide() => open(
    page(tr('How to Use', 'Cara Penggunaan'), [
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          tooltip: tr('Close guide', 'Tutup panduan'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      for (final s in [
        (
          Icons.screenshot,
          tr(
            '1. Save or screenshot a suspicious photo from WhatsApp.',
            '1. Simpan atau tangkap layar foto mencurigakan daripada WhatsApp.',
          ),
        ),
        (
          Icons.add_photo_alternate,
          tr(
            '2. Open TruthLens and tap the large check button.',
            '2. Buka TruthLens dan ketik butang semak yang besar.',
          ),
        ),
        (
          Icons.fact_check_outlined,
          tr(
            '3. Read the result and its explanation before sharing.',
            '3. Baca keputusan dan penjelasannya sebelum berkongsi.',
          ),
        ),
        (
          Icons.people_outline,
          tr(
            '4. If inconclusive, check the original source or ask someone you trust.',
            '4. Jika tidak pasti, semak sumber asal atau tanya orang yang dipercayai.',
          ),
        ),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: badge(s.$2, icon: s.$1),
        ),
    ]),
  );
}
