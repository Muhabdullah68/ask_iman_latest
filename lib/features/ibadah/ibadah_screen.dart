// lib/features/ibadah/ibadah_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// IBADAH SCREEN
//
// Sections:
//   1. Next Prayer hero banner  — live countdown
//   2. All 5 prayers list       — highlights next prayer
//   3. Hijri Calendar           — replaces old "Ibadah Tools" grid
//        • Today's Hijri date (large display)
//        • Current Hijri month mini-calendar
//        • Upcoming Islamic occasions
//   4. Quick Tools              — Qiblah & Tasbeeh (2-item row)
//   5. Sunnah Times             — Midnight, Last Third
//   6. Prayer Settings          — Madhab only (4 options), Notifications
//
// Changes from previous version:
//   • "Ibadah Tools" 4-item grid replaced by full Hijri calendar section
//   • "Calculation Method" removed from settings (fixed to Umm Al-Qura)
//   • Madhab now shows all 4: Hanafi, Maliki, Shafi'i, Hanbali
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/prayer_service.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'qiblah_screen.dart';
import 'tasbeeh_screen.dart';

class IbadahScreen extends StatefulWidget {
  const IbadahScreen({super.key});

  @override
  State<IbadahScreen> createState() => _IbadahScreenState();
}

class _IbadahScreenState extends State<IbadahScreen> {
  final _svc = PrayerService();

  // Hijri calendar state
  late int _viewHijriYear;
  late int _viewHijriMonth;

  // Interactive calendar state
  int? _selectedDay;            // tapped day in the current viewed month
  bool _showAllOccasions = false; // show-more toggle for occasions list

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onUpdate);
    if (_svc.prayerTimes == null && !_svc.isLoading) _svc.refresh();
    final today = HijriDate.today;
    _viewHijriYear  = today.year;
    _viewHijriMonth = today.month;
  }

  @override
  void dispose() {
    _svc.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(),
      body: RefreshIndicator(
        color: AppColors.gold,
        backgroundColor: AppColors.primaryDark,
        onRefresh: _svc.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNextPrayerBanner(context),
              const SizedBox(height: 20),
              _buildPrayersList(),
              const SizedBox(height: 24),
              _buildHijriCalendar(),
              const SizedBox(height: 24),
              _buildQuickTools(context),
              const SizedBox(height: 24),
              _buildSunnahTimes(),
              const SizedBox(height: 20),
              _buildCalculationMethodStrip(context),
              const SizedBox(height: 12),
              _buildSettingsStrip(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. Next Prayer Banner
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildNextPrayerBanner(BuildContext context) {
    final sw   = MediaQuery.of(context).size.width;
    final next = _svc.nextPrayerInfo;
    return ClipPath(
      clipper: _ArchClipper(),
      child: SizedBox(
        height: sw * 0.56,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/mosque interior.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) =>
                  Container(color: AppColors.primaryDark),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xBB0D2818), Color(0xEE0A1F12)],
                  stops: [0.1, 1.0],
                ),
              ),
            ),
            _svc.isLoading
                ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold))
                : _svc.error != null
                ? _buildBannerError()
                : _buildBannerContent(next),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded,
                color: AppColors.textGreenMuted, size: 36),
            const SizedBox(height: 10),
            Text(_svc.error ?? 'Enable location for prayer times',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 14,
                    color: AppColors.textCream)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _svc.refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Try Again',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerContent(PrayerInfo? next) {
    if (next == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('All prayers complete',
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                )),
            const SizedBox(height: 6),
            const Text('JazakAllah Khair',
                style: TextStyle(
                    fontFamily: 'Amiri', fontSize: 22,
                    color: AppColors.gold)),
          ],
        ),
      );
    }
    final mins = next.minutesUntil();
    final hrs  = mins ~/ 60;
    final rem  = mins % 60;
    final countdownText =
    hrs > 0 ? '${hrs}h ${rem}m remaining' : '${mins}m remaining';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('NEXT PRAYER',
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.gold, letterSpacing: 2.5,
              )),
          const SizedBox(height: 6),
          Text(next.name,
              style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 34,
                fontWeight: FontWeight.w800, color: Colors.white,
              )),
          Text(next.timeFormatted,
              style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 22,
                fontWeight: FontWeight.w600, color: AppColors.gold,
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(countdownText,
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    color: AppColors.textCream)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. Prayers List
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPrayersList() {
    final prayers = _svc.todayPrayers;
    final hijri   = HijriDate.today;
    final greg    = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Prayer Times',
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 18,
                    fontWeight: FontWeight.w700, color: AppColors.textDark,
                  )),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(greg,
                      style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 11,
                          color: AppColors.textGrey)),
                  Text(hijri.formatted,
                      style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 10,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_svc.isLoading)
            _buildPrayersShimmer()
          else if (prayers.isEmpty)
            _buildEmptyPrayers()
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: List.generate(prayers.length, (i) => _PrayerRow(
                  prayer: prayers[i],
                  showDivider: i < prayers.length - 1,
                )),
              ),
            ),
          if (_svc.prayerTimes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined,
                      color: AppColors.gold, size: 18),
                  const SizedBox(width: 10),
                  const Text('Sunrise',
                      style: TextStyle(fontFamily: 'Cairo',
                          fontSize: 14, color: AppColors.textDark)),
                  const Spacer(),
                  Text(_svc.sunriseFormatted,
                      style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayersShimmer() {
    return Container(
      height: 280,
      decoration: BoxDecoration(color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.gold),
            SizedBox(height: 12),
            Text('Calculating prayer times…',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                    color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPrayers() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Icon(Icons.access_time_rounded,
              color: AppColors.textLightGrey, size: 40),
          const SizedBox(height: 12),
          const Text('Prayer times unavailable',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                  color: AppColors.textGrey)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _svc.refresh,
            child: const Text('Tap to retry',
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.gold,
                )),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. Hijri Calendar — classy interactive redesign
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHijriCalendar() {
    final today = HijriDate.today;

    // Determine if the selected day has an occasion (for tooltip)
    final allOccasions = HijriDate.islamicOccasions(_viewHijriYear);
    final selectedOccasion = _selectedDay == null
        ? null
        : allOccasions.firstWhere(
          (o) =>
      o['month'] as int == _viewHijriMonth &&
          o['day'] as int == _selectedDay,
      orElse: () => {},
    );
    final hasOccasion =
        selectedOccasion != null && selectedOccasion.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section heading row ──
          Row(
            children: [
              const Text('Hijri Calendar',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  )),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${today.year} AH',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Unified dark calendar card ──
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2818), Color(0xFF1A3D28)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDarkest.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Top hero: today's date ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: big day number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${today.day}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            today.monthName.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Right: Arabic name + Gregorian pill
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            today.monthNameAr,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 26,
                              color: AppColors.gold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18)),
                            ),
                            child: Text(
                              DateFormat('EEE, d MMM y')
                                  .format(DateTime.now()),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppColors.textCream,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Thin gold divider ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.gold.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Month navigation ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _calNavBtn(Icons.chevron_left, () => setState(() {
                        _viewHijriMonth--;
                        _selectedDay = null;
                        if (_viewHijriMonth < 1) {
                          _viewHijriMonth = 12;
                          _viewHijriYear--;
                        }
                      })),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              HijriDate(
                                  day: 1,
                                  month: _viewHijriMonth,
                                  year: _viewHijriYear)
                                  .monthName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$_viewHijriYear AH',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _calNavBtn(Icons.chevron_right, () => setState(() {
                        _viewHijriMonth++;
                        _selectedDay = null;
                        if (_viewHijriMonth > 12) {
                          _viewHijriMonth = 1;
                          _viewHijriYear++;
                        }
                      })),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Day-of-week headers ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .asMap()
                        .entries
                        .map((e) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: e.key == 5
                                ? AppColors.gold
                                : Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Day grid ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildMonthGrid(today),
                ),

                // ── Selected-day tooltip (animates in below the grid) ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: _selectedDay == null
                      ? const SizedBox(height: 16)
                      : _buildDayTooltip(
                    _selectedDay!,
                    today,
                    hasOccasion ? selectedOccasion['name'] as String : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Upcoming Islamic occasions ──
          _buildIslamicOccasions(today),
        ],
      ),
    );
  }

  // ── Small nav button helper ──────────────────────────────────────────────
  Widget _calNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Day tooltip that appears below the grid ──────────────────────────────
  Widget _buildDayTooltip(int day, HijriDate today, String? occasionName) {
    final isToday = day == today.day &&
        _viewHijriMonth == today.month &&
        _viewHijriYear == today.year;

    // Approximate Gregorian date for the selected day
    final gregDate = _hijriToGregorian(day, _viewHijriMonth, _viewHijriYear);
    final gregFormatted = DateFormat('EEEE, d MMMM y').format(gregDate);

    final hDate = HijriDate(
        day: day, month: _viewHijriMonth, year: _viewHijriYear);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: occasionName != null
                ? AppColors.gold.withValues(alpha: 0.60)
                : Colors.white.withValues(alpha: 0.18),
            width: occasionName != null ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Day number circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: occasionName != null
                    ? AppColors.gold.withValues(alpha: 0.20)
                    : isToday
                    ? AppColors.primaryDark
                    : Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: occasionName != null
                      ? AppColors.gold
                      : isToday
                      ? AppColors.gold
                      : Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: occasionName != null
                        ? AppColors.gold
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (occasionName != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            occasionName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    hDate.formatted,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    gregFormatted,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            ),
            if (isToday)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.50)),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(HijriDate today) {
    final daysInMonth = _hijriDaysInMonth(_viewHijriMonth, _viewHijriYear);
    final firstDayGreg = _hijriToGregorian(1, _viewHijriMonth, _viewHijriYear);
    final startOffset  = (firstDayGreg.weekday % 7);
    final cells = startOffset + daysInMonth;
    final rows  = (cells / 7).ceil();

    // Occasion days in this month
    final occasionDays = HijriDate.islamicOccasions(_viewHijriYear)
        .where((o) => o['month'] as int == _viewHijriMonth)
        .map((o) => o['day'] as int)
        .toSet();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day       = cellIndex - startOffset + 1;

              if (day < 1 || day > daysInMonth) {
                return const SizedBox(width: 36, height: 40);
              }

              final isToday = day == today.day &&
                  _viewHijriMonth == today.month &&
                  _viewHijriYear  == today.year;
              final isSelected  = day == _selectedDay;
              final isFriday    = col == 5;
              final isOccasion  = occasionDays.contains(day);

              Color bgColor;
              Color textColor;
              Border? border;
              FontWeight fw = FontWeight.w400;

              if (isSelected && isToday) {
                bgColor   = AppColors.gold;
                textColor = AppColors.primaryDarkest;
                border    = null;
                fw        = FontWeight.w800;
              } else if (isSelected) {
                bgColor   = AppColors.gold.withValues(alpha: 0.22);
                textColor = AppColors.gold;
                border    = Border.all(color: AppColors.gold, width: 1.5);
                fw        = FontWeight.w700;
              } else if (isToday) {
                bgColor   = AppColors.primaryDark;
                textColor = AppColors.gold;
                border    = Border.all(color: AppColors.gold, width: 1.5);
                fw        = FontWeight.w800;
              } else if (isOccasion) {
                bgColor   = AppColors.gold.withValues(alpha: 0.15);
                textColor = AppColors.gold;
                border    = Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 1.2);
                fw        = FontWeight.w700;
              } else if (isFriday) {
                bgColor   = Colors.white.withValues(alpha: 0.06);
                textColor = AppColors.gold.withValues(alpha: 0.85);
                border    = null;
                fw        = FontWeight.w500;
              } else {
                bgColor   = Colors.transparent;
                textColor = Colors.white.withValues(alpha: 0.80);
                border    = null;
              }

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDay = (_selectedDay == day) ? null : day;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: border,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: fw,
                          color: textColor,
                        ),
                      ),
                      // Tiny dot indicator for occasion days
                      if (isOccasion && !isSelected)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildIslamicOccasions(HijriDate today) {
    final allOccasions = HijriDate.islamicOccasions(today.year);

    // Sort all occasions: upcoming first (from today), then wrap around to
    // start of year so nothing is hidden. Passed ones go to the bottom.
    final upcoming = <Map<String, dynamic>>[];
    final passed   = <Map<String, dynamic>>[];

    for (final o in allOccasions) {
      final om = o['month'] as int;
      final od = o['day']   as int;
      final isUpcoming = om > today.month ||
          (om == today.month && od >= today.day);
      if (isUpcoming) {
        upcoming.add(o);
      } else {
        passed.add(o);
      }
    }

    // Always-shown = first 2 upcoming; rest shown when expanded
    final sorted    = [...upcoming, ...passed];
    final showCount = _showAllOccasions ? sorted.length : 2;
    final visible   = sorted.take(showCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Text(
              'Islamic Occasions',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${allOccasions.length} events',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...visible.asMap().entries.map((entry) {
          final i    = entry.key;
          final o    = entry.value;
          final name  = o['name']  as String;
          final month = o['month'] as int;
          final day   = o['day']   as int;

          final hDate = HijriDate(day: day, month: month, year: today.year);
          final gregDate = _hijriToGregorian(day, month, today.year);
          final gregFormatted = DateFormat('d MMM').format(gregDate);

          final isUpcomingItem = month > today.month ||
              (month == today.month && day >= today.day);
          final isNear = month == today.month && (day - today.day).abs() <= 7;
          final isFirst = i == 0 && isUpcomingItem;

          // Special icon per event
          final icon = _occasionIcon(name);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: isFirst
                  ? const LinearGradient(
                colors: [Color(0xFF0D2818), Color(0xFF1A3D28)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: isFirst
                  ? null
                  : isNear
                  ? AppColors.primaryDark.withValues(alpha: 0.06)
                  : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFirst
                    ? AppColors.gold.withValues(alpha: 0.35)
                    : isNear
                    ? AppColors.primaryDark.withValues(alpha: 0.25)
                    : AppColors.borderLight,
                width: isFirst ? 1.2 : 1.0,
              ),
              boxShadow: isFirst
                  ? [
                BoxShadow(
                  color: AppColors.primaryDarkest.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  // Icon circle
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppColors.gold.withValues(alpha: 0.18)
                          : isNear
                          ? AppColors.primaryDark
                          : AppColors.bgCream,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isFirst
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${hDate.formatted}  ·  $gregFormatted',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: isFirst
                                ? Colors.white.withValues(alpha: 0.55)
                                : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge
                  if (isFirst)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDarkest,
                        ),
                      ),
                    )
                  else if (isNear)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldDark,
                        ),
                      ),
                    )
                  else if (!isUpcomingItem)
                      Text(
                        gregFormatted,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textLightGrey,
                        ),
                      ),
                ],
              ),
            ),
          );
        }),

        // ── Show more / show less button ──
        if (sorted.length > 2)
          GestureDetector(
            onTap: () => setState(() => _showAllOccasions = !_showAllOccasions),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showAllOccasions
                        ? 'Show Less'
                        : 'Show All ${sorted.length} Occasions',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _showAllOccasions
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 4),
      ],
    );
  }

  /// Returns an emoji icon for each Islamic occasion name
  String _occasionIcon(String name) {
    if (name.contains('New Year'))    return '🌙';
    if (name.contains('Ashura'))      return '🕌';
    if (name.contains('Mawlid'))      return '⭐';
    if (name.contains('Isra'))        return '✨';
    if (name.contains("Bara'ah"))     return '🤲';
    if (name.contains('Ramadan'))     return '🌙';
    if (name.contains('Qadr'))        return '✨';
    if (name.contains('Fitr'))        return '🎉';
    if (name.contains('Arafah'))      return '🕋';
    if (name.contains('Adha'))        return '🎊';
    return '📅';
  }

  // Helpers for calendar grid

  int _hijriDaysInMonth(int month, int year) {
    // Standard rule: odd months = 30 days, even months = 29 days
    // Month 12 in a leap year = 30 days
    if (month % 2 == 1) return 30;
    if (month == 12 && _isHijriLeapYear(year)) return 30;
    return 29;
  }

  bool _isHijriLeapYear(int year) {
    // 11 leap years in a 30-year cycle
    final r = year % 30;
    return [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29].contains(r);
  }

  DateTime _hijriToGregorian(int day, int month, int year) {
    // Convert Hijri to JDN then to DateTime
    final n  = day + (29.5001 * (month - 1)).ceil() + (year - 1) * 354 +
        (3 + 11 * year) ~/ 30 + 1948440 - 385;
    final jd = n.toDouble();

    // JDN to Gregorian
    var z  = jd.floor();
    final a = ((z - 1867216.25) / 36524.25).floor();
    z += 1 + a - (a ~/ 4);
    final b  = z + 1524;
    final c  = ((b - 122.1) / 365.25).floor();
    final d  = (365.25 * c).floor();
    final e  = ((b - d) / 30.6001).floor();
    final dd = b - d - (30.6001 * e).floor();
    final mm = e < 14 ? e - 1 : e - 13;
    final yy = mm > 2 ? c - 4716 : c - 4715;
    return DateTime(yy, mm, dd);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. Quick Tools (Qiblah + Tasbeeh only)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildQuickTools(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ibadah Tools',
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 18,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  imagePath: 'assets/images/Kaaba.png',
                  label: 'Qiblah',
                  subtitle: 'Find direction',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const QiblahScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolCard(
                  imagePath: 'assets/images/tasbih beads.png',
                  label: 'Tasbeeh',
                  subtitle: 'Dhikr counter',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const TasbeehScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required String imagePath,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox()),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33000000), Color(0xCC000000)],
                  ),
                ),
              ),
              Positioned(
                left: 12, right: 12, bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 15,
                          fontWeight: FontWeight.w700, color: Colors.white,
                        )),
                    Text(subtitle,
                        style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 11,
                          color: AppColors.textGreenMuted,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5. Sunnah Times
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSunnahTimes() {
    if (_svc.sunnahTimes == null) return const SizedBox.shrink();
    final midnight  = DateFormat('h:mm a')
        .format(_svc.sunnahTimes!.middleOfTheNight);
    final lastThird = DateFormat('h:mm a')
        .format(_svc.sunnahTimes!.lastThirdOfTheNight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.nightlight_round,
                    color: AppColors.gold, size: 18),
                SizedBox(width: 8),
                Text('Sunnah Times',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    )),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _sunnahItem(
                    'Middle of Night', midnight, Icons.bedtime_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _sunnahItem(
                    'Last Third (Tahajjud)', lastThird,
                    Icons.star_outline_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sunnahItem(String label, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryMid.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 16),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                color: AppColors.textGreenMuted, height: 1.3,
              )),
          const SizedBox(height: 3),
          Text(time,
              style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 15,
                fontWeight: FontWeight.w700, color: AppColors.textWhite,
              )),
        ],
      ),
    );
  }

  Widget _buildCalculationMethodStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calculation Method',
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w700, color: AppColors.textDark,
                )),
            const SizedBox(height: 14),
            _settingRow(
              icon: Icons.calculate_outlined,
              label: 'Method',
              value: _svc.calculationMethodName,
              onTap: () => _showMethodPicker(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Calculation Method',
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 18,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 16),
            ...kCalculationMethods.keys.map((name) => ListTile(
                  title: Text(name, style: const TextStyle(fontFamily: 'Cairo')),
                  trailing: _svc.calculationMethodName == name
                      ? const Icon(Icons.check_circle, color: AppColors.primaryDark)
                      : null,
                  onTap: () {
                    _svc.setCalculationMethod(name);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 6. Settings Strip — Madhab + Notifications only
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSettingsStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prayer Settings',
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w700, color: AppColors.textDark,
                )),
            const SizedBox(height: 4),
            const Text(
              'Customize your prayer settings below.',
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 14),
            // Madhab
            _settingRow(
              icon: Icons.school_outlined,
              label: 'Madhab',
              value: _svc.madhabName,
              onTap: () => _showMadhabPicker(context),
            ),
            const SizedBox(height: 10),
            // Notifications
            _settingRow(
              icon: Icons.notifications_outlined,
              label: 'Prayer Reminders',
              value: _svc.notifEnabled
                  ? '${_svc.reminderMinutes} min before'
                  : 'Off',
              onTap: () => _showNotifSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    color: AppColors.textDark,
                  )),
            ),
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.textGrey,
                )),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textLightGrey),
          ],
        ),
      ),
    );
  }

  void _showMadhabPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _MadhabPickerSheet(
        selected: _svc.madhabName,
        onSelect: (v) {
          _svc.setMadhab(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showNotifSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => NotifSettingsSheet(service: _svc),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PRAYER ROW
// ══════════════════════════════════════════════════════════════════════════════
class _PrayerRow extends StatelessWidget {
  final PrayerInfo prayer;
  final bool showDivider;
  const _PrayerRow({required this.prayer, required this.showDivider});

  static const _icons = {
    'Fajr':    Icons.wb_twilight,
    'Dhuhr':   Icons.wb_sunny_rounded,
    'Asr':     Icons.light_mode_outlined,
    'Maghrib': Icons.wb_twilight,
    'Isha':    Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context) {
    final isNext = prayer.isNext;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: isNext
              ? AppColors.primaryDark.withValues(alpha: 0.06)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isNext ? AppColors.primaryDark : AppColors.bgCream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _icons[prayer.name] ?? Icons.access_time,
                  color: isNext ? AppColors.gold : AppColors.textGrey,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(prayer.name,
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 15,
                      fontWeight:
                      isNext ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.textDark,
                    )),
              ),
              if (isNext)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: const Text('NEXT',
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldDark, letterSpacing: 0.5,
                      )),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(prayer.timeShort,
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 16,
                        fontWeight: isNext
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isNext
                            ? AppColors.primaryDark
                            : AppColors.textDark,
                      )),
                  Text(prayer.amPm,
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 10,
                        color: isNext
                            ? AppColors.gold
                            : AppColors.textGrey,
                      )),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MADHAB PICKER SHEET  — 4 schools with descriptions
// ══════════════════════════════════════════════════════════════════════════════
class _MadhabPickerSheet extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  const _MadhabPickerSheet(
      {required this.selected, required this.onSelect});

  static const _descriptions = {
    'Hanafi':
    "Asr begins when shadow = 2× object length. Named after Imam Abu Hanifa.",
    'Maliki':
    "Asr begins when shadow = 1× object length. Named after Imam Malik.",
    "Shafi'i":
    "Asr begins when shadow = 1× object length. Named after Imam al-Shafi'i.",
    'Hanbali':
    "Asr begins when shadow = 1× object length. Named after Imam Ahmad ibn Hanbal.",
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 44, height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Select Your Madhab',
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
        ),
        Container(height: 1, color: AppColors.borderLight),
        ...kMadhabs.keys.map((name) {
          final active = name == selected;
          return GestureDetector(
            onTap: () => onSelect(name),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primaryDark.withValues(alpha: 0.05)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.borderLight.withValues(alpha: 0.5)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20, height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active
                            ? AppColors.primaryDark
                            : AppColors.borderLight,
                        width: 2,
                      ),
                      color: active
                          ? AppColors.primaryDark
                          : Colors.transparent,
                    ),
                    child: active
                        ? const Icon(Icons.check,
                        color: AppColors.gold, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                              fontFamily: 'Cairo', fontSize: 15,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textDark,
                            )),
                        const SizedBox(height: 2),
                        Text(_descriptions[name] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Cairo', fontSize: 11,
                              color: AppColors.textGrey, height: 1.4,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION SETTINGS SHEET
// ══════════════════════════════════════════════════════════════════════════════
class NotifSettingsSheet extends StatefulWidget {
  final PrayerService service;
  const NotifSettingsSheet({super.key, required this.service});

  @override
  State<NotifSettingsSheet> createState() => _NotifSettingsSheetState();
}

class _NotifSettingsSheetState extends State<NotifSettingsSheet> {
  late bool _enabled;
  late int  _minutes;

  @override
  void initState() {
    super.initState();
    _enabled = widget.service.notifEnabled;
    _minutes = widget.service.reminderMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Prayer Reminders',
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Enable notifications',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                        color: AppColors.textDark)),
              ),
              Switch(
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
                activeThumbColor: AppColors.gold,
                activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
              ),
            ],
          ),
          if (_enabled) ...[
            const SizedBox(height: 16),
            Text('Remind me $_minutes minutes before',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
                    color: AppColors.textDark)),
            Slider(
              value: _minutes.toDouble(),
              min: 5, max: 30, divisions: 5,
              activeColor: AppColors.primaryDark,
              inactiveColor: AppColors.borderLight,
              label: '$_minutes min',
              onChanged: (v) => setState(() => _minutes = v.round()),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              widget.service.setNotificationsEnabled(_enabled);
              if (_enabled) widget.service.setReminderMinutes(_minutes);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text('Save',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 15,
                      fontWeight: FontWeight.w700, color: AppColors.gold,
                    )),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ARCH CLIPPER
// ══════════════════════════════════════════════════════════════════════════════
class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(0, h);
    path.lineTo(w, h);
    path.lineTo(w, h * 0.45);
    path.cubicTo(w, h * 0.10, w * 0.70, 0, w / 2, 0);
    path.cubicTo(w * 0.30, 0, 0, h * 0.10, 0, h * 0.45);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
