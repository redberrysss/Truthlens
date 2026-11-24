import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/check.dart';
import '../services/services.dart';

class ScanScreen extends StatefulWidget {
  final XFile file;
  final Uint8List bytes;
  final Verdict sample;
  final bool malay;
  const ScanScreen({
    super.key,
    required this.file,
    required this.bytes,
    required this.sample,
    required this.malay,
  });
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool failed = false;
  String tr(String en, String ms) => widget.malay ? ms : en;
  @override
  void initState() {
    super.initState();
    run();
  }

  Future<void> run() async {
    try {
      final verdict = await DemoAnalysisService().analyze(
        widget.file,
        widget.sample,
      );
      if (mounted) Navigator.pop(context, verdict);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('Analyzing Media…', 'Menganalisis Media…'))),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              tr('DEMO • No AI analysis', 'DEMO • Tiada analisis AI'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                widget.bytes,
                height: 260,
                fit: BoxFit.contain,
                semanticLabel: tr(
                  'Selected photo preview',
                  'Pratonton foto dipilih',
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!failed) ...[
              const LinearProgressIndicator(semanticsLabel: 'Demo'),
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: Text(
                  tr(
                    'Photo opened. Preparing your selected demo result… No visual patterns are being analyzed.',
                    'Foto dibuka. Menyediakan keputusan demo pilihan anda… Tiada corak visual dianalisis.',
                  ),
                ),
              ),
            ] else
              Semantics(
                liveRegion: true,
                child: Text(
                  tr(
                    'Could not read your photo. Please select another file.',
                    'Foto tidak dapat dibaca. Sila pilih fail lain.',
                  ),
                ),
              ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                failed ? tr('Go Back', 'Kembali') : tr('Cancel', 'Batal'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
