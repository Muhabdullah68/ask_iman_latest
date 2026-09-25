# Website UI Overhaul — Implementation Plan

Captured 25 Sep 2026. Implements three distinct areas of the website redesign feedback. No functionality changes — all existing features (Talawat reading, Tarjuma EN/UR, Tafseer 3-col, Settings toggles, Share link builder, QuranAudioService, QuranReadingState) are retained; only the layout composition and motion layer are upgraded. Color scheme preserved: brandDeepGreen #0E4D3C, accentGoldAmber #D4A24C, text palettes, hero gradients unchanged.

## Repository Research

### Current Quran page layout (quran_page.dart L111–L161)
4 stacked UI bars sit ABOVE the tab content:
1. _QuranHero — dark gradient hero band L168–L248 (≈120–150 px)
2. _SubNavBar — green Back-to-Library + 3 action icons L250–L340 (44 px)
3. _ControlBar — Quran/Juz segmented toggle + Index button L342–L421 (≈56 px)
4. _PillTabBar — Talawat/Tarjuma/Tafseer/Settings/Share pills L494–L585 (≈56 px)

Result: **~276 px of chrome BEFORE any reading content** on a 1080p screen (≈46% of viewport). The user called this unusable.

Additionally, each tab reinvents navigation:
- Talawat (tab 0) has a rich 316-px SURAH SIDEBAR + Juz grid toggle
- Tarjuma/Tafseer use a WEAK plain DropdownButton instead of the sidebar
- Settings/Share have NO surah selector at all (share uses singleton QuranReadingState, but state doesn't update when tarjuma/tafseer pick a surah because each has its own local `_selected`)
- QuranPaneContent (quran_web_widgets.dart L61–L88) wraps Tabs 1–4 in their OWN SingleChildScrollView + FOOTER inside the pane, while Talawat embeds its own Sliver footer + spacer → DOUBLE footers on non-Talawat tabs

### Current 3D ornament on Home (home_page.dart L977–L1028)
The `Daily Inspiration` row renders a 264×264 circular medallion containing:
- Outer gold circular border + radial gradient blob
- Padding(all:18) → `Model3D(src: open_quran_rehal_polished.glb)` with:
  - `borderRadius: Radius.circular(112)` → `ClipRRect` clips the 3D GLB tightly to a **circle**
  - `cameraOrbit: '0deg 85deg auto'` → top-down bird's eye, no tilt, no depth
  - `shadowIntensity: 0` → no ground shadow, no Z-depth cue

So user literally sees "just a circular element" because the 3D Quran-on-Rehal model gets clipped to a medallion circle + flattened with a top-down camera angle. The 3D widget code itself (web_model3d.dart L17–L85 + web_tilt3d.dart L18–L146) is correct and capable, but the Home parent parameters starve it of any 3D perception.

### Current scroll + keyboard
- WebShell (web_shell.dart L18–L40) = `Column: [WebNavbar, Expanded(child)]`. No keyboard Shortcuts, no focusable page scroll controller, no RawKeyboardListener. Browser handles ArrowDown natively by scrolling ~3 line-heights (~40–60 px per press), not the impressive jump the user wants.
- Home page uses ScrollReveal ONLY on 3 macro-section containers: _FeatureTiles, _DailyInspiration, _SacredCollections (home_page.dart L41–L58). Individual children (6 feature tiles, panel+ornament, 3 book cards) are wrapped with a one-shot `animate()` (L627) but not tied to scroll visibility. There is no per-child staggered entrance as the user scrolls.

---

## Files and Modules

| File | Expected change |
|---|---|
| `lib/web/pages/quran_page.dart` | Full layout redesign: 2-row chrome (hero+subnav merged → control+pills merged), always-on shared sidebar, single pane content area, no double footers |
| `lib/web/pages/quran/surah_explorer_web.dart` | Extract sidebar `_SurahSidebar` as public `QuranSurahSidebar` + keep `SurahReadingPane` standalone; add `onSurahChanged` to sidebar; remove own WebFooter/Sliver spacer (footer promoted to shell in WEB-5) |
| `lib/web/pages/quran/translation_web.dart` | Remove Dropdown + local `_selected`; accept injected `(currentSurah, onSurahChanged, currentAyah, onAyahTapped)` and wrap its content body in a new reading-pane container to match Talawat visuals |
| `lib/web/pages/quran/tafseer_web.dart` | Same: remove Dropdown, remove local `_surah`, accept injected reading state, wrap content in unified reading-pane shell |
| `lib/web/pages/quran/settings_web.dart` | Accept shared state + wrap cards in unified pane; rename `_SettingsSection` border to gold-hairline for premium feel; expose state so user can see settings affect the current surah preview |
| `lib/web/pages/quran/share_web.dart` | Already driven by QuranReadingState singleton → no logic change, just wrap cards in unified pane to match siblings |
| `lib/web/pages/quran/quran_web_widgets.dart` | `QuranPaneContent` DEPRECATED (replaced by new `_TabContentPane` inside quran_page); new `UnifiedReadingPane(Widget child, {String? eyebrow, String? title, String? subtitle, List<Widget>? actions})` widget used uniformly by all 5 tabs; `BasmalaWidget` stays unchanged; new `_SurahMetaBar` (shared by every tab) shows open surah chip + arabic micro-label |
| `lib/web/pages/home_page.dart` | **DailyInspiration ornament** (L977–L1028): remove circular clip on Model3D, switch to 3/4 cameraOrbit, enable shadow, add float Tilt3D idle, expand ratio from 2:6→3:5, add ka_ba_3d.glb alternative option via if-else asset swap; **_FeatureTiles** (L543–L642): wrap each GridView child individually in ScrollReveal with staggered delays (replace the one-shot animate that only plays on first build); **_SacredCollections** (L1059–L1192): StaggeredEntrance for each _BookCard; **_AyatSlider** (L124–L510): each slide's khatam lattice + Mihrab gets a parallax offset tied to page scroll position so ornaments drift as user scrolls |
| `lib/web/widgets/web_shell.dart` | Add `Shortcuts` + `CallbackAction` bindings for ArrowUp/ArrowDown/PageUp/PageDown/Home/End that drive a global `PageScrollController` attached to the Expanded child's scrollable; 1 press = scroll by 0.33 viewport heights with `animateTo` + Curves.easeOutCubic |
| `lib/web/widgets/web_animations.dart` | ScrollReveal: fix current bug where `_checkVisibility` only fires inside a NotificationListener (home wraps sections in a non-animated Column, no scroll notifications bubble → ScrollReveal never fires except for the LayoutBuilder); add a `Scrollable.maybeOf(context)` frame-tick listener so reveals work in ANY scroll context; add new `ParallaxScroll` wrapper used for ornament layers |
| `lib/web/widgets/web_widgets.dart` | WebPageScaffold: expose its scroll controller so Shell-level keyboard shortcuts can drive it; HoverLift: add 0.5 px gold border fade-in on hover to match WEB-1 card ornate feel |
| `lib/changes.txt` | Append 3 new issue headers (WEB-6 Quran layout, WEB-7 Home 3D, WEB-8 Scroll+keyboard) with spec + done markers as each phase completes |

---

## Implementation Steps

### Phase 1: Quran Page Unified Layout (WEB-6)
1. **Extract shared QuranSurahSidebar**: In `surah_explorer_web.dart`, cut the private `_Sidebar` + `_SurahTile` + `_JuzSidebar` widgets and promote them to a public `QuranSurahSidebar(juzMode, onToggleJuz, selectedSurah, onSelectSurah, onSelectAyah, drawerOpen, onToggleDrawer, query, onQueryChanged)`. Keep `SurahReadingPane` as public standalone widget. Remove the SliverToBoxAdapter WebFooter at L657 and 72-px spacer at L658 (footer is shell-managed per WEB-5).

2. **Hoist shared state up to QuranPageState** (quran_page.dart L47–L88): add fields `_currentSurahNum`, `_currentAyahNum?`, `_sidebarQuery`; make Talawat's previously private `_handleAyahTapped` call `_setAyah` on parent; remove each of the 4 tab panes' internal surah state. `_pane(i)` (L89–L109) signature updated to pass down `currentSurahNum`, `currentAyahNum`, `ValueChanged<int> onSurahChanged`, `ValueChanged<int> onAyahChanged` for every tab.

3. **Collapse the 4 stacked bars to 2**:
   - **Top chrome row** = `_TopHeader` (1 merged row replacing _QuranHero + _SubNavBar):
     - Left: small 48×48 ArabicRoundel (Bismillah) + `AL-QUR'ĀN AL-KARĪM` eyebrow + `Quran Explorer` title (2 lines, compacted — hero text shrunk 20% vertically)
     - Right: Back-to-Library (inline pill), search icon, profile icon, moon icon. The 3 settings/gear icons from SubNavBar and pill from top-right share space.
     - Total height: **104 px max** (was ~194 for hero+subnav combined). Dark green gradient base + MihrabOrnament in corner.
   - **Bottom chrome row** = `_ChromeBar` (1 merged row replacing _ControlBar + _PillTabBar):
     - Left: Quran/Juz segmented pill + Index button (same as before)
     - Center/Right: THE 5 PILL TABS (Talawat/Tarjuma/Tafseer/Settings/Share) — fit them in the same bar by shaving pill padding from 16/9 → 12/7
     - Total height: **52 px** (was ~112 for bar+pills combined)
   - Net chrome reduction: 276 px → **156 px** → frees 120 px of reading real estate + avoids the "overlap at top" described in WEB-2

4. **Always-on Sidebar layout**: In QuranPage.build (L112–L161) replace Column with:
   ```
   TopHeader (1 row)
   ChromeBar (1 row)
   Expanded → Row:
     [ QuranSurahSidebar (304 px wide, visible ≥960, drawer <960)
     | VerticalDivider
     | Expanded → IndexedStack(tabs) all wrapped in unified scroll-view with single footer ]
   AudioBar still positioned at very bottom of Stack (above shell footer z-order)
   ```
   Every tab (Tarjuma/Tafseer/Settings/Share) now BENEFITS FROM having the surah index always present on the left — no more weak dropdowns, no disorientation about which surah is open.

5. **Unified reading pane shell for all 5 tabs**: Each tab exports a BODY-only widget now (no more own scroll, no more own footer). Tarjuma's Daily Inspiration banner moves ABOVE the `_TabIntro` inside the unified shell so all 5 tab bodies start at the exact same vertical anchor. Add a shared `_SurahContextChip` (small pill: 4 · An-Nisa · Medina · 176 ayat · 🟢 Makki or 🟡 Madani) rendered at the top of every tab body, so user always sees context.

6. **Update each tab to use injected state + unified pane**:
   - **Tarjuma**: Delete DropdownButton row L113–L174 entirely. Surah changes come from sidebar onLeft, current surah chip on top. The existing `_LangToggle` + `_ModeToggle` moves into the `UnifiedReadingPane.actions` slot so they are top-right aligned instead of buried in a container.
   - **Tafseer**: Delete DropdownButton + keep source pills in `UnifiedReadingPane.actions`. 3-col layout preserved exactly; `_setSource` stays local.
   - **Settings**: Wrap all 3 sections in `UnifiedReadingPane` with actions=[]; `_FontPreviewTile` / `_SettingsPill` cosmetics only (gold hairline borders).
   - **Share**: Already uses QuranReadingState singleton — now additionally responds to sidebar surah changes instantly; wrap the 3 `_ShareCard`s in `UnifiedReadingPane`; title/subtitle become `eyebrow='Share' / title='Share the Quran you are reading'` for consistency.

### Phase 2: Home Page 3D Ornament Fixed + Scroll Reveals (WEB-7)
1. **Fix 3D ornament cropping (home_page.dart L977–L1028)** — in `_DailyInspiration.build`, the `ornament` variable:
   - Remove `Positioned.fill > DecoratedBox shape:circle` (the outer circular frame). Replace with a rectangular gold 1-px hairline frame at 0.55 alpha with rounded-24 corners + optional `Tilt3D(maxAngle: 6)` so cursor gently tilts the whole ornament stack.
   - `Model3D` parameters change:
     - `borderRadius` → `BorderRadius.circular(20)` (card-style, NO circular clip)
     - `cameraOrbit` → `'28deg 62deg auto'` (true 3/4 view, looking slightly down at the open Quran rehal so pages + stand geometry both visible)
     - delete `shadowIntensity: 0` → use default (adds ground shadow, sells depth)
     - Also add `environmentImage: 'legacy'` if needed for better PBR on the gold rehal trim
   - Enlarge the ornament size: 264→320 px, padding 18→6 so ModelViewer has more space inside the clip-free frame
   - Layout row ratio change: `flex 6 + flex 2` (panel + ornament) → **5+3** so ornament gets the real estate it needs. On narrow layouts (<800 px) ornament goes ABOVE panel (reverse: `[ornament, 16px, panel]`) instead of below, so 3D wow-factor is encountered FIRST.
   - `web_model3d.dart` rotationPerSecond upgrade: default `18deg` → `10deg` reduce motion for readability, but ensure autoRotate: true + add a `Tilt3D` wrapped around the ornament's outer `Container` so hover adds a cursor-following 6deg tilt layered ON TOP of the model's own orbit. User now perceives "3D animation" not "circular element rotating."

2. **Scroll-triggered per-element StaggeredEntrance on Home**:
   - **Feature tiles** (_FeatureTiles L608–L636): replace the one-shot `.animate(delay: ...)` (which plays only once on first widget build, regardless of whether user has scrolled to them) with individual `ScrollReveal(delay: Duration(milliseconds: i*90), slideOffset: Offset(0, 24), child: tile)`. Wrap each tile in its own `StaggeredEntrance` children-list item by constructing a list of `[for (var i=0; i<_tiles.length; i++) ScrollReveal(…)]` — the existing GridView stays as container, now each cell scroll-reveals independently.
   - **Daily Inspiration panel + ornament** (_DailyInspiration L1030–L1052): replace current single `ScrollReveal` wrapper on the whole section with TWO staggered reveals: `panel` with delay=0, `ornament` with delay=120ms and slideOffset + scale + rotate(−1.5deg→0deg) entrance so the 3D model has a grand entrance curve.
   - **Sacred Collections book cards** (_SacredCollections L1157–L1182): `LayoutBuilder` row/column builder → wrap each `_BookCard` in its own `ScrollReveal(delay: 90*i)`; also on the books section's `GoldRule` L1155 add `GoldReveal(72, 2, 600ms)` below it so the rule draws itself as it enters viewport.

3. **Hero ornaments parallax drift** (_AyatSlider L200–L276): wrap the two MihrabOrnament Positioned layers (top-right + bottom-left) individually in new `ParallaxScroll(depth: 0.18 child: …)` from `web_animations.dart` so when user scrolls, the ornaments drift at 18% different speed from the slide content, selling the illusion of depth. The ArabesqueBand bottom layer uses `ParallaxScroll(depth: 0.08)` for subtle parallax.

### Phase 3: Keyboard-Driven Page Scrolling + ScrollReveal bugfix (WEB-8)
1. **Add Shortcuts bindings to WebShell** (web_shell.dart L18–L40). New:
   - Create `final _scrollCtrl = ScrollController();` inside WebShell (convert to Stateful widget temporarily OR use InheritedWidget controller). Best: `WebShell` → Stateful with `_WebShellState` holding `_scrollCtrl` and disposing it.
   - Wrap Scaffold body in:
     ```dart
     Shortcuts(
       shortcuts: {
         LogicalKeySet(LogicalKeyboardKey.arrowDown): const _ScrollStep(fwd:true),
         LogicalKeySet(LogicalKeyboardKey.arrowUp):   const _ScrollStep(fwd:false),
         LogicalKeySet(LogicalKeyboardKey.pageDown):  const _ScrollPage(fwd:true),
         LogicalKeySet(LogicalKeyboardKey.pageUp):    const _ScrollPage(fwd:false),
         LogicalKeySet(LogicalKeyboardKey.home):      const _ScrollEdge(top:true),
         LogicalKeySet(LogicalKeyboardKey.end):       const _ScrollEdge(top:false),
       },
       child: Actions(
         actions: {
           _ScrollStep:  CallbackAction<_ScrollStep>(onInvoke: (intent) => _step(intent.fwd, 0.33)),
           _ScrollPage:  CallbackAction<_ScrollPage>(onInvoke: (intent) => _step(intent.fwd, 0.80)),
           _ScrollEdge:  CallbackAction<_ScrollEdge>(onInvoke: (intent) => _edge(intent.top)),
         },
         child: Focus(autofocus: true, canRequestFocus: true, child: …original scaffold…),
       ),
     )
     ```
   - `_step(fwd, ratio)`: find viewport height via `MediaQuery.size.height` minus navbar 64 px; target = current offset + (±ratio × vpHeight); `_scrollCtrl.animateTo(target clamped, duration 520ms, curve easeOutCubic)`
   - Critical: use `Actions` + `Shortcuts` instead of `RawKeyboardListener` because TextFields in the page (QuranPage search box, home search) need to consume arrows for cursor movement when focused — the Shortcuts system correctly defers to focus-winner text fields automatically.

2. **Wire the ScrollController into every page's WebPageScaffold** (web_widgets.dart `WebPageScaffold` L17–L70): add a new optional `ScrollController? controller` parameter. If passed, use it for the inner `SingleChildScrollView`; otherwise create a local one. This way Shell-level `_scrollCtrl` flows through to Home/About/Quran's outer scroll view and the Shortcuts step the same scroll the user's mouse wheel does.

3. **Fix ScrollReveal visibility detection** (web_animations.dart L21–L112): current code listens to `ScrollNotification` via `NotificationListener` but when the `Scrollable` lives in an ancestor (WebPageScaffold wrapping the Column parent), notifications don't descend. Fix: replace the notification-listener-based logic with a `SchedulerBinding.instance.addPostFrameCallback` loop that re-queries visibility every frame WHILE the ScrollController attached to the nearest Scrollable `extentAfter` + `extentBefore` is changing. OR simpler: switch `ScrollReveal` to use `VisibilityDetector`-style check by re-querying `box.localToGlobal` on every scroll event subscribed to the nearest `Scrollable.of(context).position`. Implementation:
   ```dart
   @override void initState() { super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       final pos = Scrollable.maybeOf(context)?.position;
       pos?.addListener(_checkVisibility);
     });
   }
   @override void dispose() { Scrollable.maybeOf(context)?.position.removeListener(_checkVisibility); _controller.dispose(); super.dispose(); }
   ```
   This makes ScrollReveals fire reliably in every page, not just the ones lucky enough to catch bubbling notifications. After phase 3, all 6 feature tiles' entrance animations work as the user scrolls.

4. **New ParallaxScroll** widget in `web_animations.dart`: accepts `child` and `double depth` (0.0–1.0). Uses the same Scrollable.position listener to track scroll offset, then wraps child in `Transform.translate(offset: Offset(0, -(savedOffset) * depth))` to achieve parallax proportional to how far ornament is from top of screen.

---

## Dependencies and Considerations

- **No new packages.** Shortcuts/Actions/Transform/ModelViewer/Tilt3D/ScrollController all exist. `model_viewer_plus` is already a `pubspec` dep.
- **Focus management**: The Shortcuts system relies on a `Focus` node in the Shell being the primary focus when no text field is active. `autofocus: true` on the Shell's Focus + `.requestFocus()` after tap-to-dispatch (GestureDetector on body → `Focus.of(context).requestFocus(shellFocusNode)`) ensures arrow keys always scroll unless a TextField has focus.
- **Talawat nested sidebar scroll vs page scroll**: Talawat's 2-pane (sidebar + reading) has 2 internal `ListView`s. When user presses ArrowDown and sidebar has focus → browser scrolls sidebar (OK because Shortcuts only trigger on the ancestor Focus, which is not focused when a scrollable child holds it). Reading content is the default focus target → Shell shortcuts always scroll the page-level scroll, not inner ayat lists (unless user explicitly taps sidebar/ayat list first). Correct UX.
- **QuranReadingState already singleton + Listenable**: perfect because `QuranShareWeb` uses `ListenableBuilder(QuranReadingState.instance, …)` → once hoisted parent calls `instance.setSurah(_currentSurahNum)` inside the ValueChanged callback, the Share tab updates via the existing listenable. No breaking change.
- **Reduce motion**: `MediaQuery.disableAnimations` is honored in Tilt3D, ScrollReveal, Model3D (rotationPerSecond drops to 4deg). New keyboard scroll `animateTo` duration should be 0ms when disableAnimations is true.

---

## Validation

1. **Quran layout unified**:
   - Measure viewport: 1440×900 → chrome ≤160 px, visible ayat cards in Talawat ≥3 (was ≤2 before)
   - Switch to Tarjuma → still shows Surah sidebar; picking different surah via sidebar → Tarjuma body + Share tab both reflect new surah instantly
   - DropdownButton nowhere to be seen in Tabs 1–4; footers rendered exactly ONCE via shell (no inner-QuranPaneContent footer, no Talawat Sliver footer → grep `WebFooter` in quran_page/surah_explorer_web returns 0 matches)
   - Open Settings, change font → switch to Talawat → font style applied immediately (shared state wired)

2. **3D ornament**:
   - Scroll to Daily Inspiration → ornament appears with staggered entrance (rotate -1.5deg → 0, slide up 24px, scale 0.98→1.0)
   - Model3D displays Quran-on-Rehal with pages tilted toward camera (28deg azimuth), ground shadow visible, rotates 10deg/sec. No circular crop — ornament has rectangular 24-radius rounded corners with gold hairline frame.
   - Hover cursor → ornament tilts.
   - Open browser DevTools → `<model-viewer>` `camera-orbit="28deg 62deg auto"`, no `border-radius: 50%` on the CLIP element.

3. **Scroll + keyboard**:
   - Home page, no focus → ArrowDown press → page animates down ≈ 1/3 viewport (300–320 px on 1080p) with curve, not 40 px jump
   - ArrowUp returns to prior anchor; PageDown = 0.8 vp; Home → instantly top, End → instantly bottom
   - Focus the hero search TextField → ArrowDown moves caret inside input (does NOT scroll page) → unfocus → ArrowDown scrolls again
   - Feature tiles: one by one fade/slide up as scroll crosses 85% threshold into viewport, not all at once on page load
   - Sacred Collections: each book card has a 90ms offset entrance; GoldRule paints width from 0→72 as it passes 90% scroll threshold

4. **Lint / compile**: `flutter analyze` → 0 new issues in touched files; baseline issues unchanged (64 pre-existing).
5. **Run tests**: `flutter test test/` → existing 81 tests still pass.

---

## Risks

| Risk | Handling |
|---|---|
| **Quran state hoist race**: If `_currentSurahNum` init order vs `QuranReadingState.instance` set order differs on first mount, Share tab reads Surah 1 while sidebar shows user-picked deep link. | QuranPage.initState already seeds via `QuranReadingState.instance.selectAyah/setSurah` for `widget.initialSurah`. Keep that, AND make `_currentSurahNum` default = `QuranReadingState.instance.surahNum` instead of `widget.tab`. Guards against drift. |
| **Shortcuts don't fire when Shell Focus loses node** (after user clicks empty space). | Add a top-level `Listener` wrapping WebPageScaffold → on PointerDown if the target is not a TextField → `shellFocusNode.requestFocus()`. Keep focus on scrollable root unless actively editing text. |
| **Model3D kaaba_3d.glb alternative breaks** because glTF file wasn't bundled. | Current plan uses ONLY the existing `open_quran_rehal_polished.glb` path (L1007) so no new assets required. If client later prefers Kaaba, it's a 1-line src swap. Leave both paths in code as comments. |
| **Nested scroll fights** in QuranSidebar (ListView) + shell scroll on ArrowDown. When sidebar has focus it handles arrows itself (ListView behavior). The Shortcuts priority-above-focus doesn't apply because the Focus only fires in the ancestor scope the ListView Focus consumed it. Flutter's focus system already handles this correctly. Manual smoke-test 5 scenarios: cursor in search, sidebar focus, ayat list focus, settings pill focus, empty page click — arrow keys do right thing. |
| **Parallax jank**: Scroll position listener + transform translate each frame = layout work every scroll tick. Cap parallax depth max = 0.25, and use `const` children wherever possible; use `addPersistentFrameCallback` instead of setState when possible (compute transform directly via `AnimatedBuilder` vs scroll position `listen`). |

---

## Deliverables Order

1. Step 1: Extract `QuranSurahSidebar` + refactor `SurahReadingPane` → Phase 1.1
2. Step 2: State hoist in `QuranPageState` + update tab constructors → Phase 1.2
3. Step 3: Merge 4→2 chrome bars + always-on Row layout → Phase 1.3–1.4
4. Step 4: UnifiedReadingPane + each tab body wiring → Phase 1.5–1.6
5. Step 5: Fix 3D ornament + entrance curve (Home DailyInspiration) → Phase 2.1
6. Step 6: Per-element ScrollReveal staggered on FeatureTiles/DailyInspiration/SacredCollections → Phase 2.2
7. Step 7: ParallaxScroll + ornament drift → Phase 2.3
8. Step 8: Shell Shortcuts + ScrollController propagation + ScrollReveal bugfix → Phase 3.1–3.3
9. Step 9: New ParallaxScroll widget → Phase 3.4
10. Step 10: `flutter analyze`, `flutter test`, write WEB-6/7/8 done markers in changes.txt → Validation

After step 4 user can already validate Quran layout redesign; after step 7 the Home wow-factor is visible; after step 9 keyboard + scroll behavior finalized. This lets you stop midway and confirm each stage before deeper investment.
