DEFINES = --dart-define-from-file=dart_defines.local.json
export LANG    = en_US.UTF-8
export LC_ALL  = en_US.UTF-8

.PHONY: setup run run-release build-ios build-android gen analyze test pods

## ── First-time setup ───────────────────────────────────────────────
setup:
	flutter pub get
	cd ios && pod install

pods:
	cd ios && pod install

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
