import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// One-time corpus fetcher: downloads the Quran + 6 hadith books (eng/ara) in
/// the same raw JSON shapes the app parsers expect and stores them under
/// assets/corpus/ so the ASK Iman AI runs fully offline (assets-first).
///
/// Run: dart run tool/download_corpus.dart
void main() async {
  final outDir = Directory('assets/corpus');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  const quranEditions = {
    'ara': 'quran-uthmani-hafs',
    'eng': 'en.sahih',
    'urd': 'ur.ahmedali',
  };
  const hadithSlugs = [
    'bukhari', 'muslim', 'abudawud', 'tirmidhi', 'nasai', 'ibnmajah',
  ];

  var ok = true;

  for (final e in quranEditions.entries) {
    final url = Uri.parse(
        'https://api.alquran.cloud/v1/quran/${e.value}');
    final file = File('${outDir.path}/quran_${e.key}.json');
    ok &= await _fetch(file, url, [],
        check: (body) {
          final raw = jsonDecode(body) as Map<String, dynamic>;
          final surahs = (raw['data'] as Map)['surahs'] as List;
          var count = 0;
          for (final s in surahs) {
            count += ((s as Map)['ayahs'] as List? ?? const []).length;
          }
          if (count < 6000) throw StateError('quran_${e.key}: only $count ayahs');
          return 'quran_${e.key}: $count ayahs';
        });
  }

  for (final slug in hadithSlugs) {
    for (final lang in ['eng', 'ara']) {
      final url = Uri.parse(
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/$lang-$slug.json');
      final mirror = Uri.parse(
          'https://raw.githubusercontent.com/fawazahmed0/hadith-api/1/editions/$lang-$slug.json');
      final file = File('${outDir.path}/hadith_${lang}_$slug.json');
      ok &= await _fetch(file, url, [mirror],
          check: (body) {
            final raw = jsonDecode(body) as Map<String, dynamic>;
            final hadiths = (raw['hadiths'] as List?) ?? const [];
            if (hadiths.length < 50) {
              throw StateError('hadith_$lang-$slug: only ${hadiths.length} hadiths');
            }
            return 'hadith_$lang-$slug: ${hadiths.length} hadiths';
          });
    }
  }

  stdout.writeln(ok ? '\nALL CORPUS FILES OK.' : '\nSOME FILES FAILED.');
  exitCode = ok ? 0 : 1;
}

/// Downloads [url] (falling back through [mirrors]) into [file]. Verifies the
/// JSON is parseable via [check] before declaring success. Retries each source.
Future<bool> _fetch(
  File file,
  Uri url,
  List<Uri> mirrors,
  {required String Function(String body) check,
  int attempts = 3}) async {
  final sources = [url, ...mirrors];
  String? lastErr;
  for (final src in sources) {
    for (var a = 0; a < attempts; a++) {
      try {
        stdout.writeln('GET $src');
        final body = await _getBody(src);
        final info = check(body);
        file.writeAsStringSync(body, flush: true);
        stdout.writeln('  -> saved ${file.path} (${file.lengthSync()} bytes, $info)');
        return true;
      } on SocketException catch (e) {
        lastErr = e.toString();
      } on HttpException catch (e) {
        lastErr = e.toString();
      } on TimeoutException catch (e) {
        lastErr = e.toString();
      } on FormatException catch (e) {
        lastErr = 'format: ${e.toString()}';
      } catch (e) {
        lastErr = e.toString();
      }
      stdout.writeln('  attempt ${a + 1} failed: $lastErr'
          '${a < attempts - 1 ? ' — retrying…' : ''}');
      if (a < attempts - 1) await Future<void>.delayed(const Duration(seconds: 3));
    }
  }
  stdout.writeln('  !! FAILED ($url): $lastErr');
  return false;
}

Future<String> _getBody(Uri uri, {int timeoutSeconds = 120}) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30);
  try {
    final req = await client.getUrl(uri);
    final res = await req.close().timeout(Duration(seconds: timeoutSeconds));
    if (res.statusCode != 200) {
      throw HttpException('HTTP ${res.statusCode}');
    }
    final bytes = await res
        .fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk))
        .timeout(Duration(seconds: timeoutSeconds));
    return utf8.decode(bytes, allowMalformed: true);
  } finally {
    client.close();
  }
}