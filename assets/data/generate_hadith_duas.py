import json

duas = []
id_counter = 1

def add_dua(category, title, intro, arabic, translation, ref):
    global id_counter
    duas.append({
        "id": id_counter,
        "category": category,
        "title": title,
        "narrator_intro": intro,
        "arabic": arabic,
        "transcription": "",
        "translation": translation,
        "reference": ref
    })
    id_counter += 1

# --- JUMA TONGIDA (Misolda ko'rsatilgandek) ---
add_dua(
    "Juma", 
    "1-duo",
    "Anas roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam:\n«Kim juma kuni bomdod namozidan oldin:",
    "أَسْتَغْفِرُ اللَّهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ",
    "«Astag'firullohallaziy laa ilaha illaa huval hayyul qoyyum va atubu ilayh», deb uch marta aytsa, Alloh taolo uning gunohlarini dengiz ko'pigicha bo'lsa ham, kechirib yuboradi», dedilar.\n\nMa'nosi: Hay va qayyum sifatli Zotdan boshqa iloh yo'q va Unga istig'for aytaman, Unga tavba qilaman.",
    "Ibn Sunniy rivoyati"
)

add_dua(
    "Juma",
    "2-duo",
    "Abu Hurayra roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam juma kuni tong otganda shunday der edilar:",
    "اللَّهُمَّ اجْعَلْنِي فِي عِيَاذِكَ وَجِوَارِكَ مِنْ شَرِّ نَفْسِي",
    "«Allohummaj'alniy fiy 'iyazika va jivarika min sharri nafsiy»\n\nMa'nosi: Ey Allohim! Meni nafsingning yomonligidan O'z panohingda va qo'shnichiligingda (omoningda) qilgin.",
    "Ibn Sunniy rivoyati"
)

# --- TONGGI DUOLAR ---
add_dua(
    "Tonggi",
    "1-duo",
    "Abu Hurayra roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam tong otganda shunday duoni o'qir edilar:",
    "اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
    "«Allohumma bika asbahnaa va bika amsaynaa, va bika nahyaa va bika namuutu va ilaykan nushuur»\n\nMa'nosi: Ey Allohim, Sening noming bilan tong ottirdik, Sening noming bilan kechga kirdik. Sening noming bilan yashaymiz va Sening noming bilan vafot etamiz. Va qaytish Sengadir.",
    "Termiziy rivoyati"
)

add_dua(
    "Tonggi",
    "2-duo",
    "Shaddod ibn Avs roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam:\n«Kimki (ushbu) sayyidul istig'forni tongda aytib, kech kirmasdan vafot etsa, jannat ahlidan bo'ladi», dedilar:",
    "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي؛ فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
    "«Allohumma anta robbiy laa ilaha illaa ant. Xolaqtaniy va ana a'bduk. Va ana a'laa ahdika va va'dika mastato'tu. A'uuzu bika min sharri maa sona'tu, abuu'u laka bini'matika a'layya va abuu'u laka bizambiy, fag'firliy fa innahuu laa yag'firuz-zunuuba illaa ant»\n\nMa'nosi: Ey Allohim, Sen mening Robbimdirsan. Sendan o'zga iloh yo'q. Meni Sen yaratding va men Sening qulingman. Va men qurbim yetganicha Senga bergan ahdim va va'damdaman. Qilgan ishlarimning yomonligidan panoh tilayman. Menga bergan ne'matlaringni e'tirof etaman. Gunohlarimni ham tan olaman. Meni mag'firat qilgin. Chunki Sendan boshqa hech kim gunohlarni kechirmas.",
    "Buxoriy rivoyati"
)

add_dua(
    "Tonggi",
    "3-duo (Oyatul Kursiy)",
    "Ubay ibn Ka'b roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam aytdilar: «Oyatul kursiyni tongda o'qigan kishi kechgacha jinlardan himoya qilinadi».",
    "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
    "Alloh — Undan o'zga haq ma'bud yo'q. U barhayot, butun borliqni tutib turuvchidir. Uni mudroq ham, uyqu ham tutmaydi. Osmonlar va yerdagi barcha narsalar Onikidir. Uning huzurida O'zining iznisiz kim ham shafoat qilar edi?! U ularning oldilaridagi narsani ham, orqalaridagi narsani ham bilur. Va baribir, Uning ilmidan faqat O'zi xohlaganidan boshqa hech narsani qamray olmaslar. Uning Kursiysi osmonlar va yerni qamrab olgandir. Va ularni hifz qilish Uni charchatmas. Va U Oliy, Buyukdir.",
    "Hakim rivoyati"
)


# --- NAMOZ ---
add_dua(
    "Namoz",
    "1-duo (Sano)",
    "Oisha roziyallohu anhodan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam namozni boshlasalar shunday derdilar:",
    "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ",
    "«Subhaanakallohumma va bihamdik, va tabaarokasmuk, va ta'aala jadduk, va laa ilaha g'oyruk»\n\nMa'nosi: Ey Allohim! Sen barcha nuqsonlardan poksan, Senga hamd bo'lsin, isming barakotlidir. Shoning ulug'dir. Sendan o'zga haq iloh yo'qdir.",
    "Termiziy, Abu Dovud va Nasoiy rivoyatlari"
)

add_dua(
    "Namoz",
    "2-duo (Ruku)",
    "Huzayfa roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam rukuda uch marta shunday derdilar:",
    "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
    "«Subhaana robbiyal a'ziym»\n\nMa'nosi: Ulug' darajali Robbim har qanday nuqsondan pokdir.",
    "Muslim, Abu Dovud va Imom Ahmad rivoyatlari"
)

add_dua(
    "Namoz",
    "3-duo (Tasbehlar)",
    "Abu Hurayra roziyallohu anhudan rivoyat qilinadi: “Kim har namozdan keyin 33 marta: Subhanalloh, 33 marta: Alhamdulillah, 33 marta: Allohu akbar deb, yuzinchisida (quyidagini) aytsa, uning gunohlari dengiz ko'pigicha bo'lsa ham kechib yuboriladi”:",
    "لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
    "«Laa ilaha illallohu vahdahu laa shariyka lah, lahul mulku va lahul hamdu va huva a’la kulli shay’in qodiyr»\n\nMa'nosi: Yagona Allohdan o'zga haq iloh yo'q. Uning sherigi ham yo'q. Mulk ham, maqtov ham Unikidir. U barcha narsaga qodirdir.",
    "Muslim rivoyati"
)


# --- KUNDALIK HAYOT ---
add_dua(
    "Kundalik",
    "1-duo (Uydan chiqishda)",
    "Anas roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam dedilar: «Kim uydan chiqayotib shunday desa, unga: \"Kifoya qilinding, himoya qilinding, to'g'ri yo'lga boshlanding\", deyiladi va shayton undan yiroqlashadi»:",
    "بِسْمِ اللهِ تَوَكَّلْتُ عَلَى اللهِ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ",
    "«Bismillahi, tavakkaltu a’lalloh, va laa havla va laa quvvata illaa billah»\n\nMa'nosi: Alloh nomi bilan boshlayman. Allohga tavakkal qildim. Allohsiz (kuch-qudrat keladigan va harakatlanadigan) hech qanday kuch ham, quvvat ham yo'q.",
    "Abu Dovud va Termiziy rivoyatlari"
)

add_dua(
    "Kundalik",
    "2-duo (Masjidga kirishda)",
    "Abu Humayd yoki Abu Usayd roziyallohu anhudan rivoyat qilinadi: Rasullulloh sollallohu alayhi vasallam aytdilar: «Qachon biringiz masjidga kirsa, Payg'ambarga salom aytsin va (shunday) desin»:",
    "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
    "«Allohummaftahliy abvaaba rohmatik»\n\nMa'nosi: Ey Allohim! Menga O'z rahmating eshiklarini ochgin.",
    "Muslim rivoyati"
)

add_dua(
    "Kundalik",
    "3-duo (Kiyim kiyganda)",
    "Muoz ibn Anas roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam aytdilar: «Kim bir kiyim kiyganda (ushbu) duoni o'qisa, uning o'tgan gunohlari kechiriladi»:",
    "الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا (الثَّوْبَ) وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ",
    "«Alhamdulillahillaziy kasaaniy haazassavba va rozoqoniyhi min g'oyri havlim-minniy va laa quvva»\n\nMa'nosi: Mening o'zimdan hech qanday kuch va quvvat bo'lmagani holda menga bu libosni kiydirib, meni u bilan rizqlantirgan Allohga barcha hamd (maqtov) bo'lsin.",
    "Termiziy, Abu Dovud, Ibn Mojah rivoyati"
)


# --- BEMORLIK VA MUSIBAT ---
add_dua(
    "Bemorlik",
    "1-duo (Kasal ko'rganda)",
    "Ibn Abbos roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam kasalni ko'rgani kirsalar, unga qarab:",
    "لَا بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ",
    "«Laa ba'sa tohuurun in shaa'alloh»\n\nMa'nosi: Hech qisi yo'q, xohlasa poklovchidir, deb aytar edilar.",
    "Buxoriy rivoyati"
)

add_dua(
    "Bemorlik",
    "2-duo (Musibat yetganda)",
    "Ummu Salama roziyallohu anhodan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam: «Birortangizga musibat yetsa, albatta biz Allohnikimiz va unga qaytamiz degach, (ushbu duoni) aytsa, Alloh taolo unga yaxshisidan o'rinbosar beradi», dedilar:",
    "إِنَّا للهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي، وَأَخْلِفْ لِي خَيْرًا مِنْهَا",
    "«Innaa lillahi va innaa ilayhi rooji'uun, Allohumma'jurniy fiy musiybatiy va axlifliy xoyrom-minhaa»\n\nMa'nosi: Albatta biz Allohnikimiz va albatta Undan Uning huzuriga qaytamiz! Ey Allohim! Musibatimda menga ajr bergin va o'rnini yaxshilik bilan qoplagin.",
    "Muslim rivoyati"
)


# --- SAFAR ---
add_dua(
    "Safar",
    "1-duo (Ulovga minganda)",
    "Ibn Umar roziyallohu anhudan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam safarga chiqib ulovga minganlarida uch marta takbir aytib («Allohu akbar»), so'ng (shunday) der edilar:",
    "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ",
    "«Subhaanal laziy soxxoro lanaa haaza va maa kunna lahu muqriniyn, va innaa ilaa robbinaa lamunqolibuun»\n\nMa'nosi: Buni bizga bo'ysundirib bergan zot butun nuqsonlardan pokdir, biz bunga mashaqqatsiz erisholmas edik. Biz, shubhasiz, Robbimizga qaytguvchilardirimiz.",
    "Muslim rivoyati"
)

add_dua(
    "Safar",
    "2-duo (Manzilga yetganda)",
    "Xavla binti Hakiym roziyallohu anhodan rivoyat qilinadi: Rasululloh sollallohu alayhi vasallam aytdilar: «Kim bir manzilga tushganda (ushbu duoni) aytsa, to o'sha manzildan ko'chib ketgunicha hech narsa unga zarar etkaza olmaydi»:",
    "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
    "«A'uuzu bikalimaatillahit taammaati min sharri maa xolaq»\n\nMa'nosi: Men Allohning to'liq – barcha kamchilikdan uzoq kalimalari vositasida O'zi yaratgan zararli narsalardan panoh tilayman.",
    "Muslim rivoyati"
)


# Write data into the JSON
with open("g:/muslim/assets/data/duas_uz.json", "w", encoding="utf-8") as f:
    json.dump(duas, f, ensure_ascii=False, indent=2)

print("Created 15 high-quality sample authentic Hadith duas with required JSON structures")
