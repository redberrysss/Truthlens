part of 'app.dart';

extension _MessageFlow on _AppState {
  void message() {
    final controller = TextEditingController();
    List<String>? signals;
    String? error;
    open(
      StatefulBuilder(
        builder: (c, update) => page(tr('Check a Message', 'Semak Mesej'), [
          badge(
            tr(
              'Local scam warning-sign check. This does not verify whether a news claim is true or open any links.',
              'Semakan tanda amaran penipuan setempat. Ini tidak mengesahkan kebenaran berita atau membuka pautan.',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            minLines: 6,
            maxLines: 12,
            maxLength: 5000,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              labelText: tr(
                'Paste message or link',
                'Tampal mesej atau pautan',
              ),
              alignLabelWithHint: true,
              errorText: error,
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (c.mounted && data?.text != null) {
                controller.text = data!.text!.substring(
                  0,
                  data.text!.length.clamp(0, 5000).toInt(),
                );
              }
            },
            icon: const Icon(Icons.content_paste),
            label: Text(tr('Paste from clipboard', 'Tampal dari papan klip')),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                update(
                  () => error = tr(
                    'Enter a message or link first.',
                    'Masukkan mesej atau pautan dahulu.',
                  ),
                );
                return;
              }
              if (text.length > 5000) {
                update(
                  () => error = tr(
                    'Use 5,000 characters or fewer.',
                    'Gunakan 5,000 aksara atau kurang.',
                  ),
                );
                return;
              }
              final urls = RegExp(
                r'https?://\S*',
                caseSensitive: false,
              ).allMatches(text);
              if (urls.any((m) {
                final uri = Uri.tryParse(m[0]!);
                return uri == null ||
                    uri.host.isEmpty ||
                    !uri.host.contains('.') ||
                    uri.host.endsWith('.');
              })) {
                update(
                  () => error = tr(
                    'This link looks incomplete. Check its address.',
                    'Pautan ini kelihatan tidak lengkap. Semak alamatnya.',
                  ),
                );
                return;
              }
              final found = messageSignals(text);
              update(() {
                error = null;
                signals = found;
              });
              await add(
                Check(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  date: DateTime.now(),
                  verdict: found.isEmpty
                      ? Verdict.inconclusive
                      : Verdict.likely,
                  demo: false,
                  message: true,
                ),
              );
            },
            child: Text(tr('Check Message', 'Semak Mesej')),
          ),
          if (signals != null) ...[
            heading(
              signals!.isEmpty
                  ? tr(
                      'No listed warning signs found',
                      'Tiada tanda amaran tersenarai ditemui',
                    )
                  : tr('Possible warning signs', 'Kemungkinan tanda amaran'),
            ),
            badge(
              tr(
                'Rule-based check • Not AI or a fact-check',
                'Semakan berasaskan peraturan • Bukan AI atau semakan fakta',
              ),
            ),
            for (final s in signals!)
              paragraph(switch (s) {
                'urgency' => tr(
                  '• Urgent wording can pressure you to act without thinking.',
                  '• Bahasa mendesak boleh menekan anda untuk bertindak tanpa berfikir.',
                ),
                'money' => tr(
                  '• Money or prize wording deserves extra care.',
                  '• Sebutan wang atau hadiah memerlukan perhatian tambahan.',
                ),
                'personal' => tr(
                  '• Requests for personal details, passwords or OTPs can be risky.',
                  '• Permintaan maklumat peribadi, kata laluan atau OTP boleh berisiko.',
                ),
                'short' => tr(
                  '• A shortened link hides its destination.',
                  '• Pautan pendek menyembunyikan destinasinya.',
                ),
                _ => tr(
                  '• A link is present. Its destination and reputation were not checked.',
                  '• Pautan ditemui. Destinasi dan reputasinya tidak disemak.',
                ),
              }),
            paragraph(
              tr(
                'These simple rules can miss scams and flag ordinary messages. No warning signs does not mean a message is trustworthy. Language variations may be missed.',
                'Peraturan mudah ini boleh terlepas penipuan dan menandakan mesej biasa. Ketiadaan tanda amaran tidak bermakna mesej boleh dipercayai. Variasi bahasa mungkin terlepas.',
              ),
            ),
            heading(tr('Your next step', 'Langkah seterusnya')),
            paragraph(
              tr(
                'Contact the person or organisation through a number you already trust. Do not use a number or link supplied by the suspicious message. Verify the source before forwarding.',
                'Hubungi individu atau organisasi melalui nombor yang anda percayai. Jangan guna nombor atau pautan dalam mesej mencurigakan. Semak sumber sebelum menghantar semula.',
              ),
            ),
          ],
        ]),
      ),
    ).then((_) => controller.dispose());
  }
}
