# CBSE Study Assistant

A CBSE exam study assistant that ships as an Android app. The repository contains
two implementations of the same assistant and two APK pipelines.

| Path | Language / stack | Notes |
| --- | --- | --- |
| `main.py`, `recommender.py`, `data_loader.py`, `buildozer.spec` | Python 3 + Kivy ≥2.1 + KivyMD, packaged with Buildozer | Root implementation |
| `cbse_study_app/` | Flutter (Dart SDK ≥3.0), `provider`, `shared_preferences` | Flutter rewrite with Home/Search/Profile tabs |

Both implement the same feature set and content model described below.

## Features

- **Onboarding profile** — goal, daily study time, difficulty and note-length
  preferences.
- **Chapter reader** — notes, formulas, examples and practice problems for 22 CBSE
  chapters.
- **Search** — substring match over chapter name and subject.
- **Spaced repetition** — review scheduling per chapter.
- **Mastery tracking** — per-chapter completion with a 0.8 threshold and an overall
  mastery average.
- **Daily recommendations** — scored from the profile (weak subjects, goal, time
  budget) and the chapter table.
- **Local AI helper** (Flutter) — `AIService` summarises and generates questions
  from chapter text locally; it is not a remote model.

## Content model

`cbse_chapters.csv` has 8 columns and 22 chapter rows:

`chapter`, `subject`, `pages`, `weightage`, `key_formulas`, `detailed_notes`,
`examples`, `practice_problems`.

The Kivy app reads the CSV at runtime, copying it into the user data directory on
first run. The Flutter app hardcodes the same 22 chapters in
`cbse_study_app/lib/data/chapters.dart`. The two copies can drift independently.

The Kivy profile is stored as `user_profile.json` in the app data directory
(git-ignored). Flutter persistence uses `shared_preferences` through `AppState`,
storing profile, progress and learner model as JSON. There is no SQL database,
schema file or migration.

## Build: Kivy app

Requirements: Python 3, `kivy` and `kivymd` (see `requirements.txt`), and
Buildozer with the Android SDK/NDK for an APK.

```bash
pip install -r requirements.txt
python main.py          # desktop run
buildozer android debug # APK
```

`buildozer.spec` sets `package.name=studyassistant`, `package.domain=com.cbse`,
version 1.0.0, portrait, fullscreen, and no Android permissions. It pins python3,
kivy 2.3.1, kivymd 1.2.0, pillow and pygments.

`build_apk.yml` (manual dispatch only) installs Buildozer and Android build
dependencies, removes `user_profile.json`, runs `buildozer android debug`, and
uploads `bin/*.apk` as `CBSE-Study-Assistant-APK`.

## Build: Flutter app

```bash
cd cbse_study_app
flutter pub get
flutter build apk --release
```

The repo commits no Android project for the Flutter app. `flutter_build.yml` runs
on push to `master` and on `v*` tags, and first synthesises the platform files with
`flutter create --platforms=android .` before building. No signing configuration is
present, so the release APK is debug-signed by default.

`build_apk_colab.ipynb` is a 10-cell Colab notebook that installs Buildozer, asks
for an uploaded `project_3.zip`, and builds the Kivy APK.

## Tests

There are **no tests**: no `test/` directory in the Flutter app and no Python
tests. `flutter_test` is declared in the pubspec but unused. There is no Python
lockfile (`requirements.txt` has unpinned lower bounds) and no Flutter lockfile.

No build or test was executed for this documentation.

## Configuration

No component reads environment variables. There is no `.env` file, no secrets, no
Firebase or other backend configuration. `user_profile.json` and `bin/` are
git-ignored.

## Known limitations

- Chapter content is duplicated between CSV and Dart.
- The Flutter CI generates Android configuration at build time, so the committed
  repo has no Android project to review.
- APKs are debug-signed.
- No tests and no lockfiles.
- Which implementation is the intended release target is not stated in the
  repository.

## License

MIT. See [`LICENSE`](LICENSE).
