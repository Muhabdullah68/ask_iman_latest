import 'dart:convert';
import 'dart:io';

/// Quick validation that the ibnmajah slug fix works and Arabic text is
/// present.  Run: dart run tool/check_ibnmajah.dart
Future<void> main() async {
  const editions = [
    'eng-ibnmajah', 'ara-ibnmajah',
    'eng-bukhari',   'ara-bukhari',
  ];
  final client = HttpClient();
  try {
    for (final ed in editions) {
      final url = Uri.parse(
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/$ed.json');
      final req = await client.getUrl(url);
      final res = await req.close();
      print('--- $ed  (HTTP ${res.statusCode}) ---');
      if (res.statusCode != 200) continue;
      final body = await res.transform(utf8.decoder).join();
      final j = jsonDecode(body) as Map<String, dynamic>;
      final hadiths = (j['hadiths'] as List?) ?? const [];
      if (hadiths.isEmpty) {
        print('  [no hadiths]');
        continue;
      }
      print('  count: ${hadiths.length}');
      for (final h in hadiths.take(3)) {
        final hm = h as Map<String, dynamic>;
        print('  #${hm['hadithnumber']} '
            '(first-referenced grade: ${_grade(hm)})');
      }
      print('');
    }

    print('=== Sample citation block ===');
    // Simulate building references from eng-ibnmajah + ara-ibnmajah
    final eng = await _load('eng-ibnmajah');
    final ara = await _load('ara-ibnmajah');
    print('eng-ibnmajah items: ${eng.length}');
    print('ara-ibnmajah items: ${ara.length}');
    if (eng.isNotEmpty && ara.isNotEmpty) {
      final first = eng.first;
      final num = first['hadithnumber'];
      final araText = ara.firstWhere(
        (a) => a['hadithnumber'] == num,
        orElse: () => <String, dynamic>{},
      );
      print('');
      print('Hadith — Sunan Ibn Majah #$num:');
      final arText = araText['text'] ?? '';
      if (arText.toString().isNotEmpty) print('\u201C$arText\u201D');
      print('Translation: ${first['text']}');
      final grades = first['grades'] as List? ?? [];
      if (grades.isNotEmpty) {
        print('Authenticity note: ${(grades.first as Map)['grade']}');
      }
    }
  } finally {
    client.close();
  }
}

Future<List<Map<String, dynamic>>> _load(String ed) async {
  final client = HttpClient();
  try {
    final url = Uri.parse(
        'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/$ed.json');
    final req = await client.getUrl(url);
    final res = await req.close();
    if (res.statusCode != 200) return const [];
    final body = await res.transform(utf8.decoder).join();
    final j = jsonDecode(body) as Map<String, dynamic>;
    final hadiths = (j['hadiths'] as List?) ?? const [];
    return [
      for (final h in hadiths)
        if (h is Map<String, dynamic>)
          {
            'hadithnumber': h['hadithnumber'],
            'text': h['text'] ?? '',
            'grades': h['grades'] ?? [],
          }
    ];
  } finally {
    client.close();
  }
}

String _grade(Map<String, dynamic> h) {
  final grades = h['grades'] as List? ?? [];
  if (grades.isEmpty) return '';
  final g = grades.first;
  if (g is Map && g['grade'] is String) return g['grade'] as String;
  return '';
}
