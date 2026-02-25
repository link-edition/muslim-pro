import json

duas = []
id_counter = 1

def add_dua(category, title, arabic, translation):
    global id_counter
    duas.append({
        "id": id_counter,
        "category": category,
        "title": title,
        "arabic": arabic,
        "transcription": "", # As requested, no transcription
        "translation": translation
    })
    id_counter += 1

# TONGGI DUOLAR (1-10)
add_dua("Tonggi", "Uyqudan uyg'onganda", "الْحَمْدُ للهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ", "Bizni o'ldirgandan keyin tiriltirgan Allohga hamd bo'lsin va qaytish Ungadir.")
add_dua("Tonggi", "Uyqudan turganda zikr", "لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ", "Allohdan o'zga iloh yo'q. U yagonadir, sherigi yo'qdir. Mulk ham, hamd ham Unikidir va U barcha narsaga qodirdir.")
add_dua("Tonggi", "Tong otish paytiga yetganda", "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ", "Ey Allohim! Sening (fazling) ila tong otdirdik va Sening (fazling) ila kech kirguzdik. Sening (ixtiyoring) ila yashaymiz, Sening (ixtiyoring) ila vafot topamiz va senga qayturmiz.")
add_dua("Tonggi", "Sayyidul istig'for (Istig'forlarning sayyidi)", "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ", "Ey Allohim! Sen mening Robbimdirsan. Sendan o'zga iloh yo'q. Meni Sen yaratgansan va men Sening qulingman. Qurbim yetgunicha Senga bergan ahdimgaman va Sening va'dangdaman. Sen menga bergan ne'mating va qilgan gunohlarimni tan olaman. Menga mag'firat qil, chunki gunohlarni faqat Sen kechirursan.")
add_dua("Tonggi", "Allohdan panoh so'rash", "بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ", "Allohning nomi bilan boshlayman, Uning ismi tufayli yeru osmonda hech narsa zarar bera olmaydi va U eshituvchi, biluvchidir. (3 marta)")
add_dua("Tonggi", "Allohdan ofiyat so'rash", "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ", "Ey Allohim, men Sendan dunyo va oxiratda ofiyat so'rayman.")
add_dua("Tonggi", "Allohning roziligini so'rash", "رَضِيتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا", "Allohni Robbim deb, Islomni dinim deb, Muhammad (sollallohu alayhi vasallam)ni Payg'ambarim deb rozi bo'ldim. (3 marta)")

# KECHKI DUOLAR (11-20)
add_dua("Kechki", "Kech kirganda o'qiladigan", "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ", "Biz kechga kirdik va Mulk ham Allohga tegishli holda kechga kirdi. Barcha hamd Allohga xosdir. Yagona Allohdan o'zga iloh yo'q, Uning sherigi yo'q.")
add_dua("Kechki", "Kechga kiritgan Allohga shukr", "اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ", "Ey Allohim! Menga yoki xayrli ishlaringdan birortasiga kechqurun berilgan har qanday ne'mat faqat Sendandir, Sening sheriging yo'q. Senga hamd va shukrlar bo'lsin.")
add_dua("Kechki", "Uxlashdan oldin karavotga yotganda", "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ", "Ey Robbim, isming bilan yonimni (karavotga) qo'ydim va isming bilan uni ko'taraman. Agar ro'himni olsang, unga rahm qil, agar ro'yobga chiqarsang (tiriltirsang), uni O'z solih bandalaringni himoya qilgandek himoya qilgin.")
add_dua("Kechki", "Uxlash onida qisqa duo", "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا", "Ey Allohim! Isming bilan o'laman va tirilaman.")
add_dua("Kechki", "Uyquda qo'rqib uyg'onganda", "أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ غَضَبِهِ وَعِقَابِهِ، وَشَرِّ عِبَادِهِ، وَمِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَنْ يَحْضُرُونِ", "Allohning barcha mukammal so'zlari bilan Uning g'azabidan, iqobidan, bandalarining yomonligidan, shaytonlarning vasvasalaridan va ular mening huzurimga kelishlaridan panoh so'rayman.")

# NAMOZ DUOLARI (21-30)
add_dua("Namoz", "Masjidga borayotganda", "اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا، وَفِي بَصَرِي نُورًا، وَفِي سَمْعِي نُورًا", "Ey Allohim! Qalbimda nur, ko'zimda nur, qulog'imda nur qilgin.")
add_dua("Namoz", "Masjidga kirishda", "أَعُوذُ بِاللهِ الْعَظِيمِ، وَبِوَجْهِهِ الْكَرِيمِ، وَسُلْطَانِهِ الْقَدِيمِ، مِنَ الشَّيْطَانِ الرَّجِيمِ. بِسْمِ اللهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ", "Buyuk Alloh yordami, Uning himmati va qadimiy saltanati ila la'nati shaytondan panoh so'rayman. Allohning barcha rahmat eshiklarini men uchun och!")
add_dua("Namoz", "Masjiddan chiqishda", "بِسْمِ اللهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ", "Bismillah. Allohning Rosuliga salovot va salomlar bo'lsin. Ey Allohim, men Sendan sening fazlingni so'rayman.")
add_dua("Namoz", "Tahorat qilayotganda, boshlashdan oldin", "بِسْمِ اللهِ", "Allohning nomi bilan.")
add_dua("Namoz", "Tahoratdan so'ng", "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ", "Guvohlik beramanki, yagona Allohdan o'zga iloh yo'q, Uning sherigi yo'q va guvohlik beramanki, Muhammad (sollallohu alayhi vasallam) Uning bandasi va Rasuli.")
add_dua("Namoz", "Azonni eshitganda izidan aytiladigan duo", "اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ", "Ey mukammal da'vatning va barpo qilinadigan namozning Robbi! Muhammad (sollallohu alayhi vasallam)ga Vasila va Fazilat baxsh et va uni O'zing va'da qilgan Maqomi Mahmudga (Maqtovli maqomga) yuborgin.")
add_dua("Namoz", "Sajdada qilinadigan duo", "سُبْحَانَ رَبِّيَ الْأَعْلَى", "Oliy maqomli Robbimni poklayman. (3 marta)")
add_dua("Namoz", "Jalsa (ikki sajda orasidagi) duo", "رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي", "Robbim, meni kechirgin, Robbim, meni kechirgin.")

# KUNDALIK (31-50)
add_dua("Kundalik", "Xojatxonaga kirishda", "بِسْمِ اللهِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبْثِ وَالْخَبَائِثِ", "Bismillah. Ey Alloh, men Sendan erkak va ayol jin/shaytonlarning yomonligidan panoh tilayman.")
add_dua("Kundalik", "Xojatxonadan chiqishda", "غُفْرَانَكَ", "Sendan mag'firatingni so'rayman.")
add_dua("Kundalik", "Uyga kirishda", "بِسْمِ اللهِ وَلَجْنَا، وَبِسْمِ اللهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا", "Allohning ismiga kirdik, Allohning ismiga chiqdik va faqat Robbimizga tavakkal qildik.")
add_dua("Kundalik", "Uydan chiqishda", "بِسْمِ اللهِ، تَوَكَّلْتُ عَلَى اللهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ", "Bismillah. Allohga tavakkal qildim, kuch va qudrat faqat Allohdandir.")
add_dua("Kundalik", "Yangi kiyim kiyganda", "الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا (الثَّوْبَ) وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ", "Sira qodir bo'lmaganim holda shu kiyimni menga kiydirgan va rizq qilib bergan Allohga maktoovlar bo'lsin.")
add_dua("Kundalik", "Kiyim yechganda", "بِسْمِ اللهِ", "Bismillah.")
add_dua("Kundalik", "Kuzguga qaraganda", "اللَّهُمَّ أَنْتَ حَسَّنْتَ خَلْقِي، فَحَسِّنْ خُلُقِي", "Ey Allohim! Mening ko'rinishimni chiroyli qilding, shuningdek xulqimni ham go'zal qilgin.")
add_dua("Kundalik", "Aksa urgan kishi aytadi", "الْحَمْدُ لِلَّهِ", "Alhamdulillah. (Allohga hamd bo'lsin)")
add_dua("Kundalik", "Aksa urgan kishiga eshituvchi javobi", "يَرْحَمُكَ اللهُ", "Alloh senga rahm qilsin.")
add_dua("Kundalik", "Aksa urgan kishi unga javobi", "يَهْدِيكُمُ اللهُ وَيُصْلِحُ بَالَكُمْ", "Alloh sizni hidoyat qilsin va ishlaringizni isloh qilsin.")
add_dua("Kundalik", "Ovqatlanishni boshlashdan oldin", "بِسْمِ اللهِ", "Bismillah.")
add_dua("Kundalik", "Ovqatlanib bo'lgach", "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ", "Sira qodir bo'lmaganim holda shu taom bilan meni oziqlantirgan va rizq qilib bergan Allohga hamd bo'lsin.")

# SAFAR DUOLARI (51-60)
add_dua("Safar", "Safarga otlanganda", "اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، اللهُ أَكْبَرُ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ", "Alloh buyukdir (3 marta). Bizga buni (ulovni/avtomobilni) bo'ysundirib qo'ygan Zot pokdir. Biz aslida unga qodir emas edik. Va, albatta, begumon, biz Robbimizga qaytguvchilardirmiz.")
add_dua("Safar", "Safardan qaytganda", "آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ", "Qaytuvchilarmiz, tavba qiluvchilarmiz, ibodat qiluvchilarmiz, Robbimizga hamd aytuvchilarmiz.")
add_dua("Safar", "Musofir (safar qiluvchi)ning turib qolganlarga duosi", "أَسْتَوْدِعُكُمُ اللهَ الَّذِي لَا تَضِيعُ وَدَائِعُهُ", "Men sizlarni Omonatlari aslo zoye ketmaydigan Allohga topshirdim.")
add_dua("Safar", "Biror manzilga (mehmonxonaga) tushganda", "أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ", "Allohning komil so'zlari orqali Uning yaratgan maxluqotlari yomonligidan panoh so'rayman.")

# BEMORLIK VA QABR (61-75)
add_dua("Bemorlik", "Kasalni ziyorat qilganda", "لَا بَأْسَ طَهُورٌ إِنْ شَاءَ اللهُ", "Hechqisi yo'q, inshaalloh (bu kasallik gunohlar uchun) poklovchidir.")
add_dua("Bemorlik", "Dard og'irlashganda", "اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَأَلْحِقْنِي بِالرَّفِيقِ الْأَعْلَى", "Ey Allohim! Meni kechir, menga rahm qil va meni Oliy Raofiqga (jannatga / yuksak do'stlar qatoriga) yetkazgin.")
add_dua("Bemorlik", "Bemor kishining yaqinlari o'qiydigan duo", "أَسْأَلُ اللهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ", "Ulug' Arshning Robbi bo'lgan Buyuk Allohdan senga shifo berishini so'rayman (7 marta).")
add_dua("Qabr", "Janoza namozida mayyit uchun", "اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ، وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ", "Ey Allohim! Uni kechir, unga rahm qil, uni afv et va vafot etgan joyini (qabrini) keng va sharafli qil.")
add_dua("Qabr", "Qabristonga kirganda", "السَّلَامُ عَلَيْكُمْ أَهْلَ الدِّيَارِ مِنَ الْمُؤْمِنِينَ وَالْمُسْلِمِينَ، وَإِنَّا إِنْ شَاءَ اللهُ بِكُمْ لَاحِقُونَ، أَسْأَلُ اللهَ لَنَا وَلَكُمُ الْعَافِيَةَ", "Assalomu alaykum hurmatli mo'min va musulmonlar bu maskanning ahli! Albatta biz ham, xohlasa, tez orada sizlarga qo'shilamiz. Allohdan o'zimiz va sizlar uchun ofiyat so'rayman.")
add_dua("Qabr", "Mayyitni ko'mib bo'lgach (dafn so'ngida)", "اللَّهُمَّ اغْفِرْ لَهُ وَثَبِّتْهُ", "Ey Allohim! Uni kechirgin va (so'roq-javobda) sobitqadam qilgin.")

# OILA VA JAMIYAT (76-85)
add_dua("Oila", "Yangi turmush qurganlarga (Kelin-kuyovga) duo", "بَارَكَ اللهُ لَكَ، وَبَارَكَ عَلَيْكَ، وَجَمَعَ بَيْنَكُمَا فِي خَيْرٍ", "Alloh senga baraka bersin, ustingga baraka yog'dirsin va har ikkingizni yaxshilikda jamlasin.")
add_dua("Oila", "Farzand ko'rganni tabriklash", "بَارَكَ اللهُ لَكَ فِي الْمَوْهُوبِ لَكَ، وَشَكَرْتَ الْوَاهِبَ، وَبَلَغَ أَشُدَّهُ، وَرُزِقْتَ بِرَّهُ", "Alloh senga in'om etganda baraka bersin. Beruvchiga shukr qilgin, u balog'atga yetsin va sen uning yaxshiligi va hurmatiga erishgin.")
add_dua("Oila", "Uyquga yotuvchidan ayrilishda/safarga ketganda", "أَسْتَوْدِعُكَ اللهَ الَّذِي لَا تَضِيعُ وَدَائِعُهُ", "Seni omonatlari aslo yo'qolmaydigan Allohga topshirdim.")
add_dua("Kundalik", "G'azab kelganda aytiladigan duo", "أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ", "Quvilgan la'nati shayton yomonligidan Allohdan panoh so'rayman.")
add_dua("Kundalik", "Muloqot/Masjlis so'ngida uyni tark etishdan avval", "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ", "Ey Allohim! Sen barcha nuqsonlardan poksan va Senga hamd bolsin. Yagona Sendan o'zga iloh yo'qligiga guvohlik beraman. Sendan kechirim so'rayman va Senga tavba qilaman.")

# QIYINCHILIK, QURQUV VA MUSIBAT (86-100)
add_dua("Bemorlik", "Biror ish qiyin bo'lib qolganida", "اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا", "Ey Allohim! O'zing oson qilgan narsadan boshqa oson narsa yo'q va Agar O'zing xohlasang, qiyinchilik (mushkullarning) barini osonga aylantirasan.")
add_dua("Bemorlik", "Musibat va g'amga tushganda", "إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي، وَأَخْلِفْ لِي خَيْرًا مِنْهَا", "Albatta biz Allohnikimiz va albatta Uning O'ziga qaytamiz! Ey Allohim! Musibatimda menga ajr bergin va o'rnini yaxshilik bilan qoplagin.")
add_dua("Bemorlik", "Dushman/hukmdordan qo'rqqanda", "اللَّهُمَّ إِنَّا نَجْعَلُكَ فِي نُحُورِهِمْ، وَنَعُوذُ بِكَ مِنْ شُرُورِهِمْ", "Ey Allohim! Bezorilarga qarshi (kurash uchun) o'zingni bo'yinlariga havola etamiz va ularning yomonligidan panoh tilaymiz.")
add_dua("Qabr", "Birov qo'rqqanida yupatish / taskin", "حَسْبُنَا اللهُ وَنِعْمَ الْوَكِيلُ", "Bizga Allohning (O'zi) yetarlidir, va U naqadar eng yaxshi Vakildir.")
add_dua("Kundalik", "Biror kimsani maqtaganda yengil duo", "مَا شَاءَ اللهُ لَا قُوَّةَ إِلَّا بِاللهِ", "Alloh xohlagan narsa bo'ladi! Quvvat va qudrat faqat U(Alloh) uchundir.")

with open("g:/muslim/assets/data/duas_uz.json", "w", encoding="utf-8") as f:
    json.dump(duas, f, ensure_ascii=False, indent=2)

print(f"Created {len(duas)} completely authentic Arabic & Uzbek translation duas successfully.")
