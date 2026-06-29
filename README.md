# 6MONTH

A pure black and white Flutter mobile app for a 180-day personal transformation.

## Stack

- Flutter
- Riverpod for state management
- Hive for local storage
- Anthropic Claude API for goal rewriting, daily tasks, and monthly summaries
- `in_app_purchase` for the one-time unlock
- `image_picker` for before and after photos

## Run

```sh
flutter pub get
flutter run --dart-define=ANTHROPIC_API_KEY=your_key_here
```

Without `ANTHROPIC_API_KEY`, the app still works with local fallback text.

To show the development unlock button while testing the paywall:

```sh
flutter run --dart-define=SHOW_DEV_UNLOCK=true
```

## Claude

The app calls Anthropic Messages API with:

```txt
claude-sonnet-4-6
```

The API key is read from:

```txt
ANTHROPIC_API_KEY
```

Pass it with `--dart-define` for mobile builds.

## Purchases

The one-time unlock product id is:

```txt
sixmonth_lifetime_unlock
```

Create the same non-consumable product in App Store Connect and Google Play Console before release.

## Release Notes

Before publishing:

- Replace the placeholder Android `applicationId` with your real package id.
- Configure Android release signing.
- Enable In-App Purchase capability in Xcode.
- Create matching store products for `sixmonth_lifetime_unlock`.
- Keep `SHOW_DEV_UNLOCK` disabled for production builds.
