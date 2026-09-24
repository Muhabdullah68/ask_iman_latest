// lib/web/web_origin.dart
// ─────────────────────────────────────────────────────────────────────────────
// Derives the current site origin for share links. On the web this resolves
// to the browser's actual scheme://host[:port] (so links copied on
// localhost / staging point back to the same host instead of hard-coded
// https://askiman.com), falling back to the production domain off-web.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

const String fallbackProductionOrigin = 'https://askiman.com';

String siteOrigin() => kIsWeb ? Uri.base.origin : fallbackProductionOrigin;