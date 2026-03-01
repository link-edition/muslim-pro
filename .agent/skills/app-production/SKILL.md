---
name: app-production
description: Master of Production Readiness, App Store Deployment, and Error Monitoring in Flutter.
---
# Production & Release Readiness Master

When preparing code for production (Play Store / App Store), strict rules apply:

### 1. Error Handling & Crash Prevention
- Wrap critical async operations (Network ops, file reading, parsing) in `try-catch` blocks.
- Never let raw exceptions reach the user. Map them to user-friendly messages.
- Use a global error handler (e.g., `FlutterError.onError`, `PlatformDispatcher.instance.onPlatformError`).

### 2. App Size Optimization
- Ensure images are compressed (WebP is preferred over PNG/JPG). 
- Avoid heavy, unused packages. Clean `pubspec.yaml` regularly.
- Keep assets organized.

### 3. Security & Obfuscation
- Do not hardcode API keys or plain text secrets in the Dart code. Use `.env` files (e.g., `flutter_dotenv`).
- Prepare build scripts to obfuscate Dart code (`flutter build apk --obfuscate --split-debug-info=...`).

### 4. Logging
- Replace `print()` with `debugPrint()` or a proper logging framework (like `logger`).
- In production, debug prints must not be visible or slow down the app.

### 5. Review & Testing
- Write widget / unit tests for the most critical paths (like Prayer Calculation logic or Database access).
- Ensure no UI overflows occur on smaller screens (always test with `SafeArea` and `Flexible`/`Expanded`).
