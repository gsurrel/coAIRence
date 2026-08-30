# coAIRence

coAIRence is an app for Heart Rate Variability Biofeedback (HRVB), also known as cardiac coherence or slow-paced breathing. This evidence-based practice helps reduce stress, improve emotional balance, and boost overall well-being by leveraging respiratory sinus arrhythmia (RSA).

Features:
- Visual Breathing Guides: Follow smooth, calming animations designed to help you pace your breath effortlessly.
- Customizable Patterns: Adjust pattern duration and repetitions to suit your needs or explore the built-in library of exercises.
- Progress Tracking: Monitor your practice with detailed statistics, session history, and achievements.
- Focus and Relaxation: Enjoy a minimalist interface designed to keep you centered and calm.
- 100% Free and Open Source: No ads, no tracking, just pure breathing.

If it were a startup, that description would say "Start your journey to better heart health and mental clarity today with coAIRence!"

# Run the app

If you get a build error (`Error: Gradle build failed to produce an .apk file. It's likely that this file was generated under build/, but the tool couldn't find it.`), use the following command sto run the app:

## Debug

```sh
flutter run --flavor dev --debug
```

## Profile  

```sh
flutter run --flavor staging --profile
```

## Release APK

```sh
./release-android.sh # Small wrapper to provide proper signing keys
keytool -v -printcert -jarfile build/app/outputs/bundle/prodRelease/app-prod-release.aab # Check signature
```
