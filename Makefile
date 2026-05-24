DEFINES = --dart-define-from-file=dart_defines.local.json

.PHONY: run run-release build-ios build-android gen analyze test

## ── Dev ────────────────────────────────────────────────────────────
run:
	flutter run $(DEFINES)

run-release:
	flutter run --release $(DEFINES)

## ── Code gen ───────────────────────────────────────────────────────
gen:
	flutter pub run build_runner build --delete-conflicting-outputs
	flutter gen-l10n

## ── Quality ────────────────────────────────────────────────────────
analyze:
	flutter analyze

test:
	flutter test

## ── Build ──────────────────────────────────────────────────────────
build-ios:
	flutter build ios $(DEFINES)

build-android:
	flutter build apk $(DEFINES)
