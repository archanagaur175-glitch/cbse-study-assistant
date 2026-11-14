# Architecture

Static description of the three code bases in this repository. No Python run,
`flutter pub get` or APK build was performed.

**The canonical implementation is unknown.** This document describes all three and
does not rank them.

## Layout

```
main.py                  Kivy app (MDApp, screens, KV block)
recommender.py           scoring and search for the Kivy app
data_loader.py           profile and chapter CSV loading
cbse_chapters.csv        22 chapter rows, 8 columns
buildozer.spec           Python/Android packaging
requirements.txt         unpinned kivy/kivymd

cbse_study_app/          Flutter rewrite
  lib/main.dart          CBSEStudyApp
  lib/app_shell.dart     IndexedStack over Home / Search / Profile
  lib/data/chapters.dart 22 hardcoded chapters
  lib/services/          ai_service, progress_service, recommendation_engine,
                         spaced_repetition
  lib/state/app_state.dart

clarity_crew/            incomplete Flutter copy (7 files, does not compile)

.github/workflows/       build_apk.yml (Kivy), flutter_build.yml (Flutter)
build_apk_colab.ipynb    Colab Buildozer notebook
```

## App 1: Python/Kivy

`main.py` defines `CBSEApp(MDApp)` with `build()`, `on_start()` and a screen
manager. Screens: `OnboardingScreen`, `MainScreen`, `ChapterDetailScreen`, plus an
inline KV layout block.

Flow: onboarding collects goal, daily time, difficulty and note-length preferences
into a profile. `data_loader.py` persists it as `user_profile.json` in the app data
directory and copies `cbse_chapters.csv` from the bundle on first run.

- Search is a substring match over chapter name and subject.
- Recommendations are scored from profile (weak subjects, goal, time budget) and the
  chapter table.
- No HTTP server, public API or CLI flags.
- `buildozer.spec`: package `studyassistant`, domain `com.cbse`, version 1.0.0,
  portrait, fullscreen, no Android permissions.

## App 2: Flutter (`cbse_study_app`)

`lib/main.dart` runs `CBSEStudyApp` in a `MaterialApp`. `app_shell.dart` renders an
`IndexedStack` over three pages (Home, Search, Profile) with a Material 3
`NavigationBar`.

Services:

| Service | Role |
| --- | --- |
| `ai_service.dart` | Local summariser and question generator over chapter text |
| `progress_service.dart` | Chapter progress |
| `recommendation_engine.dart` | Daily recommendations |
| `spaced_repetition.dart` | Review scheduling |

State and persistence live in `app_state.dart` over `shared_preferences`, storing
profile, progress and learner model as JSON. Mastery is tracked per chapter with a
0.8 completion threshold plus an overall average.

The same 22 chapters as the CSV are hardcoded in `lib/data/chapters.dart`.

## App 3: `clarity_crew/` (incomplete)

Seven tracked files. `lib/main.dart` runs `ClarityCrewApp` → `AppStateProvider` →
`MaterialApp` → `AppBootstrap`, and imports `state/app_state.dart`,
`features/onboarding/...` and `features/home_dashboard/...`, none of which exist in
the folder. `pubspec.yaml` declares `assets/images/`, which is also untracked.

This folder is a partial copy of the separate ClarityCrew app. It is not part of
the study assistant and cannot compile as committed.

## Shared content

`cbse_chapters.csv` is the data source for the Kivy app. It has 8 columns and 22
chapter rows:

`chapter`, `subject`, `pages`, `weightage`, `key_formulas`, `detailed_notes`,
`examples`, `practice_problems`.

The Flutter rewrite duplicates the same 22 chapters in Dart. There is no generator
or shared file, so the two can drift.

## Build pipelines

### Kivy APK — `build_apk.yml`

Manual dispatch only. Installs Buildozer and Android build dependencies, removes
`user_profile.json`, runs `buildozer android debug`, and uploads `bin/*.apk` as
`CBSE-Study-Assistant-APK`.

### Flutter APK — `flutter_build.yml`

Runs on push to `master` and on `v*` tags. Java 17, Flutter 3.24.x, runs
`flutter create --platforms=android .` to synthesise platform files, then
`flutter build apk --release`. No signing configuration exists, so the artifact is
debug-signed.

### Colab

`build_apk_colab.ipynb` installs Buildozer, asks for an uploaded `project_3.zip`,
and builds the Kivy APK.

## Configuration

No component reads environment variables. There is no `.env`, no secrets and no
backend configuration. `user_profile.json` and `bin/` are git-ignored.

## Unknowns

- Whether `buildozer android debug` or `flutter build apk` currently succeed.
- Which app is intended to ship.
- Whether `clarity_crew/` was meant to be removed or is a partial migration.
- Whether either workflow ever produced an artifact.
