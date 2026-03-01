---
name: offline-first-expert
description: Specialist in Offline-First App Development using Hive, SQLite, or SharedPreferences.
---
# Offline-First App Expert

This application MUST work flawlessly without an internet connection after the initial data download. 

### 1. Local Storage Strategy
- **Small key-value pairs (Settings, simple states)**: Use `shared_preferences`.
- **Large datasets / JSON (Quran text, Duas, Hadiths)**: Use `Hive` (NoSQL) or `sqflite` (SQL). 
- **Binary Files (MP3, Images)**: Download to Application Documents Directory using `path_provider` and `dio`, store the local absolute path in DB/SharedPreferences.

### 2. Synchronization & Fallback
- Always check if the file or data exists locally FIRST before making a network request.
- If data doesn't exist locally:
  1. Check network connectivity (`connectivity_plus`).
  2. If online: Fetch, parse, SAVE LOCALLY, then display.
  3. If offline: Show a friendly offline fallback UI ("Please connect to internet to download first").

### 3. Handling Big Files
- For surah audios, implement background downloading where possible. 
- Clean up partially downloaded or corrupted files if a download fails.

### 4. State Indication
- Clearly show users when something is playing from local cache vs downloading from the cloud. 
