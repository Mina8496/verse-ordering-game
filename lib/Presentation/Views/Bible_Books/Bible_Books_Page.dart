// نفس import كما في نسختك الأصلية + خط GoogleFonts
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class BiblePage extends StatefulWidget {
  const BiblePage({Key? key}) : super(key: key);

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  Map<String, dynamic> _bible = {};
  List<String> _bookNames = [];
  String _selectedBook = '';
  int _selectedChapter = 1;
  Set<String> _favorites = {};
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadBible();
    _loadFavorites();
  }

  final List<String> oldTestament = [
    'gn',
    'ex',
    'lv',
    'nm',
    'dt',
    'js',
    'jud',
    'rt',
    '1sm',
    '2sm',
    '1kgs',
    '2kgs',
    '1ch',
    '2ch',
    'ezr',
    'ne',
    'et',
    'job',
    'ps',
    'prv',
    'ec',
    'so',
    'is',
    'jr',
    'lm',
    'ez',
    'dn',
    'ho',
    'jl',
    'am',
    'ob',
    'jn',
    'mi',
    'na',
    'hk',
    'zp',
    'hg',
    'zc',
    'ml',
  ];

  final List<String> newTestament = [
    'mt',
    'mk',
    'lk',
    'jo',
    'act',
    'rm',
    '1co',
    '2co',
    'gl',
    'eph',
    'ph',
    'cl',
    '1ts',
    '2ts',
    '1tm',
    '2tm',
    'tt',
    'phm',
    'hb',
    'jm',
    '1pe',
    '2pe',
    '1jo',
    '2jo',
    '3jo',
    'jd',
    're',
  ];

  final Map<String, String> arabicBookNames = {
    'gn': 'التكوين',
    'ex': 'الخروج',
    'lv': 'اللاويين',
    'nm': 'العدد',
    'dt': 'التثنية',
    'js': 'يشوع',
    'jud': 'القضاة',
    'rt': 'راعوث',
    '1sm': 'صموئيل الأول',
    '2sm': 'صموئيل الثاني',
    '1kgs': 'الملوك الأول',
    '2kgs': 'الملوك الثاني',
    '1ch': 'أخبار الأيام الأول',
    '2ch': 'أخبار الأيام الثاني',
    'ezr': 'عزرا',
    'ne': 'نحميا',
    'et': 'أستير',
    'job': 'أيوب',
    'ps': 'المزامير',
    'prv': 'الأمثال',
    'ec': 'الجامعة',
    'so': 'نشيد الأنشاد',
    'is': 'إشعياء',
    'jr': 'إرميا',
    'lm': 'مراثي إرميا',
    'ez': 'حزقيال',
    'dn': 'دانيال',
    'ho': 'هوشع',
    'jl': 'يوئيل',
    'am': 'عاموس',
    'ob': 'عوبديا',
    'jn': 'يونان',
    'mi': 'ميخا',
    'na': 'ناحوم',
    'hk': 'حبقوق',
    'zp': 'صفنيا',
    'hg': 'حجي',
    'zc': 'زكريا',
    'ml': 'ملاخي',
    'mt': 'متى',
    'mk': 'مرقس',
    'lk': 'لوقا',
    'jo': 'يوحنا',
    'act': 'أعمال الرسل',
    'rm': 'رومية',
    '1co': 'كورنثوس الأولى',
    '2co': 'كورنثوس الثانية',
    'gl': 'غلاطية',
    'eph': 'أفسس',
    'ph': 'فيلبي',
    'cl': 'كولوسي',
    '1ts': 'تسالونيكي الأولى',
    '2ts': 'تسالونيكي الثانية',
    '1tm': 'تيموثاوس الأولى',
    '2tm': 'تيموثاوس الثانية',
    'tt': 'تيطس',
    'phm': 'فليمون',
    'hb': 'العبرانيين',
    'jm': 'يعقوب',
    '1pe': 'بطرس الأولى',
    '2pe': 'بطرس الثانية',
    '1jo': 'يوحنا الأولى',
    '2jo': 'يوحنا الثانية',
    '3jo': 'يوحنا الثالثة',
    'jd': 'يهوذا',
    're': 'الرؤيا',
  };

  Future<void> _loadBible() async {
    final data = await rootBundle.loadString('assets/bible/ar_svd.json');
    final List<dynamic> bibleList = json.decode(data);

    print(bibleList.map((b) => b['abbrev']).toList());

    final Map<String, dynamic> parsed = {};

    for (final book in bibleList) {
      final String abbrev = book['abbrev'];
      final List<dynamic> chapters = book['chapters'];

      final Map<String, Map<String, String>> chapterMap = {};

      for (int i = 0; i < chapters.length; i++) {
        final List<dynamic> verses = chapters[i];
        final Map<String, String> verseMap = {};

        for (int j = 0; j < verses.length; j++) {
          verseMap[(j + 1).toString()] = verses[j];
        }

        chapterMap[(i + 1).toString()] = verseMap;
      }

      parsed[abbrev] = chapterMap;
    }

    setState(() {
      _bible = parsed;
      _bookNames = parsed.keys.toList();
      _selectedBook = _bookNames.first;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String verse) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(verse)) {
        _favorites.remove(verse);
      } else {
        _favorites.add(verse);
      }
      prefs.setStringList('favorites', _favorites.toList());
    });
  }

  void _copyVerse(String verse) {
    Clipboard.setData(ClipboardData(text: verse));
    showToast('تم نسخ الآية');
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: _favorites
            .map(
              (v) => ListTile(
                title: Text(v, textAlign: TextAlign.right),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyVerse(v),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterMap =
        _bible[_selectedBook]?['$_selectedChapter'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          'الكتاب المقدس',
          style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _showFavorites,
          ),
        ],
      ),
      body: _bible.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['الكل', 'العهد القديم', 'العهد الجديد'].map((
                    filter,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                            if (_selectedFilter == 'العهد القديم') {
                              _bookNames = oldTestament;
                            } else if (_selectedFilter == 'العهد الجديد') {
                              _bookNames = newTestament;
                            } else {
                              _bookNames = _bible.keys.toList();
                            }
                            _selectedBook = _bookNames.first;
                            _selectedChapter = 1;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                // اختيار السفر والإصحاح
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      // textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBook,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBook = value!;
                                  _selectedChapter = 1;
                                });
                              },
                              items: _bookNames
                                  .map(
                                    (code) => DropdownMenuItem(
                                      value: code,
                                      child: Text(
                                        arabicBookNames[code] ?? code,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: _selectedChapter,
                          onChanged: (value) {
                            setState(() => _selectedChapter = value!);
                          },
                          items: List.generate(
                            _bible[_selectedBook]?.length ?? 1,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text(
                                'الإصحاح ${i + 1}',
                                style: GoogleFonts.cairo(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // قائمة الآيات
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children:
                        chapterMap?.entries.map((entry) {
                          final verseNumber = entry.key;
                          final verseText = entry.value;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$verseNumber. $verseText',
                                    textDirection: TextDirection.rtl,

                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () => _copyVerse(verseText),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _favorites.contains(verseText)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _toggleFavorite(verseText),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                ),

                // أزرار التنقل بين الإصحاحات
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            if (_selectedChapter > 1) {
                              setState(() => _selectedChapter--);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            final max = _bible[_selectedBook]?.length ?? 1;
                            if (_selectedChapter < max) {
                              setState(() => _selectedChapter++);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
