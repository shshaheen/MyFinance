# Flutter Firebase Setup & Project Execution Guide

## Prerequisites
Ensure you have the following installed before proceeding:
- Flutter SDK
- Dart
- Firebase CLI

## Setting Up the Project

### 1. Clone the Project Repository
Run the following command in the terminal to clone the project:
```sh
git clone https://github.com/shshaheen/MyFinance.git
mv MyFinance my_finance
cd my_finance
```

### 2. Open the Project in an Editor
Use your preferred code editor (VS Code, Android Studio, etc.) to open the project.

### 3. Get Dependencies
Run the following command in the terminal:
```sh
flutter pub get
```

### 4. Create a Firebase Project
Follow these steps to set up Firebase:
1. Visit [Firebase Console](https://firebase.google.com/).
2. Click on **Get Started**.
3. Click on **Create a project**.
4. Enter a project name and click **Continue**.
5. **Disable Gemini** in Firebase and click **Continue**.
6. **Disable Google Analytics** and click **Continue**.
7. Your Firebase project will start creating; once done, click **Continue**.

### 5. Enable Firebase Authentication
1. In the Firebase **Overview**, select **Authentication**.
2. Click **Get Started**.
3. Under the **Sign-in method** tab, select **Email/Password**.
4. Toggle **Enable**, then click **Save**.
5. Authentication setup is complete.

### 6.Firestore Setup
1. In the Firebase Console sidebar, click on Build.
2. Select Firestore Database.
3. Click on Get Started.
4. Choose your location and click Next.
5. Select Start in test mode and then click Next.
6. Click Create, and your Firestore database is ready!

### 7. Configure Firebase in Flutter
Run the following command in the terminal to configure Firebase in your Flutter project:
```sh
flutterfire configure
```
Steps to Configure Firebase in Flutter:
1. After running flutterfire configure, you will be prompted to select a Firebase project.
2. Select the Firebase project you created earlier.
3. Choose the platform (Android, iOS, Web) for your Flutter app.

### 8. Run the Project
Use the following command to run the project on an emulator or physical device:
```sh
flutter run
```

Your Flutter app with Firebase Authentication is now set up and ready to run!

