const axios = require('axios');
const fs = require('fs-extra');
const path = require('path');

async function downloadData() {
    const dataDir = path.join(__dirname, 'data');
    await fs.ensureDir(dataDir);
    await fs.ensureDir(path.join(dataDir, 'chapters'));

    console.log('Fetching chapters list...');
    const chaptersRes = await axios.get('https://api.quran.com/api/v4/chapters?language=uz');
    await fs.writeJson(path.join(dataDir, 'chapters.json'), chaptersRes.data, { spaces: 2 });

    console.log('Fetching verses for 114 chapters...');
    for (let i = 1; i <= 114; i++) {
        try {
            const versesRes = await axios.get(
                `https://api.quran.com/api/v4/verses/by_chapter/${i}?translations=101&fields=text_uthmani,text_uthmani_tajweed,page_number,juz_number&per_page=300`
            );
            await fs.writeJson(path.join(dataDir, 'chapters', `${i}.json`), versesRes.data, { spaces: 2 });
            console.log(`Saved chapter ${i}`);
        } catch (e) {
            console.error(`Failed on chapter ${i}`, e.message);
        }
        await new Promise(r => setTimeout(r, 150)); // Rate limit himoyasi
    }

    console.log('Data successfully downloaded!');
}

downloadData();
