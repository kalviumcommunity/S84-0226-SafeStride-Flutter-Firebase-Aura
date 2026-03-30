# Google Sign-In Setup Guide

This guide walks through the final configuration steps needed to enable fully functional Google Sign-In in SafeStride.

## What's Been Implemented

✅ **Google Sign-In Package Added** - Added `google_sign_in: ^6.2.1` to pubspec.yaml
✅ **AuthService Methods** - Implemented `signInWithGoogle()` and `signOutGoogle()` methods
✅ **Login UI Wired** - Google Sign-In button is now functional with loading states
✅ **User Profile Creation** - New Google users automatically get Firestore profiles with proper fields
✅ **Logout Handler** - Updated profile screen to handle Google sign-out properly

## Required Setup Steps

### 1. Google Cloud Console Configuration

#### a. Create/Configure Your Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select your existing project
3. Enable the **Google Identity Services API**
4. Navigate to **APIs & Services** → **Credentials**

#### b. Create OAuth 2.0 Credentials
1. Click **Create Credentials** → **OAuth 2.0 Client IDs**
2. You'll need to configure the OAuth consent screen first:
   - User Type: **External** (or Internal if in Google Workspace)
   - Add required app information
   - Add your email as a test user

#### c. Create Android OAuth Client ID
1. In Credentials, click **+ Create Credentials** → **OAuth 2.0 Client IDs**
2. Select **Android**
3. Enter your app's **Package Name**: `com.example.safestride_app`
4. Get your app's **SHA-1 fingerprint**:

   ```bash
   # For debug keystore:
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For release keystore (if you have one):
   keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
   ```

5. Paste the SHA-1 fingerprint and click **Create**

#### d. Create iOS OAuth Client ID
1. In Credentials, click **+ Create Credentials** → **OAuth 2.0 Client IDs**
2. Select **iOS**
3. Enter your **Bundle ID**: `com.example.safestride-app` (check your ios/Runner/Info.plist)
4. Click **Create**
5. Download the GoogleService-Info.plist file

#### e. Create Web OAuth Client ID (if deploying to web)
1. In Credentials, click **+ Create Credentials** → **OAuth 2.0 Client IDs**
2. Select **Web application**
3. Add authorized redirect URIs:
   - `http://localhost:7357`
   - `http://localhost:7357/` (with trailing slash)
   - Your production domain when available
4. Click **Create** and note the **Client ID**

### 2. Android Setup

#### a. Update google-services.json
1. Download your `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. The file should already be in your project structure

#### b. No additional Android configuration needed
The build.gradle.kts already has the proper Google Services plugin configured.

### 3. iOS Setup

#### a. Update GoogleService-Info.plist
1. Download `GoogleService-Info.plist` from your Google Cloud Console OAuth 2.0 iOS credentials
2. Open Xcode: `open ios/Runner.xcworkspace`
3. Drag and drop `GoogleService-Info.plist` into the Runner project
4. Make sure it's added to the Runner target

#### b. Configure Info.plist
Your `ios/Runner/Info.plist` should already include the URL scheme. Verify or add:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your actual Client ID from Google Cloud Console -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

### 4. Web Setup (if applicable)

For web deployment, add the Google Client ID to `web/index.html`:

```html
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

The flutter_web platform's Google Sign-In will use the web OAuth client ID you created.

### 5. Update Web Configuration

If you have a Next.js web project (`web-next/`), you'll need to handle Google Sign-In there separately:

1. Install Next.js Google Sign-In package:
   ```bash
   cd web-next
   npm install next-google-login
   ```

2. Configure environment variables in `web-next/.env.local`:
   ```
   NEXT_PUBLIC_GOOGLE_CLIENT_ID=your-web-oauth-client-id
   ```

## Testing Google Sign-In

### Android Testing
```bash
cd path/to/S84-0226-SafeStride-Flutter-Firebase-Aura
flutter run -d android
```

1. Navigate to the login screen
2. Click "Sign in with Google"
3. A Google Sign-In dialog will appear
4. Use a test Google account
5. User should be signed in and profile created in Firestore

### iOS Testing
```bash
flutter run -d ios
```

Same testing procedure as Android.

### Web Testing
```bash
flutter run -d chrome
```

1. Same flow as mobile
2. Google Sign-In dialog opens in browser
3. Complete authentication

## Firestore Structure

When a user signs in with Google, their profile is automatically created with this structure:

```
/users/{uid}
├── uid: string
├── email: string (from Google account)
├── displayName: string (from Google account)
├── photoURL: string (from Google account)
├── activityType: string ("runner" or "cyclist" from login screen toggle)
├── bio: string
├── darkMode: boolean
├── notificationsEnabled: boolean
├── preferredDistance: number
├── savedRoutesCount: number
├── reviewsCount: number
├── favoritesCount: number
├── totalDistanceKm: number
├── createdAt: timestamp
└── lastLoginAt: timestamp
```

## Error Handling

The implementation includes comprehensive error handling:

- **Cancelled Sign-In**: Shows user-friendly message
- **Network Errors**: Caught and reported
- **Firebase Errors**: Mapped to readable messages
- **Firestore Write Errors**: Logged and reported

All error messages are displayed via snackbars in the login screen.

## Code Reference

### AuthService Methods

#### signInWithGoogle()
```dart
Future<UserCredential> signInWithGoogle({String activityType = 'runner'}) async
```

- Initiates Google Sign-In flow
- Creates user profile in Firestore for new users
- Updates lastLoginAt for existing users
- Returns the Firebase UserCredential

#### signOutGoogle()
```dart
Future<void> signOutGoogle() async
```

- Signs out from both Firebase and Google
- Clears all authentication state
- Can be called safely even if user isn't logged in with Google

### LoginScreen Updates

The Google Sign-In button now:
- Shows loading state during authentication
- Respects the selected activity type (🏃 Runner / 🚴 Cyclist)
- Provides visual feedback with spinner
- Handles all error cases gracefully

## Troubleshooting

### iOS: "The user cancelled the sign-in flow"
This is normal behavior when users cancel. The app handles it gracefully.

### Android: "com.google.android.gms.common.api.ApiException"
This usually means:
1. SHA-1 fingerprint doesn't match
2. google-services.json is missing or incorrect
3. Package name doesn't match

**Solution**: Regenerate your OAuth client with the correct SHA-1 from keytool.

### Web: "oauth2_callback error"
Usually means the redirect URI isn't registered in Google Console.

**Solution**: Add `http://localhost:7357` and your production domain to authorized redirect URIs.

### "GoogleSignIn failed"
Check:
1. Google Cloud Project has Google Identity Services API enabled
2. OAuth consent screen is properly configured
3. Test user account is added (if user type is External)

## Security Notes

✅ **Best Practices Implemented**:
- OAuth tokens are handled by Firebase/Google Sign-In packages (no tokens stored locally)
- Firestore rules should be configured to protect user data
- No credentials are logged or exposed
- Activity type is stored but user can update it later

⚠️ **Production Checklist**:
- [ ] Use production OAuth credentials (not debug)
- [ ] Configure proper Firestore security rules
- [ ] Set up privacy policy and terms of service
- [ ] Test with real Google accounts
- [ ] Implement app review compliance
- [ ] Configure correct Bundle IDs for iOS (match App Store)
- [ ] Configure correct package names for Android (match Play Store)

## Next Steps

1. ✅ Complete the Google Cloud Console setup above
2. ✅ Run the app and test Google Sign-In
3. ✅ Verify user profiles are created in Firestore
4. ✅ Test logout flow
5. ✅ Configure Firestore security rules
6. ✅ Set up proper error monitoring (Crashlytics)

## Support

For common issues with google_sign_in package:
- [google_sign_in pub.dev](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication Web](https://firebase.google.com/docs/auth)
- [Firebase Authentication Mobile](https://firebase.google.com/docs/auth/part-1)

---

**Last Updated**: March 24, 2026
**Status**: ✅ Ready for Google Cloud Console Configuration
