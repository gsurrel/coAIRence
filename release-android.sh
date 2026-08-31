read -s -p "Keystore password: " KEYSTORE_PASSWORD; echo
export KEYSTORE_PASSWORD
export KEYSTORE=/path/to/your.jks
export KEY=your-alias

cd android
./gradlew bundleProdRelease
