const axios = require('axios');
const fs = require('fs-extra');
const path = require('path');

async function downloadData() {
    const dataDir = path.join(__dirname, 'data');
    console.log('Clearing old data...');
    await fs.remove(dataDir);
    await fs.ensureDir(dataDir);
    await fs.ensureDir(path.join(dataDir, 'chapters'));

    console.log('Fetching chapters list...');
    const chaptersRes = await axios.get('https://api.quran.com/api/v4/chapters?language=uz');
    await fs.writeJson(path.join(dataDir, 'chapters.json'), chaptersRes.data, { spaces: 2 });

    console.log('Fetching verses with Tajweed & Audio...');
    for (let i = 1; i <= 114; i++) {
        try {
            // Reciter 7 is Mishary Rashid Al-Afasy
            // Translation 101 is Uzbek (Muhammad Sodik Muhammad Yusuf)
            const url = `https://api.quran.com/api/v4/verses/by_chapter/${i}?translations=101&fields=text_uthmani,text_uthmani_tajweed,page_number,juz_number,verse_number&audio=7&per_page=300`;
            const versesRes = await axios.get(url);

            // Add full audio URL for convenience and ensure tajweed text is present
            const verses = versesRes.data.verses.map(v => {
                if (v.audio && v.audio.url) {
                    v.audio_url = `https://audio.quran.com/reciters/7/${v.audio.url}`;
                } else {
                    // Fallback Construct if not present
                    const s = v.verse_key.split(':')[0].padStart(3, '0');
                    const a = v.verse_key.split(':')[1].padStart(3, '0');
                    v.audio_url = `https://download.quranicaudio.com/quran/mishari_rashid_al-afasy/${s}${a}.mp3`;
                }
                return v;
            });

            await fs.writeJson(path.join(dataDir, 'chapters', `${i}.json`), { verses }, { spaces: 2 });
            console.log(`Saved Chapter ${i} with Tajweed and Audio`);
        } catch (e) {
            console.error(`Failed on chapter ${i}`, e.message);
        }
        await new Promise(r => setTimeout(r, 50)); // Rate limit
    }

    console.log('Data successfully refreshed with Uthmani Tajweed and Audio links!');
}

downloadData();
