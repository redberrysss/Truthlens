part of 'app.dart';

extension _MediaFlow on _AppState {
  Future<void> choose() async {
    Verdict sample = Verdict.inconclusive;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, update) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tr('Try a photo demo', 'Cuba demo foto'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                paragraph(
                  tr(
                    'No AI analysis takes place. Choose a sample outcome for this demonstration. JPEG, PNG or WebP only, up to 15 MB. Video is not supported.',
                    'Tiada analisis AI dilakukan. Pilih keputusan contoh untuk demonstrasi ini. JPEG, PNG atau WebP sahaja, sehingga 15 MB. Video tidak disokong.',
                  ),
                ),
                ...Verdict.values.map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      selected: sample == v,
                      child: OutlinedButton.icon(
                        onPressed: () => update(() => sample = v),
                        icon: Icon(
                          sample == v
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                        ),
                        label: Text(status(v)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(c, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(tr('Select Photo', 'Pilih Foto')),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(c, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(tr('Take Photo', 'Ambil Foto')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text(tr('Cancel', 'Batal')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (file == null || !mounted) return;
      if (await file.length() > 15 * 1024 * 1024) throw Exception('size');
      final bytes = await file.readAsBytes();
      // Decode before navigation to reject unreadable or unsupported image data.
      final png =
          bytes.length > 8 &&
          bytes[0] == 137 &&
          bytes[1] == 80 &&
          bytes[2] == 78 &&
          bytes[3] == 71;
      final jpg =
          bytes.length > 3 &&
          bytes[0] == 255 &&
          bytes[1] == 216 &&
          bytes[2] == 255;
      final webp =
          bytes.length > 12 &&
          String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
          String.fromCharCodes(bytes.skip(8).take(4)) == 'WEBP';
      if (!png && !jpg && !webp) throw Exception('format');
      final decoded = await decodeImageFromList(bytes);
      decoded.dispose();
      if (!mounted) return;
      final verdict = await Navigator.of(context).push<Verdict>(
        MaterialPageRoute(
          builder: (_) => ScanScreen(
            file: file,
            bytes: bytes,
            sample: sample,
            malay: malay,
          ),
        ),
      );
      if (verdict == null || !mounted) return;
      await add(
        Check(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          date: DateTime.now(),
          verdict: verdict,
        ),
      );
      if (mounted) result(verdict);
    } catch (_) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(
              tr('Photo could not be opened', 'Foto tidak dapat dibuka'),
            ),
            content: Text(
              tr(
                'Choose a readable JPEG, PNG or WebP under 15 MB. Camera access may require permission or may not be available on this device.',
                'Pilih JPEG, PNG atau WebP yang boleh dibaca di bawah 15 MB. Kamera mungkin memerlukan kebenaran atau tidak tersedia pada peranti ini.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(tr('Close', 'Tutup')),
              ),
            ],
          ),
        );
      }
    }
  }

  void result(Verdict verdict) {
    final color = switch (verdict) {
      Verdict.likely => const Color(0xFFFFE8D0),
      Verdict.none => const Color(0xFFDCEDE7),
      Verdict.inconclusive => const Color(0xFFE4E7F0),
    };
    open(
      page(tr('Your Result', 'Keputusan Anda'), [
        badge(
          tr(
            'Demo result — not a real verification',
            'Keputusan demo — bukan pengesahan sebenar',
          ),
          icon: Icons.science_outlined,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                verdict == Verdict.likely
                    ? Icons.report_outlined
                    : verdict == Verdict.none
                    ? Icons.search
                    : Icons.help_outline,
                size: 40,
              ),
              heading(status(verdict)),
            ],
          ),
        ),
        heading(tr('What was checked?', 'Apa yang disemak?')),
        paragraph(
          tr(
            'The app opened your photo for preview and displayed the sample outcome you selected. No AI detector, metadata review or forensic analysis was performed. This result says nothing about your photo’s authenticity.',
            'Aplikasi membuka foto untuk pratonton dan memaparkan keputusan contoh pilihan anda. Tiada pengesan AI, semakan metadata atau analisis forensik dilakukan. Keputusan ini tidak menentukan kesahihan foto anda.',
          ),
        ),
        paragraph(
          tr(
            'A real detector’s result would also be an estimate, not proof. It can miss manipulated media.',
            'Keputusan pengesan sebenar juga merupakan anggaran, bukan bukti. Media yang diubah suai mungkin tidak dikesan.',
          ),
        ),
        heading(tr('What should I do?', 'Apa yang patut saya lakukan?')),
        paragraph(
          tr(
            'Pause before sharing. Check the original source or ask the sender where it came from. Never send money or personal details based on a photo alone.',
            'Berhenti sebelum berkongsi. Semak sumber asal atau tanya pengirim dari mana ia diperoleh. Jangan hantar wang atau maklumat peribadi berdasarkan foto sahaja.',
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            choose();
          },
          child: Text(tr('Check Another', 'Semak Lagi')),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (shareContext) => OutlinedButton.icon(
            onPressed: () async {
              final box = shareContext.findRenderObject() as RenderBox?;
              try {
                await SharePlus.instance.share(
                  ShareParams(
                    text: tr(
                      'I tried TruthLens in demo mode. This is not a real verification of this photo. Please verify the original source before sharing.',
                      'Saya mencuba TruthLens dalam mod demo. Ini bukan pengesahan sebenar foto ini. Sila semak sumber asal sebelum berkongsi.',
                    ),
                    sharePositionOrigin: box == null
                        ? null
                        : box.localToGlobal(Offset.zero) & box.size,
                  ),
                );
              } catch (_) {
                if (mounted) {
                  notice(
                    tr(
                      'Sharing is unavailable on this device.',
                      'Perkongsian tidak tersedia pada peranti ini.',
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.ios_share),
            label: Text(tr('Share Warning', 'Kongsi Peringatan')),
          ),
        ),
      ]),
    );
  }
}
