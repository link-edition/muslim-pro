import json

duas = [
  {
    "id": 1,
    "category": "Hayotiy",
    "title": "Safar duosi",
    "arabic": "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ",
    "transcription": "",
    "translation": "Bizga buni (ulovni) bo'ysundirib qo'ygan Zot pokdir. Biz aslida unga qodir emas edik. Va, albatta, begumon, biz Robbimizga qaytguvchilardirmiz."
  },
  {
    "id": 2,
    "category": "Hayotiy",
    "title": "Boylik va baraka so'rash duosi",
    "arabic": "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا",
    "transcription": "",
    "translation": "Ey Allohim! Men Sendan foydali ilm, pok-pokiza rizq (boylik) va qabul bo'ladigan amal so'rayman."
  },
  {
    "id": 3,
    "category": "Hayotiy",
    "title": "Qarzdan qutulish duosi",
    "arabic": "اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ",
    "transcription": "",
    "translation": "Ey Allohim! Menga haloling bilan haromingdan kifoya qilgin va O'z fazling bilan meni O'zingdan boshqalardan behojat (boy) qilgin."
  },
  {
    "id": 4,
    "category": "Hayotiy",
    "title": "Kasallik va dardga shifo duosi",
    "arabic": "اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَاسَ، اشْفِهِ وَأَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا",
    "transcription": "",
    "translation": "Ey insonlarning Robbi Alloh! Kasallikni ketkazgin. Shifo bergin, asil Shifo beruvchi O'zingsan. Sening shifoingdan boshqa shifo yo'qdir. Shunday shifo berki, kasallik asari ham qolmasin."
  },
  {
    "id": 5,
    "category": "Hayotiy",
    "title": "G'am va musibat yetganda",
    "arabic": "إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي، وَأَخْلِفْ لِي خَيْرًا مِنْهَا",
    "transcription": "",
    "translation": "Albatta biz Allohnikimiz va albatta Uning O'ziga qaytamiz! Ey Allohim! Musibatimda menga ajr bergin va o'rnini yaxshilik bilan qoplagin."
  },
  {
    "id": 6,
    "category": "Hayotiy",
    "title": "Biron ish og'ir bo'lganda o'qiladigan duo",
    "arabic": "اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا",
    "transcription": "",
    "translation": "Ey Allohim! O'zing oson qilgan narsadan boshqa oson narsa yo'q. Agar O'zing xohlasang, qiyinchilik (mushkullarning) barini osonga aylantirasan."
  },
  {
    "id": 7,
    "category": "Uy va Oila",
    "title": "Uydan chiqish duosi",
    "arabic": "بِسْمِ اللهِ، تَوَكَّلْتُ عَلَى اللهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ",
    "transcription": "",
    "translation": "Allohning nomi bilan uydan chiqaman. Allohga tavakkal qildim. Gunohdan saqlanish va toatga quvvat topish faqat Allohning yordami bilandir."
  },
  {
    "id": 8,
    "category": "Uy va Oila",
    "title": "Uyga kirish duosi",
    "arabic": "بِسْمِ اللهِ وَلَجْنَا، وَبِسْمِ اللهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا",
    "transcription": "",
    "translation": "Allohning nomi bilan kirdik, Allohning nomi bilan chiqdik va faqatgina Robbimizga tavakkal qildik."
  },
  {
    "id": 9,
    "category": "Uy va Oila",
    "title": "Ovqatlanishdan oldin",
    "arabic": "بِسْمِ اللهِ",
    "transcription": "",
    "translation": "Allohning nomi bilan."
  },
  {
    "id": 10,
    "category": "Uy va Oila",
    "title": "Ovqatdan keyingi duo",
    "arabic": "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ",
    "transcription": "",
    "translation": "Sira qodir bo'lmaganim holda shu taom bilan meni oziqlantirgan va rizq qilib bergan Allohga hamd bo'lsin."
  },
  {
    "id": 11,
    "category": "Uy va Oila",
    "title": "Ota-ona haqqiga duo",
    "arabic": "رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
    "transcription": "",
    "translation": "Ey Robbim! Ular (ota-onam) meni go'daklik chog'imda tarbiya qilganlaridek, Sen ularga rahm qilgin."
  },
  {
    "id": 12,
    "category": "Uy va Oila",
    "title": "Yangi kelin-kuyovni tabriklash duosi",
    "arabic": "بَارَكَ اللهُ لَكَ، وَبَارَكَ عَلَيْكَ، وَجَمَعَ بَيْنَكُمَا فِي خَيْرٍ",
    "transcription": "",
    "translation": "Alloh senga baraka bersin, ustingga baraka yog'dirsin va har ikkingizni yaxshilikda jamlasin."
  },
  {
    "id": 13,
    "category": "Tonggi",
    "title": "Uyqudan uyg'ongandagi duo",
    "arabic": "الْحَمْدُ للهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
    "transcription": "",
    "translation": "Bizni o'ldirgandan keyin tiriltirgan Allohga hamd bo'lsin va qaytish Ungadir."
  },
  {
    "id": 14,
    "category": "Tonggi",
    "title": "Tong ottirganda o'qiladigan",
    "arabic": "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
    "transcription": "",
    "translation": "Ey Allohim! Sening fazling ila tong otdirdik va Sening fazling ila kech kirguzdik. Faqat Sening ixtiyoring ila yashaymiz, vafot topamiz va Senga qaytamiz."
  },
  {
    "id": 15,
    "category": "Tonggi",
    "title": "Eng go'zal Istig'for (Sayyidul istig'for)",
    "arabic": "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ",
    "transcription": "",
    "translation": "Ey Allohim! Sen mening Robbimdirsan. Sendan o'zga iloh yo'q. Meni Sen yaratgansan va men Sening qulingman. Qurbim yetgunicha Senga bergan ahdim va va'dangdaman."
  },
  {
    "id": 16,
    "category": "Kechki",
    "title": "Uxlashdan oldingi duo",
    "arabic": "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
    "transcription": "",
    "translation": "Ey Allohim! Isming bilan o'laman va tirilaman."
  },
  {
    "id": 17,
    "category": "Kechki",
    "title": "Kech kirganda o'qiladigan",
    "arabic": "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ",
    "transcription": "",
    "translation": "Biz kechga kirdik va Mulk ham Allohga tegishli holda kechga kirdi. Barcha hamd Allohga xosdir. Yagona Allohdan o'zga iloh yo'q, Uning sherigi yo'q."
  },
  {
    "id": 18,
    "category": "Namoz",
    "title": "Masjidga kirish duosi",
    "arabic": "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
    "transcription": "",
    "translation": "Ey Allohim! Menga rahmating eshiklarini ochgin."
  },
  {
    "id": 19,
    "category": "Namoz",
    "title": "Masjiddan chiqish duosi",
    "arabic": "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ",
    "transcription": "",
    "translation": "Ey Allohim, Sendan fazlingni (boyliging va barakangni) so'rayman."
  },
  {
    "id": 20,
    "category": "Namoz",
    "title": "Tahoratdan so'ngi duo",
    "arabic": "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
    "transcription": "",
    "translation": "Guvohlik beramanki, yagona Allohdan o'zga iloh yo'q, Uning sherigi yo'q va guvohlik beramanki, Muhammad (sollallohu alayhi vasallam) Uning bandasi va Rasuli."
  }
]

with open("g:/muslim/assets/data/duas_uz.json", "w", encoding="utf-8") as f:
    json.dump(duas, f, ensure_ascii=False, indent=2)

print("Created highly requested and specific duas inside assets data.")
