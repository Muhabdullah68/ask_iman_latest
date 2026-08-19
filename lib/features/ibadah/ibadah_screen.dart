import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/breakpoints.dart';
import '../../shared/widgets/islamic_background.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/notif_settings_sheet.dart';
import '../../core/services/prayer_service.dart';
import 'alarm_screen.dart';
import 'qiblah_screen.dart';
import 'tasbeeh_screen.dart';

class IbadahScreen extends StatefulWidget {
  const IbadahScreen({super.key, this.embedded = false});

  /// When true the internal app bar is hidden (used by the website shell,
  /// which provides its own site navigation).
  final bool embedded;

  @override
  State<IbadahScreen> createState() => _IbadahScreenState();
}

class _IbadahScreenState extends State<IbadahScreen> {
  final _svc = PrayerService();

  late int _viewHijriYear;
  late int _viewHijriMonth;
  int? _selectedDay;
  int _dhikrCount = 0;

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onUpdate);
    if (_svc.prayerTimes == null && !_svc.isLoading) _svc.refresh();
    final today = HijriDate.today;
    _viewHijriYear = today.year;
    _viewHijriMonth = today.month;
  }

  @override
  void dispose() {
    _svc.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? FigmaTokens.darkBg : FigmaTokens.surfaceBackground,
      appBar: widget.embedded ? null : const AskImanAppBar(),
      body: RefreshIndicator(
        color: FigmaTokens.accentGoldAmber,
        backgroundColor: FigmaTokens.brandDeepGreen,
        onRefresh: _svc.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: IslamicBackground(
            showPattern: true,
            child: ContentContainer(
              maxWidth: 1200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(),
                  const SizedBox(height: FigmaTokens.spacing6),
                  _buildHijriCalendarCard(),
                  const SizedBox(height: FigmaTokens.spacing6),
                  _buildDhikrCounterCard(),
                  const SizedBox(height: FigmaTokens.spacing6),
                  _buildUpcomingEventsList(),
                  const SizedBox(height: FigmaTokens.spacing6),
                  _buildToolsGrid(),
                  const SizedBox(height: FigmaTokens.spacing10),
                  _buildFooter(),
                  const SizedBox(height: FigmaTokens.spacing6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    final hijri = HijriDate.today;
    final gregYear = DateTime.now().year;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        boxShadow: FigmaTokens.cardShadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        child: Row(
          children: [
            Container(
              width: FigmaTokens.accentBarWidth,
              height: 140,
              color: FigmaTokens.accentGoldAmber,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 24, 20),
                decoration: BoxDecoration(
                  gradient: FigmaTokens.heroGradientLight,
                  color: FigmaTokens.surfacePanelMint,
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR DAILY IBADAH COMPANION',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.2,
                            color: FigmaTokens.brandDeepGreen
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: FigmaTokens.spacing2),
                        Text(
                          'Calendar & Tools',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: FigmaTokens.brandDeepGreen,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: FigmaTokens.spacing4),
                        Wrap(
                          spacing: FigmaTokens.spacing2,
                          runSpacing: FigmaTokens.spacing2,
                          children: [
                            _statPill('Hijri ${hijri.year}', true),
                            _statPill('$gregYear CE', false),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showSettingsSheet(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: FigmaTokens.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: FigmaTokens.borderHairline,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            size: 19,
                            color: FigmaTokens.brandDeepGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String text, bool isGold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isGold
            ? FigmaTokens.accentGoldSurface
            : FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        border: Border.all(
          color: isGold
              ? FigmaTokens.accentGoldAmber.withValues(alpha: 0.35)
              : FigmaTokens.borderHairline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGold ? Icons.calendar_month_rounded : Icons.today_rounded,
            size: 14,
            color: isGold
                ? FigmaTokens.accentGoldAmber
                : FigmaTokens.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isGold
                  ? FigmaTokens.accentGoldAmber
                  : FigmaTokens.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHijriCalendarCard() {
    final today = HijriDate.today;
    return Container(
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: FigmaTokens.borderHairline, width: 1),
        boxShadow: FigmaTokens.cardShadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: FigmaTokens.accentGoldAmber,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hijri Calendar',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.textHeading,
                  ),
                ),
                const Spacer(),
                _calNavBtn(
                  Icons.chevron_left,
                  () => setState(() {
                    _viewHijriMonth--;
                    _selectedDay = null;
                    if (_viewHijriMonth < 1) {
                      _viewHijriMonth = 12;
                      _viewHijriYear--;
                    }
                  }),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      HijriDate(
                        day: 1,
                        month: _viewHijriMonth,
                        year: _viewHijriYear,
                      ).monthName,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: FigmaTokens.textHeading,
                      ),
                    ),
                    Text(
                      '$_viewHijriYear AH',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 10,
                        color: FigmaTokens.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                _calNavBtn(
                  Icons.chevron_right,
                  () => setState(() {
                    _viewHijriMonth++;
                    _selectedDay = null;
                    if (_viewHijriMonth > 12) {
                      _viewHijriMonth = 1;
                      _viewHijriYear++;
                    }
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .asMap()
                  .entries
                  .map(
                    (e) => SizedBox(
                      width: 38,
                      child: Center(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: e.key == 5
                                ? FigmaTokens.accentGoldAmber
                                : FigmaTokens.textMuted,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),
            _buildMonthGrid(today),
          ],
        ),
      ),
    );
  }

  Widget _calNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: FigmaTokens.surfacePanelMint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: FigmaTokens.borderHairline),
        ),
        child: Icon(icon, color: FigmaTokens.brandDeepGreen, size: 18),
      ),
    );
  }

  Widget _buildMonthGrid(HijriDate today) {
    final daysInMonth = _hijriDaysInMonth(_viewHijriMonth, _viewHijriYear);
    final firstDayGreg = _hijriToGregorian(1, _viewHijriMonth, _viewHijriYear);
    final startOffset = (firstDayGreg.weekday % 7);
    final cells = startOffset + daysInMonth;
    final rows = (cells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - startOffset + 1;

              if (day < 1 || day > daysInMonth) {
                return const SizedBox(width: 38, height: 42);
              }

              final isToday =
                  day == today.day &&
                  _viewHijriMonth == today.month &&
                  _viewHijriYear == today.year;
              final isSelected = day == _selectedDay;
              final isFriday = col == 5;

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDay = (_selectedDay == day) ? null : day;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected && isToday
                        ? FigmaTokens.accentGoldAmber
                        : isSelected
                            ? FigmaTokens.accentGoldAmber.withValues(alpha: 0.15)
                            : isToday
                                ? FigmaTokens.accentGoldSurface
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday
                          ? FigmaTokens.accentGoldAmber
                          : isSelected
                              ? FigmaTokens.accentGoldAmber
                              : Colors.transparent,
                      width: isToday || isSelected ? 1.2 : 0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (isFriday)
                        Positioned(
                          left: 0,
                          top: 6,
                          bottom: 6,
                          child: Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: FigmaTokens.accentGoldAmber,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w800
                                : isFriday
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                            color: isSelected && isToday
                                ? Colors.white
                                : isToday || isSelected
                                    ? FigmaTokens.accentGoldAmber
                                    : isFriday
                                        ? FigmaTokens.accentGoldAmber
                                            .withValues(alpha: 0.8)
                                        : FigmaTokens.textBody,
                          ),
                        ),
                      ),
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

  Widget _buildDhikrCounterCard() {
    return Container(
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: FigmaTokens.borderHairline, width: 1),
        boxShadow: FigmaTokens.cardShadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Tap to count',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FigmaTokens.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _dhikrCount++),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FigmaTokens.surfacePanelMint,
                      FigmaTokens.accentGoldSurface,
                    ],
                  ),
                  border: Border.all(
                    color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SubhanAllah',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyArabicSerif,
                        fontSize: 14,
                        color: FigmaTokens.brandDeepGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_dhikrCount',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: FigmaTokens.accentGoldAmber,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _resetBtn(() => setState(() => _dhikrCount = 0)),
                const SizedBox(width: 12),
                _resetBtn(
                  () => setState(() {
                    if (_dhikrCount > 0) _dhikrCount--;
                  }),
                  icon: Icons.remove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resetBtn(VoidCallback onTap, {IconData icon = Icons.refresh}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: FigmaTokens.primaryButtonGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: FigmaTokens.accentGoldLight,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsList() {
    final today = HijriDate.today;
    final allOccasions = HijriDate.islamicOccasions(today.year);
    final upcoming = <Map<String, dynamic>>[];

    for (final o in allOccasions) {
      final om = o['month'] as int;
      final od = o['day'] as int;
      final isUpcoming =
          om > today.month || (om == today.month && od >= today.day);
      if (isUpcoming) upcoming.add(o);
    }
    upcoming.sort((a, b) {
      final ma = a['month'] as int;
      final mb = b['month'] as int;
      if (ma != mb) return ma.compareTo(mb);
      return (a['day'] as int).compareTo(b['day'] as int);
    });

    final visible = upcoming.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_rounded,
              color: FigmaTokens.accentGoldAmber,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Upcoming Events',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.textHeading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...visible.asMap().entries.map((entry) {
          final i = entry.key;
          final o = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < visible.length - 1 ? 10 : 0),
            child: _eventCard(o, today),
          );
        }),
      ],
    );
  }

  Widget _eventCard(Map<String, dynamic> o, HijriDate today) {
    final name = o['name'] as String;
    final month = o['month'] as int;
    final day = o['day'] as int;
    final hDate = HijriDate(day: day, month: month, year: today.year);
    final gregDate = _hijriToGregorian(day, month, today.year);
    final gregFormatted = DateFormat('d MMM y').format(gregDate);

    final todayGreg = DateTime.now();
    final diffDays = gregDate.difference(todayGreg).inDays;
    final daysText = diffDays > 0
        ? '$diffDays days away'
        : diffDays == 0
            ? 'Today'
            : '${diffDays.abs()} days ago';
    final icon = _occasionIcon(name);

    return Container(
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(color: FigmaTokens.borderHairline, width: 1),
        boxShadow: FigmaTokens.cardShadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FigmaTokens.accentGoldSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.2),
                ),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FigmaTokens.textHeading,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${hDate.formatted} · $gregFormatted',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 11,
                      color: FigmaTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: FigmaTokens.accentGoldSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                daysText,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FigmaTokens.accentGoldAmber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _occasionIcon(String name) {
    if (name.contains('New Year')) return '🌙';
    if (name.contains('Ashura')) return '🕌';
    if (name.contains('Mawlid')) return '⭐';
    if (name.contains('Isra')) return '✨';
    if (name.contains("Bara'ah")) return '🤲';
    if (name.contains('Ramadan')) return '🌙';
    if (name.contains('Qadr')) return '✨';
    if (name.contains('Fitr')) return '🎉';
    if (name.contains('Arafah')) return '🕋';
    if (name.contains('Adha')) return '🎊';
    return '📅';
  }

  Widget _buildToolsGrid() {
    final tools = [
      _ToolItem(
        title: 'Prayer Times',
        subtitle: 'Salah schedule',
        icon: Icons.access_time_filled_rounded,
        onTap: () => _showPrayerTimesSheet(),
      ),
      _ToolItem(
        title: 'Qibla Finder',
        subtitle: 'Kaaba direction',
        icon: Icons.explore_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QiblahScreen()),
        ),
      ),
      _ToolItem(
        title: 'Sunnah Duas',
        subtitle: 'Daily supplications',
        icon: Icons.menu_book_rounded,
        onTap: () => _showSunnahDuasSheet(),
      ),
      _ToolItem(
        title: '99 Names',
        subtitle: 'Asmaul Husna',
        icon: Icons.stars_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasbeehScreen()),
        ),
      ),
    ];

    if (context.isDesktop || context.isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: FigmaTokens.accentGoldAmber,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Ibadah Tools',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: FigmaTokens.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _toolCard(tools[0])),
              const SizedBox(width: 12),
              Expanded(child: _toolCard(tools[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _toolCard(tools[2])),
              const SizedBox(width: 12),
              Expanded(child: _toolCard(tools[3])),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grid_view_rounded,
              color: FigmaTokens.accentGoldAmber,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Ibadah Tools',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.textHeading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...tools.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _toolCardWide(t),
            )),
      ],
    );
  }

  Widget _toolCard(_ToolItem t) {
    return GestureDetector(
      onTap: t.onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          border: Border.all(color: FigmaTokens.borderHairline, width: 1),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: FigmaTokens.accentBarWidth,
                decoration: BoxDecoration(
                  color: FigmaTokens.accentGoldAmber,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(FigmaTokens.radiusCard),
                    bottomLeft: Radius.circular(FigmaTokens.radiusCard),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FigmaTokens.brandAccentSageStart,
                          FigmaTokens.brandAccentSageEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      t.icon,
                      color: FigmaTokens.accentGoldLight,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    t.title,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: FigmaTokens.textHeading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.subtitle,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 11,
                      color: FigmaTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolCardWide(_ToolItem t) {
    return GestureDetector(
      onTap: t.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
          border: Border.all(color: FigmaTokens.borderHairline, width: 1),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FigmaTokens.brandAccentSageStart,
                      FigmaTokens.brandAccentSageEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  t.icon,
                  color: FigmaTokens.accentGoldLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FigmaTokens.textHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.subtitle,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 11,
                        color: FigmaTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: FigmaTokens.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sheets & Settings ──────────────────────────────────────────────────────────

  void _showSheet(Widget child, {double maxWidth = 460}) {
    if (context.isTablet || context.isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: maxWidth,
              constraints: const BoxConstraints(maxHeight: 560),
              decoration: BoxDecoration(
                color: FigmaTokens.surfaceCard,
                borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
              ),
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: BoxDecoration(
            color: FigmaTokens.surfaceCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(child: child),
        ),
      );
    }
  }

  Widget _sheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: FigmaTokens.borderHairline,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    _showSheet(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _sheetHandle(),
            const SizedBox(height: 16),
            Text(
              'Ibadah Settings',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.textHeading,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prayer calculation method, reminders and alarm',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                color: FigmaTokens.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            _settingsSectionTitle('Calculation Method (Madhab)'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kMadhabs.keys.map((name) {
                final active = _svc.madhabName == name;
                return GestureDetector(
                  onTap: () {
                    _svc.setMadhab(name);
                    if (mounted) setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? FigmaTokens.brandDeepGreen
                          : FigmaTokens.surfacePanelMint,
                      borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
                      border: Border.all(
                        color: active
                            ? FigmaTokens.brandDeepGreen
                            : FigmaTokens.borderHairline,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? FigmaTokens.accentGoldLight
                            : FigmaTokens.textBody,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _settingsSectionTitle('Prayer Reminders'),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notification settings',
              subtitle: _svc.notifEnabled
                  ? 'Enabled · ${_svc.reminderMinutes} min before'
                  : 'Disabled',
              onTap: () => _showSheet(NotifSettingsSheet(service: _svc)),
            ),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.alarm_rounded,
              title: 'Prayer Alarm',
              subtitle: 'Manage prayer alarms & azan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlarmScreen()),
              ),
            ),
          ],
        ),
      ),
      maxWidth: 420,
    );
  }

  Widget _settingsSectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: FigmaTokens.fontFamilyUiSans,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: FigmaTokens.textMuted,
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FigmaTokens.surfacePanelMint,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
          border: Border.all(color: FigmaTokens.borderHairline, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: FigmaTokens.brandDeepGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FigmaTokens.textHeading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 11,
                      color: FigmaTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: FigmaTokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showPrayerTimesSheet() {
    final prayers = _svc.todayPrayers;
    _showSheet(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _sheetHandle(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: FigmaTokens.accentGoldAmber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Today's Prayer Times",
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.textHeading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                color: FigmaTokens.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            if (_svc.prayerTimes == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    _svc.isLoading
                        ? 'Calculating prayer times…'
                        : 'Unable to load prayer times.\nCheck your location settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 13,
                      color: FigmaTokens.textMuted,
                    ),
                  ),
                ),
              )
            else ...[
              if (prayers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Prayer times are not available yet.',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 13,
                        color: FigmaTokens.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...prayers.map(
                  (p) => _prayerRow(p.name, p.timeFormatted, p.isNext),
                ),
              const SizedBox(height: 6),
              _prayerRow('Sunrise', _svc.sunriseFormatted, false,
                  sunrise: true),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FigmaTokens.accentGoldSurface,
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
                ),
                child: Text(
                  'Method: ${_svc.madhabName} · Next: ${_svc.nextPrayerInfo?.name ?? '—'}',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FigmaTokens.brandDeepGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      maxWidth: 400,
    );
  }

  Widget _prayerRow(String name, String time, bool isNext,
      {bool sunrise = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isNext
            ? FigmaTokens.brandDeepGreen
            : FigmaTokens.surfacePanelMint,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(
          color: isNext
              ? FigmaTokens.brandDeepGreen
              : FigmaTokens.borderHairline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            sunrise ? Icons.wb_sunny_rounded : Icons.mosque_rounded,
            size: 18,
            color: isNext
                ? FigmaTokens.accentGoldAmber
                : FigmaTokens.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isNext
                    ? FigmaTokens.accentGoldLight
                    : FigmaTokens.textHeading,
              ),
            ),
          ),
          if (isNext) ...[
            Text(
              'NEXT',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: FigmaTokens.accentGoldAmber,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            time,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isNext
                  ? FigmaTokens.accentGoldLight
                  : FigmaTokens.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  void _showSunnahDuasSheet() {
    const duas = [
      (
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'Bismillah-ir-Rahman-ir-Rahim',
        'In the name of Allah, the Most Gracious, the Most Merciful.',
      ),
      (
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
        'Asbahna wa asbahal-mulku lillah',
        'We have reached the morning and all sovereignty belongs to Allah.',
      ),
      (
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
        "Allahumma inni as'alukal-huda wat-tuqa wal-'afafa wal-ghina",
        'O Allah, I ask You for guidance, piety, chastity and self-sufficiency.',
      ),
      (
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        'Subhanallahi wa bihamdih',
        'Glory be to Allah and all praise is due to Him.',
      ),
      (
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
        'Rabbana atina fid-dunya hasanah wa fil-akhirati hasanah',
        'Our Lord, give us good in this world and good in the Hereafter.',
      ),
      (
        'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
        "Allahumma a'inni 'ala dhikrika wa shukrika wa husni 'ibadatik",
        'O Allah, help me to remember You, thank You, and worship You well.',
      ),
    ];

    _showSheet(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _sheetHandle(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: FigmaTokens.accentGoldAmber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sunnah Duas',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.textHeading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Daily supplications from the Sunnah',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                color: FigmaTokens.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            ...duas.map(
              (d) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FigmaTokens.surfacePanelMint,
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
                  border: Border.all(
                    color: FigmaTokens.borderHairline,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.$1,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: FigmaTokens.brandDeepGreen,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d.$2,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: FigmaTokens.textBody,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.$3,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 12,
                        color: FigmaTokens.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      maxWidth: 440,
    );
  }

  Widget _buildFooter() {
    final isWide = context.isDesktop;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FigmaTokens.brandDeepGreen,
            FigmaTokens.brandMidGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _footerBrand()),
                const SizedBox(width: 24),
                Expanded(child: _footerCol('Explore', _exploreLinks())),
                const SizedBox(width: 24),
                Expanded(child: _footerCol('Community', _communityLinks())),
                const SizedBox(width: 24),
                Expanded(child: _footerCol('Contact', _contactLinks())),
              ],
            )
          else ...[
            _footerBrand(),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _footerCol('Explore', _exploreLinks())),
                const SizedBox(width: 20),
                Expanded(child: _footerCol('Community', _communityLinks())),
              ],
            ),
            const SizedBox(height: 20),
            _footerCol('Contact', _contactLinks()),
          ],
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            '© 2026 Ask Iman. All rights reserved.',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: FigmaTokens.accentGoldAmber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.mosque_rounded,
                color: FigmaTokens.brandDeepGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Ask Iman',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: FigmaTokens.accentGoldLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Your daily companion for Islamic learning, prayer guidance, and spiritual growth.',
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _socialIcon(Icons.facebook_rounded),
            const SizedBox(width: 8),
            _socialIcon(Icons.language_rounded),
            const SizedBox(width: 8),
            _socialIcon(Icons.email_rounded),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Icon(
        icon,
        color: FigmaTokens.accentGoldLight,
        size: 16,
      ),
    );
  }

  Widget _footerCol(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: FigmaTokens.accentGoldAmber,
          ),
        ),
        const SizedBox(height: 14),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _exploreLinks() => [
        'Learn Islam',
        'Quran Reading',
        'Hadith Library',
        'Daily Duas',
      ];
  List<String> _communityLinks() => [
        'Community Forum',
        'Local Mosques',
        'Islamic Events',
        'Charity Drive',
      ];
  List<String> _contactLinks() => [
        'support@askiman.app',
        'Privacy Policy',
        'Terms of Service',
        'Help Center',
      ];

  int _hijriDaysInMonth(int month, int year) {
    if (month % 2 == 1) return 30;
    if (month == 12 && _isHijriLeapYear(year)) return 30;
    return 29;
  }

  bool _isHijriLeapYear(int year) {
    final r = year % 30;
    return [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29].contains(r);
  }

  DateTime _hijriToGregorian(int day, int month, int year) {
    final n = day +
        (29.5001 * (month - 1)).ceil() +
        (year - 1) * 354 +
        (3 + 11 * year) ~/ 30 +
        1948440 -
        385;
    final jd = n.toDouble();
    var z = jd.floor();
    final a = ((z - 1867216.25) / 36524.25).floor();
    z += 1 + a - (a ~/ 4);
    final b = z + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();
    final dd = b - d - (30.6001 * e).floor();
    final mm = e < 14 ? e - 1 : e - 13;
    final yy = mm > 2 ? c - 4716 : c - 4715;
    return DateTime(yy, mm, dd);
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
