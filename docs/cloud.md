# Cloud & Backend Architecture

## REST API

- **Base URL:** [add from existing project — replace this placeholder]
- **Auth:** JWT Bearer tokens (access + refresh)
- **Token storage:** `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android)
- **Token refresh:** Dio `AuthInterceptor` auto-refreshes on 401, retries original request
- **Error envelope format:**
  ```json
  { "success": false, "message": "Unauthorized", "data": null }
  ```

## Firebase Services

| Service               | Purpose                                        |
|-----------------------|------------------------------------------------|
| `firebase_auth`       | Social login (Google, Apple, Microsoft)        |
| `firebase_messaging`  | Push notifications (FCM)                       |
| `firebase_analytics`  | Key event tracking (bookings, signups, errors) |
| `firebase_app_check`  | API abuse prevention                           |
| `firebase_crashlytics`| Crash reporting + non-fatal error logging      |

## `ApiResult<T>` Pattern

Every network call returns `ApiResult<T>` — never throws, never returns null on failure.

```dart
sealed class ApiResult<T> {
  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(String message, {int? statusCode}) = ApiFailure<T>;
}
```

Usage:
```dart
final result = await _repo.login(phone, password);
result.fold(
  onFailure: (msg) => state = AuthState.error(msg),
  onSuccess: (user) => state = AuthState.authenticated(user),
);
```

## Auth Flow

### Mobile + Password
1. `POST /auth/login` with `{ mobile, password }`
2. Response: `{ accessToken, refreshToken, user }`
3. Tokens saved to `SecureStorageService`
4. On 401: `AuthInterceptor` calls `POST /auth/refresh` → retries

### Social Login (Firebase)
1. `firebase_auth.signInWithGoogle()` (or Apple / Microsoft)
2. Get Firebase ID token from credential
3. `POST /auth/firebase` with `{ idToken, provider }`
4. Response: `{ accessToken, refreshToken, user }`
5. Tokens saved to `SecureStorageService`

### Token Refresh
```
Client → POST /auth/refresh { refresh_token }
Server → 200 { access_token, refresh_token } | 401 (force logout)
```
On refresh failure: clear tokens + navigate to login.

## Environment Configuration

```dart
// lib/core/config/app_config.dart (to be created)
abstract final class AppConfig {
  static const baseUrl = String.fromEnvironment('BASE_URL',
    defaultValue: 'https://api.travelworldonline.com/v1');
}
```

Pass via `--dart-define=BASE_URL=https://...` in build commands.

## Push Notifications (FCM)

- FCM token registered on login, stored server-side
- Notification types: booking confirmation, circular from association, news alert
- Deep-link routing handled in `GoRouter` via `GoRouter.setNavigatorKey`

## Firebase Setup Checklist

- [ ] Add `google-services.json` to `android/app/`
- [ ] Add `GoogleService-Info.plist` to `ios/Runner/`
- [ ] Enable Firebase App Check (Play Integrity on Android, DeviceCheck on iOS)
- [ ] Enable Firebase Analytics debug mode for development
- [ ] Configure FCM for both platforms in Firebase Console
