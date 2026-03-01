# Amal — Loyiha Holati (v1.0)

Ushbu fayl loyihaning hozirgi holati va bajarilgan ishlar haqida qisqacha ma'lumot beradi. Yangi agent uchun qo'llanma.

## ✅ Bajarilgan ishlar:
1. **Tasbeh Bo'limi:**
   - Zikrlar ro'yxati, sanash funksiyasi, tebranish (vibration).
   - "Tarix va Statistika" sahifasi (v1.6). 
   - Uzbek Heatmap Calendar va Custom Bar Chart (fl_chart o'rniga shaxsiy implementatsiya).
2. **Qur'on Bo'limi:**
   - `api.quran.com` (v4) integratsiyasi.
   - Alouddin Mansur tarjimasi (ID: 101).
   - Mishary Rashid Alafasy qiroati (ID: 7).
   - Reading Settings: Fon rangi (Oq, Sepia, Dark), Tajvid rejimi, Shrift o'lchami.
   - Floating Audio Player implemented.
3. **Namoz Vaqtlari:**
   - `adhan` paketi orqali hisob-kitob.
   - Geolokatsiya orqali joylashuvni aniqlash.
4. **Texnik tuzatishlar:**
   - **Android/Gradle:** Kotlin versiyasi `2.1.0` ga, AGP versiyasi `8.7.0` ga yangilandi.
   - `gradle.properties` da `kotlin.incremental=false` qilindi (Drayvlar orasidagi ziddiyatni hal qilish uchun).

## 🛠 Ishlatilgan texnologiyalar:
- **Framework:** Flutter (3.6.2+)
- **State Management:** Flutter Riverpod (`quran_provider.dart`, `quran_settings_provider.dart` va h.k.)
- **Storage:** SharedPreferences, SQFlite.
- **Audio:** `just_audio`.
- **UI:** `google_fonts`, `flutter_widget_from_html`, `share_plus`.

## 🚀 Keyingi rejalar:
- Namoz vaqtlari uchun bildirishnomalar (Azan notification).
- Qibla kompasini premium ko'rinishga keltirish.
- Ilovani to'liq O'zbek tiliga mahalliylashtirish (Localization).

---
*Yangi agentga ko'rsatma:* Loyihani davom ettirishdan oldin `lib/features/` papkasini ko'zdan kechir. Gradle muammolari bo'lsa, `android/settings.gradle` dagi versiyalarga tayan.
