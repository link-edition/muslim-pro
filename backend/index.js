const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs-extra');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 10000;

app.use(cors());
app.use(express.json());

// Qur'on tekstlari va audio linklari uchun bazani (JSON) tayyorlash
// Realdan quran-api yoki fayllardan foydalansa bo'ladi.
// Hozirda biz ZIP fayllarni server orqali tarqatish uchun yo'llarni ochamiz.

// Statik fayllar uchun papka (agar rasm yoki audiolarni o'zimizda saqlasak)
const PUBLIC_DIR = path.join(__dirname, 'public');
fs.ensureDirSync(PUBLIC_DIR);
app.use('/static', express.static(PUBLIC_DIR));

// 1. API: Surahlar ro'yxati (proxy kabi ishlaydi yoki keshdan beradi)
app.get('/api/chapters', async (req, res) => {
    try {
        // Bu joyda xohlasangiz o'zingizning JSON baza-dan ma'lumot qaytarishingiz mumkin
        // Hozircha namunaviy javob:
        res.json({
            message: "Muslim App Backend v1",
            status: "Online",
            endpoints: {
                mushaf_standard: "/api/mushaf/standard",
                mushaf_tajweed: "/api/mushaf/tajweed",
                audio: "/api/audio/:id"
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 2. Mushaf ZIP fayllari uchun yo'naltirish (Redirect)
// Render-da disk joyi kam bo'lsa, GitHub-dagi ZIP-ga yo'naltiramiz
// Agar serveringizda joy bo'lsa, faylni o'ziga joylash mumkin.
app.get('/api/mushaf/standard', (req, res) => {
    res.redirect('https://github.com/GovarJabbar/Quran-PNG/archive/refs/heads/master.zip');
});

app.get('/api/mushaf/tajweed', (req, res) => {
    res.redirect('https://github.com/HiIAmMoot/quran-android-tajweed-page-provider/archive/refs/heads/main.zip');
});

// 3. Audio linklar (Masalan: Al-Afasy)
app.get('/api/audio/:number', (req, res) => {
    const num = req.params.number.padStart(3, '0');
    // Mashhur audio serveriga yo'naltiramiz
    res.json({
        surah: req.params.number,
        audio_url: `https://download.quranicaudio.com/quran/mishari_rashid_al-afasy/${num}.mp3`
    });
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
