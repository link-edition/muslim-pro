const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs-extra');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 10000;

app.use(cors());
app.use(express.json());

// Public folder
const PUBLIC_DIR = path.join(__dirname, 'public');
fs.ensureDirSync(PUBLIC_DIR);
app.use('/static', express.static(PUBLIC_DIR));

// Data qismi - local saqlangan JSON-lar
const DATA_DIR = path.join(__dirname, 'data');

// Asosiy ma'lumot qutisi (Xotirada keshlab qo'yish tezlikni oshiradi)
let chaptersData = null;
const versesByChapter = {};
let versesByPage = {};

// Barcha chapterlarni va oyatlarni server yoqilishi bilan xotiraga olish
async function loadData() {
    try {
        const chaptersPath = path.join(DATA_DIR, 'chapters.json');
        if (await fs.pathExists(chaptersPath)) {
            chaptersData = await fs.readJson(chaptersPath);
        }

        for (let i = 1; i <= 114; i++) {
            const chapPath = path.join(DATA_DIR, 'chapters', `${i}.json`);
            if (await fs.pathExists(chapPath)) {
                versesByChapter[i] = await fs.readJson(chapPath);

                // Oyatlarni betlarga bo'lib indexing qilish
                const verses = versesByChapter[i].verses;
                if (verses && Array.isArray(verses)) {
                    for (const v of verses) {
                        const page = v.page_number;
                        if (!versesByPage[page]) versesByPage[page] = [];
                        versesByPage[page].push(v);
                    }
                }
            }
        }
        console.log("Memory DB loaded successfully.");
    } catch (e) {
        console.error("Error loading data:", e);
    }
}
loadData();

app.get('/api', (req, res) => {
    res.json({
        message: "Muslim App Backend v1",
        status: "Online"
    });
});

// Mushaf ZIP yo'naltirishlari
app.get('/api/mushaf/standard', (req, res) => {
    res.redirect('https://github.com/GovarJabbar/Quran-PNG/archive/refs/heads/master.zip');
});

app.get('/api/mushaf/tajweed', (req, res) => {
    res.redirect('https://github.com/HiIAmMoot/quran-android-tajweed-page-provider/archive/refs/heads/main.zip');
});

// Suralar ro'yxati (api.quran.com kabi)
app.get('/api/quran/chapters', (req, res) => {
    if (chaptersData) {
        // As api.quran.com response was something like { chapters: [...] }
        res.json(chaptersData);
    } else {
        res.status(503).json({ error: "Data is loading" });
    }
});

// Biror suraning barcha oyatlari
app.get('/api/quran/verses/by_chapter/:id', (req, res) => {
    const id = req.params.id;
    if (versesByChapter[id]) {
        res.json(versesByChapter[id]);
    } else {
        res.status(404).json({ error: "Chapter not found" });
    }
});

// Biror betning barcha oyatlari 
app.get('/api/quran/verses/by_page/:id', (req, res) => {
    const page = parseInt(req.params.id);
    if (!isNaN(page) && versesByPage[page]) {
        // api.quran.com formasi
        res.json({ verses: versesByPage[page] });
    } else {
        res.status(404).json({ error: "Page not found or not yet available" });
    }
});

// Duolar bazasi (Hisnul Muslim O'zbekcha)
app.get('/api/duas', async (req, res) => {
    try {
        const duasPath = path.join(DATA_DIR, 'duas_uz.json');
        if (await fs.pathExists(duasPath)) {
            const duas = await fs.readJson(duasPath);
            res.json(duas);
        } else {
            res.status(404).json({ error: "Duas not found" });
        }
    } catch (e) {
        res.status(500).json({ error: "Server error" });
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
