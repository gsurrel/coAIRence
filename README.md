# coAIRence

An app for training cardiac coherance.

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
flutter build apk --flavor prod --release
```
