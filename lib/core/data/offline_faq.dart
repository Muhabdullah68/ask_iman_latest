// lib/core/data/offline_faq.dart
//
// Curated, conservative offline Q&A used by Ask Iman AI when Gemini is
// unreachable OR for instant pre-Gemini answers on the fundamentals.
//
// SAFETY: these are general guidance summaries written for a lay audience.
// They never give definitive rulings on disputed masaa'il and every answer
// (in the service, when rendered) is closed with "consult a qualified
// scholar / your local scholar". Procedural entries use numbered steps so the
// chat bubble renders them as an ordered list.

/// One bundled offline Q&A entry.
///
/// [keys] are keyword/alias phrases in any script (English, Roman-Urdu,
/// Urdu, Arabic script, Pashto). Matching is conservative: an entry only
/// answers when either 2+ keys hit, or exactly 1 dominant content word hits.
class OfflineFaqEntry {
  final String id;
  final List<String> keys;
  final Map<String, String> answers; // 'en' | 'ur' | 'ps'

  const OfflineFaqEntry({
    required this.id,
    required this.keys,
    required this.answers,
  });
}

const List<OfflineFaqEntry> offlineFaq = [
  OfflineFaqEntry(
    id: 'wudu',
    keys: [
      'wudu',
      'wudhu',
      'wudoo',
      'ablution',
      'wazu',
      'وضو',
      'وضوء',
      'avu',
      'wuzu',
    ],
    answers: {
      'en':
          'Wudu (ablution) is required for salah and for touching the Mushaf.\n'
          '1. Begin with Bismillah and intend wudu.\n'
          '2. Wash the hands up to the wrists three times.\n'
          '3. Rinse the mouth and nose three times.\n'
          '4. Wash the face three times, from hairline to chin and ear to ear.\n'
          '5. Wash the arms up to the elbows three times, starting with the right.\n'
          '6. Wipe the head once (and the ears).\n'
          '7. Wash the feet up to the ankles three times, starting with the right.\n'
          'Wudu is nullified by natural relief, wind, sleep and other clear causes.',
      'ur':
          'وضو نماز اور قرآن چھونے کے لیے ضروری ہے۔\n'
          '1. بسم اللہ کہہ کر نیت کریں۔\n'
          '2. دونوں ہاتھ کلائیوں تک تین بار دھوئیں۔\n'
          '3. کلی اور ناک میں پانی تین بار ڈالیں۔\n'
          '4. چہرہ بالوں کی جڑ سے ٹھوڑی تک اور کان تک تین بار دھوئیں۔\n'
          '5. دونوں بازو کہنیوں تک تین بار دھوئیں، پہلے دایاں۔\n'
          '6. سر کا مسح ایک بار کریں (اور کانوں کا)۔\n'
          '7. دونوں پاؤں ٹخنوں تک تین بار دھوئیں، پہلے دایاں۔\n'
          'وضو پیشاب، پاخانہ، ہوا خارج ہونے، نیند اور دیگر واضح اسباب سے ٹوٹتا ہے۔',
      'ps':
          'اوداس د لمونځ او د قرآن د لمس لپاره ضروري دی.\n'
          '1. په بسم الله پیل کړئ او نیت وکړئ.\n'
          '2. دواړه لاسونه تر مچ پورې درې ځله ووینځئ.\n'
          '3. خوله او پوزه درې ځله ووینځئ.\n'
          '4. مخ درې ځله د ویښتو له سر تر زنې او تر غوږونو پورې ووینځئ.\n'
          '5. دواړه لاسونه تر څنګلو پورې درې ځله، لومړی ښی، ووینځئ.\n'
          '6. پر سر یو ځل مسح وکړئ (او غوږونه).\n'
          '7. دواړه پښې تر ګیټو پورې درې ځله، لومړی ښی، ووینځئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'ghusl',
    keys: ['ghusl', 'ghusal', 'full bath', 'غسل', 'غصړ'],
    answers: {
      'en':
          'Ghusl (full purification) becomes obligatory after major impurity\n'
          '(janabah, after marriage, after menses/postnatal). It is also Sunnah\n'
          'before Friday and Eid prayers.\n'
          '1. Intend ghusl.\n'
          '2. Wash the private parts.\n'
          '3. Perform wudu (the full ablution).\n'
          '4. Pour water over the whole body three times, starting from the right side.\n'
          '5. Ensure water reaches everywhere, including the hair and skin.',
      'ur':
          'غسل جنابت، جماع، حیض اور نفاس کے بعد فرض ہوتا ہے۔ جمعہ اور عید سے پہلے سنت ہے۔\n'
          '1. غسل کی نیت کریں۔\n'
          '2. شرمگاہ کو دھوئیں۔\n'
          '3. مکمل وضو کریں۔\n'
          '4. پورے جسم پر تین بار پانی بہائیں، پہلے داہنی جانب۔\n'
          '5. پانی ہر جگہ پہنچے، بالوں اور جلد تک۔',
      'ps':
          'غسل د جنابت، د جماع او د حیض/نفاس وروسته فرض دی. د جمعې او اخترو لمونځونو دمخه سنت دی.\n'
          '1. د غسل نیت وکړئ.\n'
          '2. شرمځایونه ووینځئ.\n'
          '3. پوره اوداس وکړئ.\n'
          '4. پر ټول بدن درې ځله اوبه تیر کړئ، لومړی ښی اړخ.\n'
          '5. اوبه هر ځای ته ورسېږي، ویښتان او پوټکی.',
    },
  ),
  OfflineFaqEntry(
    id: 'tayammum',
    keys: ['tayammum', 'tayamum', 'dry ablution', 'تیمم', 'تيمم'],
    answers: {
      'en':
          'Tayammum (dry ablution with clean earth) is a substitute for wudu or '
          'ghusl when water is unavailable, its use would harm you, or you cannot '
          'reach it.\n'
          '1. Intend tayammum.\n'
          '2. Strike clean earth or dust lightly with both palms.\n'
          '3. Wipe the face once with both hands.\n'
          '4. Strike the earth again and wipe the hands up to the wrists.\n'
          'It is lifted as soon as water becomes available or the excuse ends.',
      'ur':
          'تیمم پاک مٹی سے خشک طہارت ہے، جب پانی نہ ملے، پانی نقصان دہ ہو یا پانی تک رسائی ممکن نہ ہو۔\n'
          '1. تیمم کی نیت کریں۔\n'
          '2. دونوں ہتھیلیاں صاف مٹی پر ماریں۔\n'
          '3. دونوں ہاتھوں سے ایک بار چہرے کا مسح کریں۔\n'
          '4. پھر مٹی لیں اور ہاتھوں کا کلائیوں تک مسح کریں۔\n'
          'پانی ملتے ہی یا عذر ختم ہوتے ہی تیمم ختم ہو جاتا ہے۔',
      'ps':
          'تیمم په پاکه خاوره باندې خشک پاکي ده، کله چې اوبه نه وي، اوبه ضررمنې وي او یا اوبو ته لاسرسی نه وي.\n'
          '1. د تیمم نیت وکړئ.\n'
          '2. دواړه ورې خاورې ته ورکړئ.\n'
          '3. د دواړو لاسونو سره یو ځل پر مخ مسح وکړئ.\n'
          '4. بیا خاوره واخلئ او تر مچونو پورې پر دواړو لاسونو مسح وکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'salah_times',
    keys: [
      'salah times',
      'prayer times',
      'namaz times',
      'time of prayer',
      'salah ka waqt',
      'namaz ka waqt',
      'prayer time',
      'salah',
      'salat',
      'prayer',
      'pray',
      'namaz',
      'نماز',
      'صلاة',
      'صلوة',
      'اوقات نماز',
      'نماز کا وقت',
    ],
    answers: {
      'en':
          'The five daily prayers each have a fixed time window:\n'
          '1. Fajr — from dawn until sunrise.\n'
          '2. Dhuhr — after the sun passes its zenith until the shadow of an '
          'object is about double its length.\n'
          '3. Asr — from that point until just before sunset.\n'
          '4. Maghrib — just after sunset.\n'
          '5. Isha — after twilight ends until before dawn.\n'
          'A prayer prayed after its time is generally to be made up (qada), '
          'so aim to pray each salah within its window.',
      'ur':
          'پانچ نمازوں میں سے ہر ایک کا ایک خاص وقت ہے:\n'
          '1. فجر — صبح صادق سے طلوعِ آفتاب تک۔\n'
          '2. ظہر — زوالِ آفتاب کے بعد سے سایہ سورج کے دو برابر ہونے تک۔\n'
          '3. عصر — اس وقت سے غروبِ آفتاب سے کچھ پہلے تک۔\n'
          '4. مغرب — غروبِ آفتاب کے فوراً بعد۔\n'
          '5. عشاء — شفق کے غائب ہونے کے بعد سے صبح سے پہلے تک۔\n'
          'وقت گزرنے کے بعد نماز قضا ہوتی ہے، اس لیے بروقت ادا کرنے کی کوشش کریں۔',
      'ps':
          'پنځه ورځنۍ لمونځونه هر یو خپل وخت لري:\n'
          '1. فجر — له سپیده دم تر لمر ختو پورې.\n'
          '2. ظهر — له غرمې وروسته تر هغه چې سیوری دو چنده شي.\n'
          '3. عصر — له هغه وخت تر لمر لوېدو مخکې.\n'
          '4. مغرب — د لمر له لوېدو سمدستي وروسته.\n'
          '5. عشاء — د شپې له تیارو وروسته تر سبا مخکې.',
    },
  ),
  OfflineFaqEntry(
    id: 'rakats',
    keys: [
      'rakat',
      'rakats',
      'rakat number',
      'how many rakat',
      'rakah',
      'rakah',
      'rakat ka',
      'رکعات',
      'رکعت',
    ],
    answers: {
      'en':
          'Standard numbers of rakat in each prayer (with the Sunnah):\n'
          '1. Fajr — 2 fard (plus 2 sunnah before).\n'
          '2. Dhuhr — 4 fard (plus 4 before and 2 after sunnah).\n'
          '3. Asr — 4 fard.\n'
          '4. Maghrib — 3 fard (plus 2 sunnah after).\n'
          '5. Isha — 4 fard (plus 2 sunnah after).\n'
          'This can vary slightly by opinion; a beginner should pray at least '
          'the fard rakats every day.',
      'ur':
          'ہر نماز کے معروف رکعات (سنن کے ساتھ):\n'
          '1. فجر — 2 فرض (پہلے 2 سنت)۔\n'
          '2. ظہر — 4 فرض (پہلے 4 اور بعد میں 2 سنت)۔\n'
          '3. عصر — 4 فرض۔\n'
          '4. مغرب — 3 فرض (بعد میں 2 سنت)۔\n'
          '5. عشاء — 4 فرض (بعد میں 2 سنت)۔\n'
          'نظر کے اختلاف سے معمولی فرق ممکن ہے؛ کم از کم فرض رکعات ضرور ادا کیجیے۔',
      'ps':
          'د هر لمونځ معروف رکعات (له سنتونو سره):\n'
          '1. فجر — 2 فرض (مخکې 2 سنت).\n'
          '2. ظهر — 4 فرض (مخکې 4 او وروسته 2 سنت).\n'
          '3. عصر — 4 فرض.\n'
          '4. مغرب — 3 فرض (وروسته 2 سنت).\n'
          '5. عشاء — 4 فرض (وروسته 2 سنت).',
    },
  ),
  OfflineFaqEntry(
    id: 'missed_salah',
    keys: [
      'missed salah',
      'missed prayer',
      'missed namaz',
      'miss namaz',
      'missed fajr',
      'missed dhuhr',
      'qada',
      'qaza',
      'catch up prayer',
      'قضای نماز',
      'قضا نماز',
      'فوت شدہ نماز',
    ],
    answers: {
      'en':
          'If a prayer is missed, the general position is to make it up (qada) '
          'as soon as possible, praying it in the same rakat count outside its '
          'time slot. Do not pile up missed prayers out of despair — pray each '
          'fard promptly, make up what you can steadily, and fehel for any '
          'legitimate excuse. A missed prayer is not simply waived.',
      'ur':
          'اگر نماز چھوٹ جائے تو عام موقف یہ ہے کہ جلد از جلد قضا کر لی جائے، اسی رکعات کے ساتھ وقت سے باہر ادا کی جائے۔ مایوس ہو کر مزید نہ چھوڑیں — ہر فرض وقت پر ادا کریں، جو قضا ہو اسے مستقل نیت سے ادا کریں اور جائز عذر پر توبہ کریں۔ نماز صرف چھوڑ دینے سے معاف نہیں ہوتی۔',
      'ps':
          'که لمونځ فوت شوی وي، عمومي نظر دا ده چې ژر تر ژره قضا کړئ، په هماغه شمېر رکعاتو سره له خپل وخت بهر. مایوسي مه کوئ — هر فرض په خپل وخت ادا کړئ، فوت شوي په کراره قضا کړئ او د شرعي عذر لپاره توبه وکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'jummah',
    keys: [
      'jummah',
      'jumuah',
      'jumma',
      'friday prayer',
      'friday salah',
      'جمعہ',
      'جمعة',
      'جمعې',
    ],
    answers: {
      'en':
          'Jumu\'ah (Friday) prayer replaces the Dhuhr for men who attend it.\n'
          '1. Ghusl on Friday is recommended.\n'
          '2. Arrive early.\n'
          '3. The khutbah (sermon) is delivered before the two rakat.\n'
          '4. The congregation prays two rakat for Jumu\'ah.\n'
          'If Jumu\'ah is missed or a woman prays at home, Dhuhr (4 rakat) is '
          'prayed instead.',
      'ur':
          'جمعہ کی نماز مردوں کے لیے ظہر کی جگہ ادا کی جاتی ہے۔\n'
          '1. جمعہ کا غسل مستحب ہے۔\n'
          '2. جلدی آئیں۔\n'
          '3. دو رکعات سے پہلے خطبہ ہوتا ہے۔\n'
          '4. جماعت سے دو رکعت جمعہ ادا کی جاتی ہے۔\n'
          'اگر جمعہ چھوٹ جائے یا عورت گھر پر پڑھے تو چار رکعت ظہر پڑھی جاتی ہے۔',
      'ps':
          'د جمعې لمونځ د نارینه وو لپاره د ظهر پر ځای ادا کیږي.\n'
          '1. د جمعې غسل مستحب دی.\n'
          '2. وختي راشئ.\n'
          '3. د دوو رکعاتو دمخه خطبه ویل کیږي.\n'
          '4. په جماعت سره دوه رکعته جمعې ادا کیږي.',
    },
  ),
  OfflineFaqEntry(
    id: 'taraweeh',
    keys: ['taraweeh', 'tarawih', 'taraveeh', 'تراویح', 'تراويح'],
    answers: {
      'en':
          'Taraweeh are the night prayers of Ramadan prayed after Isha.\n'
          '1. Prayed in congregation or alone after the Isha prayer.\n'
          '2. Commonly prayed in 8 or 20 rakat (opinions differ) in units of 2.\n'
          '3. Witr is prayed at the end, usually 1 or 3 rakat.\n'
          'Any consistent amount is fine; regularity matters more than the length.',
      'ur':
          'تراویح رمضان کی راتوں کی نماز ہے جو عشاء کے بعد پڑھی جاتی ہے۔\n'
          '1. عشاء کی نماز کے بعد جماعت سے یا اکیلے پڑھیں۔\n'
          '2. عام طور پر 8 یا 20 رکعات (اختلاف ہے) دو دو رکعت کر کے پڑھیں۔\n'
          '3. آخر میں وتر پڑھیں، عموماً 1 یا 3 رکعت۔\n'
          'جتنی بھی مستقل مزاجی سے پڑھیں، نیت کی پابندی زیادہ اہم ہے۔',
      'ps':
          'تراویح د رمضان د شپو لمونځ دی چې د عشاء وروسته ادا کیږي.\n'
          '1. د عشاء تر لمونځ وروسته په جماعت یا یوازې.\n'
          '2. معمولا 8 یا 20 رکعته (اختلاف دی) دوه دوه رکعته.\n'
          '3. په پای کې وتر، معمولا 1 یا 3 رکعته.',
    },
  ),
  OfflineFaqEntry(
    id: 'eid_salah',
    keys: [
      'eid salah',
      'eid prayer',
      'eid namaz',
      'عید کی نماز',
      'عید نماز',
      'صلاة العيد',
    ],
    answers: {
      'en':
          'Eid prayer is a congregation prayer with an added khutbah.\n'
          '1. Perform ghusl and wear your best clothes (recommended).\n'
          '2. The Imam leads two rakat with extra takbirat.\n'
          '3. The khutbah follows the prayer.\n'
          'There is no adhan or iqamah for the Eid prayer.',
      'ur':
          'عید کی نماز جماعت کے ساتھ ہوتی ہے اور اس کے بعد خطبہ ہوتا ہے۔\n'
          '1. غسل کریں اور اچھے کپڑے پہنیں (مستحب)۔\n'
          '2. امام دو رکعت اضافی تکبیروں کے ساتھ پڑھاتا ہے۔\n'
          '3. خطبہ نماز کے بعد ہوتا ہے۔\n'
          'عید کی نماز کے لیے اذان یا اقامت نہیں ہے۔',
      'ps':
          'د اختر لمونځ په جماعت ادا کیږي او وروسته یې خطبه کیږي.\n'
          '1. غسل وکړئ او ښه جامې واغوندئ (مستحب).\n'
          '2. امام دوه رکعته د اضافي تکبیرو سره ادا کوي.\n'
          '3. خطبه د لمونځ وروسته ده.',
    },
  ),
  OfflineFaqEntry(
    id: 'zakat',
    keys: ['zakat', 'zakah', 'zakaat', 'زکاۃ', 'زكاة', 'زکات', 'زکوٰة'],
    answers: {
      'en':
          'Zakat is an obligatory yearly charity on wealth above the nisab.\n'
          '1. Due once a year (a lunar cycle) on savings beyond your basic needs.\n'
          '2. Nisab is commonly set against the value of 85g of gold (or 595g of silver).\n'
          '3. The rate is 2.5% of the qualifying wealth for cash, gold and trade goods.\n'
          '4. Pay it to the eligible recipients (the poor, needy, debtors, travellers, etc.).\n'
          'If you are unsure whether your wealth reached nisab, ask a reliable '
          'scholar — it is better to ask than to guess.',
      'ur':
          'زکوٰۃ نصاب سے اوپر والے مال پر ہر سال فرض صدقہ ہے۔\n'
          '1. بنیادی ضروریات سے زائد بچت پر سال میں ایک بار۔\n'
          '2. نصاب عموماً ساڑھے باون تولہ چاندی یا ساڑھے سات تولہ سونے کی قیمت کے برابر ہے۔\n'
          '3. نقدی، سونا چاندی اور مال تجارت پر شرح 2.5 فیصد ہے۔\n'
          '4. مستحقین (فقراء، مساکین، مقروض، مسافر وغیرہ) کو دیں۔\n'
          'اگر نصاب پورا کرنے کے بارے میں شک ہو تو کسی قابلِ اعتماد عالم سے پوچھیں۔',
      'ps':
          'زکات د نصاب څخه زیاتې شتمنۍ پر کال یو ځل فرض صدقه ده.\n'
          '1. د اساسي اړتیاوو څخه اضافي پیسو پر کال یو ځل.\n'
          '2. نصاب معمولا د ۸۵ گرامو سرو زرو (یا ۵۹۵ گرامو نقرو) ارزښت دی.\n'
          '3. نغده، سره زر او سوداګري 2.5٪.\n'
          '4. مستحقینو ته یې ورکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'zakat_recipients',
    keys: [
      'zakat recipients',
      'who can take zakat',
      'zakat mustahiq',
      'zakat ko kis ko',
      'مصارف زکاة',
      'زکوٰۃ کے مستحق',
    ],
    answers: {
      'en':
          'The Quran lists eight categories of zakat recipients (9:60): the poor, '
          'the needy, those employed to collect it, those whose hearts are to be '
          'reconciled, freeing captives/slaves, the heavily indebted, those '
          'striving in Allah\'s cause, and the stranded traveller. Immediate '
          'family (whom you are obliged to support) and those above the nisab '
          'are not given zakat.',
      'ur':
          'قرآن (سورہ توبہ 9:60) میں زکوٰۃ کے آٹھ مصارف بتائے گئے ہیں: فقراء، مساکین، زکوٰۃ کے عامل، تالیفِ قلب والے، غلاموں کی آزادی، مقروض، اللہ کی راہ میں جہاد کرنے والے، اور مسافر۔ جن لوگوں کا نان و نفقہ آپ پر واجب ہے اور جو نصاب سے اوپر ہیں انہیں زکوٰۃ نہیں دی جاتی۔',
      'ps':
          'قرآن (۹:۶۰) د زکات اته ډولونه بیان کړي دي: فقرا، مساکین، د زکات عاملین، د زړه له میلانه، د غلامانو ازادي، پوروړي، د الله په لاره کې او ستړی مسافر.',
    },
  ),
  OfflineFaqEntry(
    id: 'fasting',
    keys: [
      'fasting',
      'fast',
      'sawm',
      'roza',
      'ramadan fast',
      'siyam',
      'روزہ',
      'روزه',
      'صوم',
      'صيام',
      'روژه',
    ],
    answers: {
      'en':
          'Fasting (sawm) in Ramadan is obligatory for every sane, mature Muslim '
          'who is able.\n'
          '1. Intend to fast, ideally before dawn.\n'
          '2. Refrain from eating, drinking and marital relations from dawn to sunset.\n'
          '3. Suhur (pre-dawn meal) and iftar are recommended.\n'
          '4. The sick, travellers, pregnant/nursing mothers and those with a '
          'valid excuse may break the fast and make it up (or feed the poor where '
          'the excuse is permanent).',
      'ur':
          'رمضان کا روزہ ہر عاقل، بالغ اور تندرست مسلمان پر فرض ہے۔\n'
          '1. فجر سے پہلے نیت کریں۔\n'
          '2. طلوعِ فجر سے غروبِ آفتاب تک کھانے پینے اور مباشرت سے رکیں۔\n'
          '3. سحری اور افطار مستحب ہیں۔\n'
          '4. بیمار، مسافر، حاملہ/دودھ پلانے والی مائیں اور عنوان والے روزہ نہ چھوڑیں — قضا کریں، عارضِ دائمی ہو تو فدیہ دیں۔',
      'ps':
          'د رمضان روژه د هر عاقل، بالغ او صحتمند مسلمان لپاره فرض ده.\n'
          '1. د سبا دمخه نیت وکړئ.\n'
          '2. له سپیده دم تر لمر لوېدو پورې له خوراک، څښاک او له مېرمنې سره له اړیکې ډډه وکړئ.\n'
          '3. سحري او افطار مستحب دي.\n'
          '4. ناروغ، مسافر، امیندواره او شیدې ورکوونکې ښځې کولی شي روژه پرېږدي او قضا یې کړي.',
    },
  ),
  OfflineFaqEntry(
    id: 'iftar',
    keys: ['iftar', 'breaking fast', 'iftari', 'افطار', 'افطار'],
    answers: {
      'en':
          'Iftar is the meal that breaks the fast at sunset. It is Sunnah to '
          'hasten to break the fast at Maghrib time — with dates if possible, '
          'otherwise water. Eat moderately, make dua before breaking the fast, '
          'and remember that the fast was already valid for the day.',
      'ur':
          'افطار غروبِ آفتاب پر روزہ کھولنے کا وقت ہے۔ سنت یہ ہے کہ مغرب کے وقت جلدی افطار کیا جائے — کھجور سے ممکن ہو تو، ورنہ پانی سے۔ میانہ روی سے کھائیں، افطار سے پہلے دعا کریں، اور یاد رکھیں دن کا روزہ ویسے ہی مکمل ہو چکا تھا۔',
      'ps':
          'افطار د لمر لوېدو وخت دی چې روژه پرې ماتیږي. سنت دا ده چې په وخت افطار وشي — که ممکن وي له خرما، که نه له اوبو. په اعتدال وخورئ، د افطار دمخه دعا وکړئ او په یاد ولرئ چې ورځنی روژه په هر حال صحي ده.',
    },
  ),
  OfflineFaqEntry(
    id: 'kaffarah',
    keys: ['kaffarah', 'kaffara', 'expiation', 'کفارہ', 'كفارة', 'kafara'],
    answers: {
      'en':
          'Kaffarah (expiation) applies to specific violations, most commonly an '
          'intentionally broken Ramadan fast through eating, drinking or marital '
          'relations — fast 60 consecutive days, or feed 60 poor people if you '
          'cannot. Deliberately missing fasts without an excuse requires both '
          'making them up (qada) and repentance. Ask a scholar about your exact '
          'situation before acting.',
      'ur':
          'کفارہ مخصوص گناہوں پر ہے، سب سے عام رمضان کا روزہ جان بوجھ کر (کھانے، پینے یا مباشرت سے) توڑنا — پے در پے 60 روزے رکھیں، یا نہ رکھ سکیں تو 60 مسکینوں کو کھانا کھلائیں۔ بغیر عذر کے چھوڑے گئے روزے قضا کرنا اور توبہ کرنا دونوں ضروری ہیں۔ اپنی صورت حال پر عمل سے پہلے کسی عالم سے پوچھیں۔',
      'ps':
          'کفاره ځانګړو سرغړونو ته لازم دی، تر ټولو عام د رمضان روژه په عمد ډول ماتول — ۶۰ پرله پسې روژې ونیسئ، که نشي کولای نو ۶۰ مسکینانو ته خواړه ورکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'hajj',
    keys: ['hajj', 'haj', 'pilgrimage', 'حج'],
    answers: {
      'en':
          'Hajj is the fifth pillar, obligatory once in a lifetime for every '
          'Muslim who physically and financially can make the journey.\n'
          '1. Enter ihram with the intention near Makkah (or on the journey).\n'
          '2. Perform tawaf around the Kaaba.\n'
          '3. Perform the sai between Safa and Marwah.\n'
          '4. Stand at Arafat on the 9th of Dhul-Hijjah (the key act).\n'
          '5. Complete the remaining rites (Muzdalifah, stoning, sacrifice, '
          'shaving, final tawaf).\n'
          'A wrong or missed step can usually be repaired; ask your guide or a '
          'scholar during the pilgrimage.',
      'ur':
          'حج اسلام کا پانچواں رکن ہے، ہر صاحبِ استطاعت مسلمان (جسمانی اور مالی) پر عمر میں ایک بار فرض ہے۔\n'
          '1. مکہ یا راستے میں نیت اور احرام باندھیں۔\n'
          '2. کعبہ کا طواف کریں۔\n'
          '3. صفا و مروہ کے درمیان سعی کریں۔\n'
          '4. نویں ذوالحجہ کو عرفات میں وقوف (سب سے اہم عمل)۔\n'
          '5. بقیہ مناسک مکمل کریں — مزدلفہ، رمی، قربانی، حجامت اور طوافِ وداع۔\n'
          'چھوٹی غلطی عام طور پر درست کی جا سکتی ہے؛ حج کے دوران اپنے رہنما یا عالم سے پوچھیں۔',
      'ps':
          'حج د اسلام پنځم رکن دی، هر ډول وس لرونکي مسلمان باندې په ژوند کې یو ځل فرض دی.\n'
          '1. د نیت او احرام سره.\n'
          '2. د کعبې طواف.\n'
          '3. د صفا او مروه تر منځ سعي.\n'
          '4. د نهم ذوالحجه په ورځ د عرفات وقوف (تر ټولو مهم عمل).\n'
          '5. پاتې مناسک — مزدلفه، رمي، قرباني او طواف.',
    },
  ),
  OfflineFaqEntry(
    id: 'umrah',
    keys: ['umrah', 'umra', 'عمرہ', 'عمرة'],
    answers: {
      'en':
          'Umrah is the lesser pilgrimage, recommended and can be performed any '
          'time of the year.\n'
          '1. Enter ihram with the intention.\n'
          '2. Perform tawaf (7 circuits around the Kaaba).\n'
          '3. Perform sai between Safa and Marwah (7 runs).\n'
          '4. Shave or shorten the hair after completing these.',
      'ur':
          'عمرہ چھوٹی زیارت ہے، مستحب ہے اور سال کے کسی بھی وقت ادا کی جا سکتی ہے۔\n'
          '1. نیت سے احرام باندھیں۔\n'
          '2. کعبہ کے سات چکر لگائیں (طواف)۔\n'
          '3. صفا و مروہ کے درمیان سات مرتبہ سعی کریں۔\n'
          '4. ان اعمال کے بعد سر منڈوائیں یا بال چھوٹے کریں۔',
      'ps':
          'عمره کوچنی زیارت ده، مستحبه ده او د کال په هر وخت کې کیدی شي.\n'
          '1. د نیت سره احرام.\n'
          '2. طواف (د کعبې اوه ګرځېدنه).\n'
          '3. د صفا او مروه تر منځ اووه ځل سعي.\n'
          '4. ویښتان کمول یا ږیرل.',
    },
  ),
  OfflineFaqEntry(
    id: 'janazah',
    keys: [
      'janazah',
      'jenazah',
      'funeral',
      'janaza',
      'burial',
      'جنازہ',
      'جنازة',
      'جنازه',
    ],
    answers: {
      'en':
          'The funeral prayer (salat al-janazah) is a collective obligation.\n'
          '1. The deceased is washed, shrouded and the body laid before the congregation.\n'
          '2. The imam stands and the congregation prays: four takbirat with '
          'recitations between them, then the salam.\n'
          '3. After the prayer the body is buried in the graveyard, on its side '
          'facing the qiblah.\n'
          'Duas for the deceased are made throughout; this is one of the greatest '
          'favors you can do for a believer.',
      'ur':
          'نمازِ جنازہ فرضِ کفایہ ہے۔\n'
          '1. میت کو غسل دیا جاتا ہے، کفن پہنایا جاتا ہے اور جماعت کے سامنے رکھا جاتا ہے۔\n'
          '2. امام کھڑا ہوتا ہے اور جماعت چار تکبیروں کے ساتھ نماز پڑھتی ہے، پھر سلام۔\n'
          '3. نماز کے بعد میت کو قبرستان میں دفن کیا جاتا ہے، قبلہ رخ کروٹ پر۔\n'
          'ہر مرحلے پر میت کے لیے دعا کی جائے — یہ مومن کے لیے بہت بڑا احسان ہے۔',
      'ps':
          'د جنازې لمونځ فرض کفایه دی.\n'
          '1. میته ومینځل کیږي، کفن ورکول کیږي او مخکې ډنډه کیږي.\n'
          '2. امام د څلورو تکبیرو سره لمونځ ادا کوي، بیا سلام.\n'
          '3. د لمونځ وروسته میته د قبلې په لور په څنګ تدفین کیږي.',
    },
  ),
  OfflineFaqEntry(
    id: 'nikah',
    keys: [
      'nikah',
      'nikha',
      'marriage',
      'nikkah',
      'shaadi',
      'نکاح',
      'نكاح',
      'نکاح',
    ],
    answers: {
      'en':
          'In Islam, marriage (nikah) needs a valid contract.\n'
          '1. Both parties give consent (the woman\'s consent is required).\n'
          '2. A guardian acts for the bride.\n'
          '3. The mahr (dowry) is agreed and given to the wife.\n'
          '4. Two just witnesses are present.\n'
          'Marriage is strongly encouraged in the Quran and Sunnah; it halves '
          'worldly concerns and is a means of chastity.',
      'ur':
          'اسلام میں نکاح کے لیے درست عقد ضروری ہے۔\n'
          '1. دونوں فریقین کی رضامندی (لڑکی کی رضامندی ضروری ہے)۔\n'
          '2. دلہن کا ولی موجود ہو۔\n'
          '3. مہر طے ہو اور بیوی کو دیا جائے۔\n'
          '4. دو معتبر گواہ موجود ہوں۔\n'
          'قرآن و سنت میں شادی کا بہت زیادہ حکم دیا گیا ہے؛ یہ عفت کا ذریعہ ہے۔',
      'ps':
          'په اسلام کې وداح/نکاح لپاره صحیح عقد ضروري دی.\n'
          '1. د دواړو خواوو رضایت (د نجلۍ رضایت اړین دی).\n'
          '2. د نجلۍ ولي موجود وي.\n'
          '3. مهر ټاکل کیږي او ښځې ته ورکول کیږي.\n'
          '4. دوه معتبر ګواهان موجود وي.',
    },
  ),
  OfflineFaqEntry(
    id: 'mahr',
    keys: ['mahr', 'mehr', 'dowry', 'jahez', 'مہر', 'مهريه', 'جہیز'],
    answers: {
      'en':
          'Mahr is the bridal gift that the husband gives the wife as part of '
          'the marriage contract. It is her personal wealth — she may keep it, '
          'spend it or give it away as she wishes. It may be cash, property or '
          'anything of value, paid now or deferred by agreement. A small but '
          'sincere mahr is recommended in the Sunnah.',
      'ur':
          'مہر وہ ہدیہ ہے جو شوہر عقدِ نکاح میں بیوی کو دیتا ہے۔ یہ بیوی کا ذاتی مال ہے — وہ اسے رکھ سکتی ہے، خرچ کر سکتی ہے یا جیسے چاہے صدقہ کر سکتی ہے۔ نقد، جائیداد یا کوئی بھی قیمتی چیز ہو سکتی ہے، اتفاق سے فوراً یا ادھار۔ سنت میں ہلکا مگر خلوص سے ادا کیا گیا مہر پسندیدہ ہے۔',
      'ps':
          'مهر هغه ډالۍ ده چې میړه یې د نکاح په عقد کې ښځې ته ورکوي. دا د ښځې شخصي مال دی — هغه یې ساتلی شي، لګولی شي او یا ورکړای شي.',
    },
  ),
  OfflineFaqEntry(
    id: 'talaq',
    keys: ['talaq', 'talaaq', 'divorce', 'khula', 'طلاق', 'طلاق'],
    answers: {
      'en':
          'Divorce in Islam is a serious last resort, permitted only when the '
          'marriage cannot be saved. It is done with the pronouncement in a '
          'controlled, lawful way; there is an appointed waiting period (iddah) '
          'during which reconciliation is encouraged. Khula (divorce initiated '
          'by the wife for valid reasons) is also recognized. Because divorce '
          'rules are detailed and situation-specific, always consult a qualified '
          'scholar or Islamic court before acting.',
      'ur':
          'اسلام میں طلاق آخری حل ہے، صرف اس وقت جب نکاح کو بچانا ممکن نہ ہو۔ طلاق مقررہ شرعی طریقے سے دی جاتی ہے؛ عدت کے دوران صلح کی حوصلہ افزائی ہوتی ہے۔ خلع (بیوی کی طرف سے جائز وجہ سے طلاق) بھی تسلیم شدہ ہے۔ چونکہ احکام تفصیلی اور صورت حال کے مطابق ہوتے ہیں، عمل سے پہلے کسی مستند عالم یا شرعی عدالت سے مشورہ ضرور کریں۔',
      'ps':
          'طلاق په اسلام کې سخت وروستی حل دی. دا د شرعي طریقت سره ویل کیږي؛ د عدت موده وي چې په هغه کې د صولح هڅه کیږي. ځکه چې تفصیلات ډېر وي، له عمل دمخه له یوه عالم څخه پوښتنه وکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'hijab',
    keys: [
      'hijab',
      'niqab',
      'jilbab',
      'khimar',
      'purdah',
      'حجاب',
      'نقاب',
      'پردہ',
      'پردي',
    ],
    answers: {
      'en':
          'Hijab (modest dress) is commanded for believing women in the Quran '
          '(24:31; 33:59): to cover the body and adornment before those outside '
          'the defined circle of family. Scholars differ on the extent (headscarf '
          'vs. face covering), so follow the respected opinion of the scholars '
          'you trust. Wearing it is greatly rewarded and is a visible act of '
          'faith, not a burden.',
      'ur':
          'عورت کا حجاب قرآن (24:31 اور 33:59) میں حکم دیا گیا ہے: نامحرم لوگوں کے سامنے جسم اور زینت کو ڈھکنا۔ علماء کا اس کی مقدار (سر پر دوپٹہ سے لے کر نقاب تک) میں اختلاف ہے، اس لیے اپنے معتمد علماء کی رائے پر عمل کریں۔ حجاب ایمان کا ظاہری عمل اور بہت اجر کا ذریعہ ہے۔',
      'ps':
          'د ښځې حجاب په قرآن (۲۴:۳۱؛ ۳۳:۵۹) کې امر شوی دی: د غیر محارم په وړاندې د بدن او ښکل او سینګار پټول. د عالمینو نظر فرق لري، نو د خپل باوري عالم نظر تعقیب کړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'riba',
    keys: ['riba', 'interest', 'usury', 'interest rate', 'سود', 'ربا', 'ربو'],
    answers: {
      'en':
          'Riba (interest/usury) is clearly forbidden in the Quran (2:275-279) '
          'and hadith. Earning, paying or facilitating interest is a grave sin; '
          'the hadith curse those who eat, give, write or witness it. Lending '
          'for the sake of Allah (qard hasan) is encouraged instead. If you '
          'already hold interest-based accounts, ask a scholar for a practical '
          'way to purify and exit them.',
      'ur':
          'ربا (سود) قرآن (2:275-279) اور حدیث میں صریحاً حرام ہے۔ سود کھانا، دینا، لکھنا یا گواہ بننا سب پر لعنت آئی ہے۔ اس کے بجائے قرضِ حسن کی حوصلہ افزائی ہے۔ اگر آپ کے سود والے اکاؤنٹ ہیں تو پاک صاف کرنے کا عملی طریقہ کسی عالم سے پوچھیں۔',
      'ps':
          'سود/ربا په قرآن (۲:۲۷۵-۲۷۹) او حدیث کې په څرګند ډول حرام دی. د سود خوړل، ورکول، لیکل یا ګواهي منع دي.',
    },
  ),
  OfflineFaqEntry(
    id: 'alcohol',
    keys: ['alcohol', 'wine', 'khamr', 'liquor', 'beer', 'شراب', 'خمر', 'شراب'],
    answers: {
      'en':
          'Alcohol (khamr) is explicitly forbidden in the Quran (5:90). The '
          'prohibition covers all intoxicants in any amount — even a drop that '
          'can intoxicate, and being present where it is consumed is to be '
          'avoided. Intention and quantity do not change the rule; if a person '
          'falls into it, sincere repentance (tawbah) is the door back.',
      'ur':
          'شراب قرآن (5:90) میں صریحاً حرام ہے۔ یہ حکم ہر نشہ آور چیز پر ہے، خواہ ایک قطرہ ہی ہو؛ نیز مجلس شراب میں بیٹھنے سے بھی بچنا چاہیے۔ نیت اور مقدار سے حکم نہیں بدلتا؛ اگر کوئی اس میں مبتلا ہو جائے تو خلوصِ نیت سے توبہ واپس جانے کا دروازہ ہے۔',
      'ps':
          'شراب/الکول په قرآن (۵:۹۰) کې په ښکاره ډول حرام دی. دا حکم هر ډول نشه يي توکي پوري اړه لري، حتی یو څاڅکی. که څوک پرې اخته شي، رښتینې توبه لاره ده.',
    },
  ),
  OfflineFaqEntry(
    id: 'pork',
    keys: ['pork', 'pig', 'swine', 'خنزیر', 'سور کا گوشت', 'سور'],
    answers: {
      'en':
          'Pork and its products are explicitly forbidden in the Quran '
          '(2:173; 5:3; 6:145). A Muslim must avoid it altogether — whether in '
          'food, gelatine or products clearly derived from it. If a Muslim '
          'consumes it unknowingly or by mistake, there is no sin and no penalty; '
          'if knowingly, sincere repentance is required.',
      'ur':
          'سور کا گوشت اور اس سے بنی مصنوعات قرآن (2:173؛ 5:3؛ 6:145) میں صریحاً حرام ہیں۔ مسلمان کو اس سے مکمل اجتناب کرنا چاہیے — کھانے، جیلیٹن یا اس سے حاصل مصنوعات میں۔ اگر بھولے سے یا غلطی سے کھا لیا تو گناہ نہیں؛ جان بوجھ کر کھایا تو خلوص سے توبہ ضروری ہے۔',
      'ps':
          'د خنزیر غوښه او محصولات په قرآن (۲:۱۷۳؛ ۵:۳؛ ۶:۱۴۵) کې په څرګند ډول حرام دي. مسلمان باید ترې په بشپړ ډول ډډه وکړي.',
    },
  ),
  OfflineFaqEntry(
    id: 'music',
    keys: [
      'music',
      'singing',
      'songs',
      'song',
      'instrument',
      'گیت',
      'گانا',
      'موسیقی',
      'غنا',
      'موسيقي',
    ],
    answers: {
      'en':
          'The Quran does not mention music by name, and the scholars have '
          'differed on it: some hold musical instruments impermissible, others '
          'permit their use with conditions and disallow obscene or time-wasting '
          'content. In all views, music that promotes immorality is a sin and '
          'singing that moves the heart toward Allah (like nasheed without '
          'instruments) is acceptable. Follow the careful opinion and avoid the '
          'doubtful.',
      'ur':
          'قرآن میں موسیقی کا نام نہیں ہے اور علماء کا اختلاف ہے: کچھ آلاتِ موسیقی کو حرام کہتے ہیں، کچھ شرائط کے ساتھ جائز اور بے حیائی یا وقت ضائع کرنے والی چیز کو ناپسند کہتے ہیں۔ سب کے ہاں بے حیائی پر ابھارنے والی موسیقی گناہ ہے، اور اللہ کی یاد دلانے والا کلام (جیسے بغیر آلات کا نشید) جائز ہے۔ محتاط رائے پر عمل کریں اور شک والی چیز سے بچیں۔',
      'ps':
          'په قرآن کې د موسیقۍ نوم نه دی راغلی، عالمان یې سره اختلاف لري. د بې حیایۍ موسیقي حرامه ده او هغه څه چې د الله یاد ته بلنه کوي ښه دی. له شکمنو څیزونو ډډه وکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'gold_silk',
    keys: ['gold', 'silk', 'gold ring', 'سونا', 'ریشم', 'سره زر', 'شیدا'],
    answers: {
      'en':
          'It is well established that wearing gold and pure silk is forbidden '
          'for men (while permissible for women). This is reported in authentic '
          'hadith. A man should avoid gold jewellery and silk garments; modern '
          'gold-plated items should be checked with a scholar where unclear.',
      'ur':
          'معروف احادیث کے مطابق سونا اور خالص ریشم پہننا مردوں کے لیے حرام ہے (عورتوں کے لیے جائز ہے)۔ مرد کو سونے کے زیورات اور ریشم کے کپڑوں سے بچنا چاہیے؛ مبہم صورتیں (جیسے سونے کی پالش والی چیزیں) کسی عالم سے پوچھیں۔',
      'ps':
          'د سرو زرو د ګاڼو او خالص شیدا اغوستل د نارینه وو لپاره حرام دي (ښځو ته روا دي).',
    },
  ),
  OfflineFaqEntry(
    id: 'tattoos',
    keys: ['tattoo', 'tattoos', 'tatto', 'ٹیٹو', 'داغ', 'جسم پر نقش'],
    answers: {
      'en':
          'Permanent tattoos and changing Allah\'s creation in that way are '
          'considered impermissible by the major schools, based on authentic '
          'hadith that curse those who tattoo and are tattooed. For existing '
          'tattoos: they are not an obstacle to worship, they do not invalidate '
          'prayer, and sincere repentance is what matters. Removing them is not '
          'obligatory where it would cause harm or great difficulty.',
      'ur':
          'مستقل ٹیٹو اور اس طرح اللہ کی صورت بدلنا بڑے مکاتبِ فقہ کے نزدیک ناجائز ہے؛ حدیث میں ٹیٹو بنوانے والوں پر لعنت آئی ہے۔ اگر پہلے سے ٹیٹو ہو تو وہ عبادت میں رکاوٹ نہیں، نماز باطل نہیں کرتا، اور خلوص سے توبہ اہم ہے۔ اگر ہٹانے میں نقصان یا شدید مشقت ہو تو ہٹانا واجب نہیں۔',
      'ps':
          'دايمي ټاټو او په داسې ډول د الله د مخلوق بڼه بدلول ناجايز ګڼل کیږي. که مخکې وي، توبه مهمه ده او لمونځ باطل نه کوي.',
    },
  ),
  OfflineFaqEntry(
    id: 'dreams',
    keys: ['dream', 'dreams', 'khwab', 'khuwab', 'sleep', 'خواب', 'خواب'],
    answers: {
      'en':
          'Dreams are of three kinds in the hadith: true dreams (a glad tiding '
          'from Allah), dreams from the self, and dreams from Shaytan. Only '
          'trustworthy dreams have spiritual weight. If a good dream comes, thank '
          'Allah and share it with someone you love; if a bad dream comes, seek '
          'refuge in Allah from its evil, spit three times to the left, do not '
          'tell others about it, and it will not harm with Allah\'s permission. Do '
          'not act on unverified interpretations.',
      'ur':
          'حدیث کے مطابق خواب تین قسم کے ہیں: نیک خواب (اللہ کی طرف سے بشارت)، نفس کے خیالات اور شیطان کی طرف سے۔ اچھا خواب آئے تو اللہ کا شکر ادا کریں اور اپنے محبوب سے بیان کریں؛ برا خواب آئے تو اللہ کی پناہ مانگیں، بائیں طرف تین بار تھوکیں، کسی کو نہ بتائیں، تو اللہ کے حکم سے وہ نقصان نہیں دے گا۔ بے سند تعبیر پر عمل نہ کریں۔',
      'ps':
          'خوب له درې ډوله دي: ښه خوب (د الله بشارت)، د نفس خیال او د شیطان. ښه خوب ته د الله شکر وکړئ؛ بد خوب ته د الله پناه وغواړئ او هېڅوک ته یې مه وایئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'evil_eye',
    keys: [
      'evil eye',
      'nazar',
      'nazr',
      'aye nazar',
      'عين',
      'نظر',
      'چشم',
      'باد نظر',
    ],
    answers: {
      'en':
          'The evil eye (al-ayn) is real and mentioned in the Quran and hadith. '
          'Protection is by the remembrance of Allah, reciting the Mu\'awwidhatayn '
          '(Surah al-Falaq and an-Nas), and saying "Barak Allahu fik" (may Allah '
          'bless you) when seeing something you admire. For someone affected, '
          'ruqya (Quranic supplication) and good duas are the scriptural remedy; '
          'seek help from a person of knowledge.',
      'ur':
          'نظرِ بد (العین) قرآن اور حدیث میں ثابت ہے۔ حفاظت اللہ کے ذکر، معوذتین (سورہ فلق اور ناس) کی تلاوت اور کسی چیز کی تعریف کرتے وقت "بارک اللہ فیک" کہنے سے ہے۔ متاثرہ کے لیے رقیہ (قرآنی دعائیں) سنت علاج ہے؛ اہل علم سے مدد لیں۔',
      'ps':
          'د بد نظر (العین) رښتینې ده، په قرآن او حدیث کې راغلې. د الله د ذکر، معوذتینو او دعا په ذریعه حفاظت کیږي.',
    },
  ),
  OfflineFaqEntry(
    id: 'jinn',
    keys: ['jinn', 'jin', 'جن', 'جني'],
    answers: {
      'en':
          'Believing in the jinn is part of Islamic faith — they are beings '
          'created from smokeless fire, invisible to us, accountable like humans, '
          'and some are righteous and some wicked. Most strange experiences have '
          'ordinary explanations; recourse for real harm is the Quran, the '
          'Mu\'awwidhatayn, and good duas. Beware of fortune-tellers and "jinn '
          'experts" who mix truth with deception.',
      'ur':
          'جن پر ایمان اسلام کا حصہ ہے — وہ بے دھوئیں کی آگ سے بنائے گئے مخلوق ہیں، ہمیں دکھائی نہیں دیتے، انسانوں کی طرح مکلف ہیں، نیک اور بد دونوں ہیں۔ زیادہ تر عجیب تجربات کی عام وجوہات ہوتی ہیں؛ حقیقی نقصان کا علاج قرآن، معوذتین اور بہترین دعائیں ہیں۔ نجومیوں اور بے سند "جن ماہروں" سے بچیں۔',
      'ps':
          'پر جنيانو ایمان د اسلام برخه ده. زیاتره عجیبه تجربې عادي لاملونه لري؛ اصلي درمل قرآن او دعا ده. له فالتو خلکو څخه ډډه وکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'dua',
    keys: ['dua', 'duas', 'duaa', 'supplication', 'دعا', 'دعا'],
    answers: {
      'en':
          'Dua (supplication) is a form of worship that connects you to Allah. '
          'Ways to make it more accepted: call on Allah by His Names, be sincere, '
          'begin and end with praise, send salawat upon the Prophet ﷺ, make dua '
          'in sujood and at the end of salah, and remain hopeful — not impatient. '
          'Dua is never wasted: it is answered, deferred, or a trial is turned '
          'away by it.',
      'ur':
          'دعا ایک عبادت ہے جو اللہ سے تعلق جوڑتی ہے۔ قبولیت کے آداب: اللہ کے ناموں سے پکارنا، اخلاص، شروع اور آخر میں حمد و ثنا، درودِ شریف، سجدے میں اور نماز کے آخر میں دعا کرنا، اور بے صبری نہ کرنا۔ دعا کبھی رائیگاں نہیں — وہ قبول، مؤخر یا کسی مصیبت کو ٹالنے کا ذریعہ ہوتی ہے۔',
      'ps':
          'دعا عبادت ده چې له الله سره اړیکه جوړوي. له الله په نومونو یې وغواړئ، په اخلاص، او په سجده کې یې وکړئ.',
    },
  ),
  OfflineFaqEntry(
    id: 'dhikr',
    keys: ['dhikr', 'zikr', 'azkar', 'remembrance', 'tasbeeh', 'ذکر', 'اذکار'],
    answers: {
      'en':
          'Dhikr (remembering Allah) is among the best acts of worship — the '
          'Quran tells us the hearts find rest in the remembrance of Allah '
          '(13:28). Simple dhikr has great reward: "SubhanAllah walhamdulillah, '
          'wa la ilaha illallah wallahu akbar" — plus istighfar and morning/evening '
          'adhkar. Consistency in a little is better than a lot done rarely.',
      'ur':
          'ذکر اللہ افضل عبادات میں سے ہے — قرآن کہتا ہے دل اللہ کے ذکر سے اطمینان پاتے ہیں (13:28)۔ سادہ ذکر بہت اجر رکھتا ہے: "سبحان اللہ والحمدللہ ولا الہ الا اللہ واللہ اکبر"۔ استغفار اور صبح/شام کے اذکار بھی۔ کبھی کبھار زیادہ سے کم پر عمل پائیدار بہتر ہے۔',
      'ps':
          'ذکر د الله له غوره عبادتونو څخه دی. ساده ذکرونه لکه سبحان الله، الحمدالله او استغفار ډېر اجر لري.',
    },
  ),
  OfflineFaqEntry(
    id: 'repentance',
    keys: [
      'tawbah',
      'taubah',
      'repent',
      'repentance',
      'istighfar',
      'forgive me',
      'توبہ',
      'توبة',
      'استغفار',
    ],
    answers: {
      'en':
          'Tawbah (repentance) is the door Allah always leaves open. Its three '
          'conditions: stop the sin, feel sincere regret, and resolve not to '
          'return to it (plus return any rights taken from others). Do not delay '
          'or despair — Allah loves those who repent (2:222). For sins against '
          'Allah, repentance alone suffices; for sins against people, the rights '
          'must also be restored or forgiven.',
      'ur':
          'توبہ وہ دروازہ ہے جو اللہ ہمیشہ کھلا رکھتا ہے۔ اس کی تین شرطیں: گناہ چھوڑنا، دل سے پشیمان ہونا، اور اس پر نہ لوٹنے کا پختہ ارادہ (ساتھ ہی لوگوں کا حق واپس کرنا)۔ اللہ توبہ کرنے والوں سے محبت کرتا ہے (2:222)۔ اللہ کے حقوق کے لیے توبہ کافی ہے؛ بندوں کے حقوق کی واپسی بھی ضروری ہے۔',
      'ps':
          'توبه هغه دروازه ده چې الله یې تل پرانیسته ساتي. شرطونه یې: له ګناه لاس اخيستل، پښېماني او پرې نه کتل.',
    },
  ),
];
