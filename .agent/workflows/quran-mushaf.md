---
description: Qur'on Mushaf sahifasi ustida ishlash davomi
---

# Muslim Pro — Qur'on bo'limi holati

## Oxirgi sessiya: 2026-02-23

## Qilingan ishlar:

### 1. Qur'on Landing Page ✅
- `lib/features/quran/presentation/quran_landing_page.dart`
- Ikki karta: "Qur'on" (o'qish) va "Audio Qur'on" (tinglash)
- Home Screen dan `QuranLandingPage` ga navigatsiya

### 2. Qur'on o'qish (Mushaf) bo'limi ✅
- `lib/features/quran/presentation/quran_text_screen.dart` — Suralar ro'yxati
- `lib/features/quran/presentation/surah_reading_screen.dart` — Mushaf sahifasi
- Horizontal PageView (o'ngdan chapga varoqlash)
- Oyatlar API dan kelgan `page_number` bo'yicha guruhlanadi (604 bet standarti)
- Tajvid ON/OFF (rangli HTML yoki oddiy matn)
- 3 fon rangi: Oq, Sepia, Qora
- Tarjima yo'q — faqat arabcha matn
- `<sup>` va `foot_note` teglar tozalangan
- FittedBox bilan ekranga sig'dirish

### 3. AyahModel yangilangan ✅
- `pageNumber` va `juzNumber` maydonlari qo'shilgan
- API so'roviga `page_number,juz_number` fields qo'shilgan

### 4. Audio Qur'on ✅ (avvaldan ishlaydi)
- `lib/features/quran/presentation/quran_screen.dart` — suralar ro'yxati
- `lib/features/quran/presentation/surah_detail_screen.dart` — audio pleyer
- Mishary Rashid qiroati + Alouddin Mansur tarjimasi

## Davom ettirish kerak:

### Tekshirish:
1. Mushaf sahifasini telefondan sinash — matn ko'rinyaptimi?
2. Tajvid ranglari to'g'ri ishlayaptimi?
3. PageView varoqlash silliq ishlayaptimi?
4. FittedBox matnni to'g'ri sig'diryaptimi?

### Keyingi vazifalar:
1. **Qur'on o'qish sahifasini yaxshilash** — agar matn ko'rinmasa HtmlWidget muammosini hal qilish
2. **Lotin/Kirill konvertor** — Audio Qur'on tarjimasiga qo'shish
3. **Azan bildirishnomasi** — Push notification
4. **Qibla kompasi** — premium dizayn

## Muhim texnik ma'lumotlar:
- API: `api.quran.com/api/v4`
- `getAyahs()` ishlaydi (Audio Qur'on ham shu)
- `getPage()` timeout bergan (604-bet rejimda ishlatilmagan)
- Git commit: `714ce1a` — "Quran Mushaf 604-bet standarti"
- Device: SM-S908N (R5CT21P3SXW)
- Flutter run: `flutter run -d "R5CT21P3SXW"`
