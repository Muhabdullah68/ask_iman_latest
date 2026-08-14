// lib/admin_meta_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// META TAG GUARD — Flutter Web implementation
//
// When the hidden /secret-admin-dashboard route is mounted this guard injects:
//   <meta name="robots" content="noindex, nofollow">
// into the document <head>, AND overwrites document.title with a generic
// non-descriptive value so the word "admin" never appears in browser history,
// tab titles, or screen recordings shared publicly.
//
// When the route is disposed (navigated away) the meta tag is removed and
// the original <title> is restored (if cached).
//
// This implements Requirement 3 / Measure 6 of changes.txt:
//   "Route.meta: { noIndex: true } for admin route.
//    <meta name="robots" content="noindex, nofollow"> injected when route is
//    active. Never appears in sitemap.xml."
// ─────────────────────────────────────────────────────────────────────────────

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web-only meta tag injector for the hidden admin route.
///
/// Never call these methods from a mobile build path.
class AdminMetaWebGuard {
  static const String _metaName = 'robots';
  static const String _noIndexContent =
      'noindex, nofollow, noarchive, nosnippet, notranslate';
  static const String _anonymousTitle = 'Loading...';

  static html.MetaElement? _injectedMeta;
  static String? _originalTitle;

  /// Inject the crawler-blocking meta tag and genericize the page title.
  ///
  /// Safe to call multiple times: only injects once per route mount.
  static void applyNoIndex() {
    try {
      // 1. Save the current page title so we can restore it later,
      //    then swap in a deliberately bland string.
      _originalTitle ??= html.document.title;
      html.document.title = _anonymousTitle;

      // 2. If there's already a <meta name="robots"> in <head>, temporarily
      //    override its content so we don't double-inject nodes.
      final existing = html.document.querySelector('meta[name="$_metaName"]');
      if (existing is html.MetaElement) {
        // Stash the previous value so dispose() can restore it.
        existing.dataset['prev-content'] = existing.content;
        existing.content = _noIndexContent;
        _injectedMeta = existing;
        return;
      }

      // 3. Otherwise create a brand-new <meta> element and append to <head>.
      final head = html.document.head;
      if (head == null) return;
      final meta = html.MetaElement()
        ..name = _metaName
        ..content = _noIndexContent;
      head.append(meta);
      _injectedMeta = meta;
    } catch (_) {
      // Silently swallow — failure to inject a meta tag is non-critical.
    }
  }

  /// Remove the injected meta tag and restore the original page title.
  ///
  /// Called from _AdminGateWidgetState.dispose() when the admin user navigates
  /// back to the public-facing part of the website.
  static void restoreIndex() {
    try {
      // Restore title (if we cached one).
      if (_originalTitle != null) {
        html.document.title = _originalTitle!;
        _originalTitle = null;
      }
      // Restore / remove the robots meta node we modified.
      if (_injectedMeta != null) {
        final prev = _injectedMeta!.dataset['prev-content'];
        if (prev != null) {
          // It was a pre-existing meta we overwrote → restore previous value.
          _injectedMeta!.content = prev;
        } else {
          // It was a meta we created → remove the node entirely.
          _injectedMeta!.remove();
        }
        _injectedMeta = null;
      }
    } catch (_) {
      // Silently swallow — clean-up failures are non-critical.
    }
  }
}
