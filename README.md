# TruthLens

Accessible Flutter prototype in English and Bahasa Melayu.

## Run

With Flutter 3.35 or newer installed:

```sh
flutter pub get
flutter run -d chrome
# or flutter run on an Android / iOS device
flutter analyze
flutter test
flutter build web
```

## Analysis and privacy

* Photo analysis is **demo only**. Before selecting a photo, choose one of three sample outcomes. The photo is decoded for preview; a replaceable `MediaAnalysisService` returns the chosen sample. No detector, confidence scores, heatmaps, metadata checks or authenticity claims are provided.
* Message checking uses real local, explainable keyword/link rules in English and Malay. It does not use AI, open links, check domain reputation or fact-check news. Rules may miss scams and flag ordinary messages.
* No media or messages are uploaded. Local preferences store only timestamp, item type, verdict and demo/rule label, plus language preference. No filenames or message content are retained. Clear and individual delete controls are available. Browser history persists per origin; native history persists per installation.
* Photos: JPEG, PNG and WebP, maximum 15 MB. Video/audio analysis and receiving OS share intents are not implemented. Use the normal photo picker instead. Canceling a scan discards its result.
* Google/phone authentication is intentionally unconfigured; guest access works. No credentials are needed for the demo. A production detector would require an implementation of `MediaAnalysisService`, documented model limitations, and explicit upload disclosure before any remote processing.

## Platform setup

iOS camera and photo permission descriptions are included in `ios/Runner/Info.plist`; iOS builds require Xcode signing. Android uses the system image picker and the external camera intent. On web, camera capture availability depends on browser/device; the gallery picker remains available. System sharing depends on platform support; errors are shown honestly.

## Presentation

Start as Guest, select a sample outcome, choose a photo, and read the clearly marked demo result. Try each outcome. Check a message such as “Urgent! Transfer money now at https://bit.ly/example and send your OTP” to see local rules. Switch language in Settings and demonstrate history deletion.

## Validation and this machine

Static analysis passed with no issues. Four tests cover bilingual guest navigation, local message rules, minimum-data history storage and deletion, and phone layout at 150% text size. A release web bundle is available in `build/web`.

The installed Flutter SDK had offloaded/unreadable files, and the disk ran out of space during checks. Validation used clean temporary Flutter 3.35.5 / Dart 3.9.2 sources and artifacts; the installed SDK was not replaced. The successful web build disabled optional icon tree shaking and the Wasm dry run. For normal development, restore a healthy local Flutter SDK, keep sufficient free disk space, and run `flutter pub get` again. Temporary SDK paths in generated `.dart_tool` files are not source dependencies.

To present the existing web build without rebuilding:

```sh
python3 -m http.server 8080 --directory build/web
```

Open `http://localhost:8080` in a browser. Use a mobile device for native picker, camera and share-sheet testing. Android/iOS device builds and platform permission prompts have not been tested here. Before distributing native builds, set your app identifiers and release signing configuration.
