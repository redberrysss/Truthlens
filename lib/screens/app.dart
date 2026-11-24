import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/check.dart';
import '../services/services.dart';
import 'scan.dart';

part 'guide.dart';
part 'media.dart';
part 'message.dart';

class App extends StatefulWidget {
  final LocalStore store;
  const App({super.key, required this.store});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool guest = false;
  late bool malay = widget.store.prefs.getBool('malay') ?? false;
  late List<Check> history = widget.store.read();
  int tab = 0;
  String tr(String en, String ms) => malay ? ms : en;
  String status(Verdict v) => switch (v) {
    Verdict.likely => tr(
      'Likely AI-generated or manipulated',
      'Berkemungkinan dijana AI atau diubah suai',
    ),
    Verdict.none => tr(
      'No strong signs of AI generation detected',
      'Tiada tanda kuat penjanaan AI dikesan',
    ),
    Verdict.inconclusive => tr(
      'Inconclusive — more checks needed',
      'Tidak dapat dipastikan — semakan lanjut diperlukan',
    ),
  };
  Future<void> persist() async {
    try {
      await widget.store.save(history);
    } catch (_) {
      if (mounted) {
        notice(
          tr(
            'Could not save history on this device.',
            'Sejarah tidak dapat disimpan pada peranti ini.',
          ),
        );
      }
    }
  }

  void notice(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> add(Check c) async {
    setState(() => history.insert(0, c));
    await persist();
  }

  Widget paragraph(String s) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s));
  Widget heading(String s) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(s, style: Theme.of(context).textTheme.titleLarge),
  );
  Widget badge(String s, {IconData icon = Icons.info_outline}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE0EBF2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(child: Text(s)),
      ],
    ),
  );
  Widget action(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback tap, {
    bool primary = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      color: primary ? const Color(0xFF0B2545) : Colors.white,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: tap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(
                icon,
                size: 34,
                color: primary ? Colors.white : const Color(0xFF0B2545),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: primary ? Colors.white : const Color(0xFF0B2545),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: primary ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: primary ? Colors.white : Colors.black87,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget page(String title, List<Widget> children) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(padding: const EdgeInsets.all(24), children: children),
      ),
    ),
  );
  Future<void> open(Widget child) async =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => child));
  @override
  Widget build(BuildContext context) {
    if (!guest) {
      return page('TruthLens', [
        const SizedBox(height: 24),
        const Icon(Icons.shield_outlined, size: 86, color: Color(0xFF0B2545)),
        Center(
          child: heading(tr('Check if it’s real.', 'Semak kesahihannya.')),
        ),
        paragraph(
          tr(
            'A little pause. A more informed share.',
            'Berhenti seketika. Kongsi dengan lebih bijak.',
          ),
        ),
        const SizedBox(height: 28),
        badge(
          tr(
            'A helping hand for you and your family. Always check the original source.',
            'Membantu anda dan keluarga. Sentiasa semak sumber asal.',
          ),
          icon: Icons.family_restroom,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(
                tr(
                  'Sign-in is not configured',
                  'Log masuk belum dikonfigurasi',
                ),
              ),
              content: Text(
                tr(
                  'Google and phone sign-in need provider credentials. You can use every prototype feature as a guest.',
                  'Log masuk Google dan telefon memerlukan kelayakan penyedia. Semua ciri prototaip boleh digunakan sebagai tetamu.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text(tr('Close', 'Tutup')),
                ),
              ],
            ),
          ),
          child: Text(
            tr(
              'Continue with Google / Phone',
              'Teruskan dengan Google / Telefon',
            ),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: () => setState(() => guest = true),
          child: Text(
            tr('Skip / Try as Guest', 'Langkau / Cuba sebagai Tetamu'),
          ),
        ),
        const SizedBox(height: 32),
        paragraph(
          tr(
            'Protecting your family from online scams and fake news.',
            'Melindungi keluarga anda daripada penipuan dalam talian dan berita palsu.',
          ),
        ),
      ]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruthLens'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                tr('Guest', 'Tetamu'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            key: ValueKey(tab),
            padding: const EdgeInsets.all(24),
            children: switch (tab) {
              0 => home(),
              1 => past(),
              _ => settings(),
            },
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: tr('Home', 'Utama'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: tr('Past Checks', 'Sejarah'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: tr('Settings', 'Tetapan'),
          ),
        ],
      ),
    );
  }

  List<Widget> home() => [
    Text(
      tr('PAUSE • CHECK • SHARE', 'BERHENTI • SEMAK • KONGSI'),
      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.3),
    ),
    heading(
      tr(
        'Hello! What would you like to check today?',
        'Helo! Apa yang ingin anda semak hari ini?',
      ),
    ),
    paragraph(
      tr(
        'Take a moment before forwarding.',
        'Luangkan masa sebelum menghantar semula.',
      ),
    ),
    const SizedBox(height: 16),
    action(
      tr('Upload or Select Photo', 'Muat Naik atau Pilih Foto'),
      tr(
        'Photo library or camera • Image demo',
        'Galeri atau kamera • Demo imej',
      ),
      Icons.add_photo_alternate_outlined,
      choose,
      primary: true,
    ),
    action(
      tr('Check WhatsApp Text/Link', 'Semak Teks/Pautan WhatsApp'),
      tr(
        'Look for common scam warning signs',
        'Cari tanda amaran penipuan lazim',
      ),
      Icons.chat_outlined,
      message,
    ),
    action(
      tr('How to Use', 'Cara Penggunaan'),
      tr(
        'Four simple steps to thoughtful sharing',
        'Empat langkah untuk berkongsi dengan bijak',
      ),
      Icons.menu_book_outlined,
      guide,
    ),
    badge(
      tr(
        'Media demo mode. No AI detector is connected. Video and audio checks are not available yet. Your photo stays on your device.',
        'Mod demo media. Tiada pengesan AI disambungkan. Semakan video dan audio belum tersedia. Foto kekal pada peranti anda.',
      ),
    ),
  ];
  List<Widget> past() => [
    heading(tr('Past Checks', 'Sejarah Semakan')),
    paragraph(
      tr(
        'Stored on this device only. No photos, messages, links or filenames are saved.',
        'Disimpan pada peranti ini sahaja. Foto, mesej, pautan dan nama fail tidak disimpan.',
      ),
    ),
    if (history.isEmpty)
      badge(
        tr(
          'No checks yet. Start from Home.',
          'Belum ada semakan. Mulakan dari Utama.',
        ),
      ),
    ...history.map(
      (c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.message
                    ? tr('Message • Local rules', 'Mesej • Peraturan setempat')
                    : tr('Photo • Demo result', 'Foto • Keputusan demo'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                c.message
                    ? (c.verdict == Verdict.likely
                          ? tr('Warning signs found', 'Tanda amaran ditemui')
                          : tr(
                              'No listed warning signs found',
                              'Tiada tanda amaran tersenarai ditemui',
                            ))
                    : status(c.verdict),
              ),
              Text(
                MaterialLocalizations.of(
                  context,
                ).formatMediumDate(c.date.toLocal()),
              ),
              Row(
                children: [
                  Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatTimeOfDay(TimeOfDay.fromDateTime(c.date.toLocal())),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: tr('Delete entry', 'Padam rekod'),
                    onPressed: () {
                      setState(() => history.remove(c));
                      persist();
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    if (history.isNotEmpty)
      OutlinedButton(
        onPressed: clear,
        child: Text(tr('Clear Past Checks', 'Padam Sejarah Semakan')),
      ),
  ];
  Future<void> clear() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('Clear all history?', 'Padam semua sejarah?')),
        content: Text(
          tr(
            'This removes check summaries from this device.',
            'Ini memadam ringkasan semakan daripada peranti ini.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr('Cancel', 'Batal')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr('Clear', 'Padam')),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      setState(() => history.clear());
      await persist();
    }
  }

  List<Widget> settings() => [
    heading(tr('Settings', 'Tetapan')),
    Text(
      tr('Language', 'Bahasa'),
      style: Theme.of(context).textTheme.titleMedium,
    ),
    const SizedBox(height: 10),
    DropdownButtonFormField<bool>(
      initialValue: malay,
      items: const [
        DropdownMenuItem(value: false, child: Text('English')),
        DropdownMenuItem(value: true, child: Text('Bahasa Melayu')),
      ],
      onChanged: (v) {
        setState(() => malay = v!);
        widget.store.prefs.setBool('malay', malay);
      },
    ),
    heading(tr('Your privacy', 'Privasi anda')),
    paragraph(
      tr(
        'Photos and messages are processed on your device and are not uploaded. Selected photos are read temporarily for preview. TruthLens does not save them to history. Your system picker or camera may keep its own copy.',
        'Foto dan mesej diproses pada peranti dan tidak dimuat naik. Foto dibaca sementara untuk pratonton. TruthLens tidak menyimpannya dalam sejarah. Pemilih sistem atau kamera mungkin menyimpan salinan sendiri.',
      ),
    ),
    OutlinedButton(
      onPressed: clear,
      child: Text(tr('Clear Past Checks', 'Padam Sejarah Semakan')),
    ),
    heading(tr('About TruthLens', 'Tentang TruthLens')),
    badge(
      tr(
        'Prototype 1.0 • Media: demo only. Messages: local keyword and link rules, no AI model. No account is required.',
        'Prototaip 1.0 • Media: demo sahaja. Mesej: peraturan kata kunci dan pautan setempat, tanpa model AI. Akaun tidak diperlukan.',
      ),
    ),
    paragraph(
      tr(
        'This tool supports careful sharing. It does not replace official fraud reporting, journalism or professional forensic analysis.',
        'Alat ini membantu perkongsian berhemah. Ia tidak menggantikan laporan penipuan rasmi, kewartawanan atau analisis forensik profesional.',
      ),
    ),
  ];
}
