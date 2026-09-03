// lib/web/pages/calendar_tools_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 3 · CALENDAR & TOOLS (WEB-NATIVE)
//
// Two-column layout: Hijri calendar (left) + Tasbeeh counter (right),
// upcoming Islamic events below with View More expansion, and prayer
// times listed at the bottom. No mobile screen embedding.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/web_animations.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/figma_tokens.dart';
import '../../core/services/prayer_service.dart';
import '../../core/utils/seo_meta.dart';
import '../widgets/web_footer.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MAIN PAGE
// ══════════════════════════════════════════════════════════════════════════════

class CalendarToolsPage extends StatefulWidget {
  const CalendarToolsPage({super.key});

  @override
  State<CalendarToolsPage> createState() => _CalendarToolsPageState();
}

class _CalendarToolsPageState extends State<CalendarToolsPage>
    with SingleTickerProviderStateMixin {
  // Calendar state
  late int _viewHijriMonth;
  late int _viewHijriYear;
  int? _selectedDay;

  // Tasbeeh state
  int _dhikrCount = 0;
  int _selectedDhikrIndex = 0;
  String _customDhikr = '';
  bool _showCustomField = false;
  int? _dhikrTarget;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Events state
  bool _eventsExpanded = false;

  static const _dhikrPresets = [
    'SubhanAllah',
    'Alhamdulillah',
    'Allahu Akbar',
    'La ilaha illallah',
    'Astaghfirullah',
  ];

  @override
  void initState() {
    super.initState();
    final today = HijriDate.today;
    _viewHijriYear = today.year;
    _viewHijriMonth = today.month;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );

    PrayerService().addListener(_onPrayerUpdate);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    PrayerService().removeListener(_onPrayerUpdate);
    super.dispose();
  }

  void _onPrayerUpdate() {
    if (mounted) setState(() {});
  }

  String get _currentDhikrName =>
      _showCustomField && _customDhikr.isNotEmpty
          ? _customDhikr
          : _dhikrPresets[_selectedDhikrIndex];

  void _incrementDhikr() {
    setState(() => _dhikrCount++);
    _pulseController.forward(from: 0);
  }

  void _decrementDhikr() {
    if (_dhikrCount > 0) setState(() => _dhikrCount--);
  }

  void _resetDhikr() => setState(() => _dhikrCount = 0);

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    setPageTitle('Calendar & Tools — Hijri, Prayer Times · Ask Iman');
    return Container(
      color: figma.surfaceBackground,
      child: SingleChildScrollView(
        physics: webScrollPhysics,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroSection(),
            const SizedBox(height: 28),
            _buildMainContent(),
            const SizedBox(height: 32),
            _buildUpcomingEvents(),
            const SizedBox(height: 32),
            _buildPrayerTimes(),
            const SizedBox(height: 48),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 800;
              final calendarWidget = _HijriCalendarWidget(
                viewMonth: _viewHijriMonth,
                viewYear: _viewHijriYear,
                selectedDay: _selectedDay,
                onPrevMonth: () => setState(() {
                  _viewHijriMonth--;
                  _selectedDay = null;
                  if (_viewHijriMonth < 1) {
                    _viewHijriMonth = 12;
                    _viewHijriYear--;
                  }
                }),
                onNextMonth: () => setState(() {
                  _viewHijriMonth++;
                  _selectedDay = null;
                  if (_viewHijriMonth > 12) {
                    _viewHijriMonth = 1;
                    _viewHijriYear++;
                  }
                }),
                onDayTap: (day) => setState(() {
                  _selectedDay = (_selectedDay == day) ? null : day;
                }),
              );

              final tasbeehWidget = _TasbeehCounterWidget(
                count: _dhikrCount,
                dhikrName: _currentDhikrName,
                selectedIndex: _selectedDhikrIndex,
                showCustom: _showCustomField,
                customText: _customDhikr,
                target: _dhikrTarget,
                pulseAnimation: _pulseAnimation,
                onDhikrSelect: (i) => setState(() {
                  _selectedDhikrIndex = i;
                  _showCustomField = false;
                }),
                onCustomToggle: () => setState(() {
                  _showCustomField = !_showCustomField;
                }),
                onCustomChanged: (v) => setState(() => _customDhikr = v),
                onIncrement: _incrementDhikr,
                onDecrement: _decrementDhikr,
                onReset: _resetDhikr,
                onTargetChanged: (v) => setState(() {
                  _dhikrTarget = v;
                }),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: calendarWidget),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: tasbeehWidget.animate().fadeIn(duration: 400.ms).slideY(begin: 0.05)),
                  ],
                );
              }

              return Column(
                children: [
                  calendarWidget,
                  const SizedBox(height: 24),
                  tasbeehWidget.animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child:           _UpcomingEventsWidget(
            expanded: _eventsExpanded,
            onToggleExpand: () => setState(() => _eventsExpanded = true),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: const _PrayerTimesWidget(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO
// ══════════════════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final hijri = HijriDate.today;
    final gregYear = DateTime.now().year;
    return Container(
      decoration: const BoxDecoration(gradient: FigmaTokens.heroGradientDark),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR DAILY IBADAH COMPANION',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.4,
                        color: figma.accentGoldLight.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Calendar & Tools',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: FigmaTokens.textOnDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hijri calendar · Tasbeeh counter · Prayer times',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _HeroPill(
                          icon: Icons.calendar_month_rounded,
                          label: 'Hijri ${hijri.year}',
                          gold: true,
                        ),
                        _HeroPill(
                          icon: Icons.today_rounded,
                          label: '$gregYear CE',
                          gold: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool gold;
  const _HeroPill({required this.icon, required this.label, required this.gold});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: gold
            ? figma.accentGoldSurface
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        border: Border.all(
          color: gold
              ? figma.accentGoldAmber.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: gold
                ? figma.accentGoldAmber
                : figma.accentGoldLight,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: gold
                  ? figma.accentGoldAmber
                  : FigmaTokens.textOnDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HIJRI CALENDAR WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class _HijriCalendarWidget extends StatelessWidget {
  final int viewMonth;
  final int viewYear;
  final int? selectedDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int> onDayTap;

  const _HijriCalendarWidget({
    required this.viewMonth,
    required this.viewYear,
    required this.selectedDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final today = HijriDate.today;
    return Container(
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
        boxShadow: figma.cardShadows,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: figma.accentGoldAmber,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Hijri Calendar',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: figma.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CalNavBtn(icon: Icons.chevron_left, onTap: onPrevMonth),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    HijriDate(day: 1, month: viewMonth, year: viewYear)
                        .monthName,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: figma.textHeading,
                    ),
                  ),
                  Text(
                    '$viewYear AH',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 12,
                      color: figma.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              _CalNavBtn(icon: Icons.chevron_right, onTap: onNextMonth),
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
                    width: 40,
                    child: Center(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: e.key == 5
                              ? figma.accentGoldAmber
                              : figma.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          _MonthGrid(
            viewMonth: viewMonth,
            viewYear: viewYear,
            today: today,
            selectedDay: selectedDay,
            onDayTap: onDayTap,
          ),
          const SizedBox(height: 16),
          if (selectedDay != null) ...[
            Divider(height: 1, color: figma.borderHairline),
            const SizedBox(height: 14),
            _SelectedDayInfo(
              hijriDay: selectedDay!,
              hijriMonth: viewMonth,
              hijriYear: viewYear,
            ),
          ],
        ],
      ),
    );
  }
}

class _CalNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CalNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Material(
      color: figma.surfacePanelMint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: figma.borderHairline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: figma.accentGoldSurface,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: FigmaTokens.brandDeepGreen, size: 20),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final int viewMonth;
  final int viewYear;
  final HijriDate today;
  final int? selectedDay;
  final ValueChanged<int> onDayTap;

  const _MonthGrid({
    required this.viewMonth,
    required this.viewYear,
    required this.today,
    required this.selectedDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final daysInMonth = _hijriDaysInMonth(viewMonth, viewYear);
    final firstDayGreg = _hijriToGregorian(1, viewMonth, viewYear);
    final startOffset = firstDayGreg.weekday % 7;
    final cells = startOffset + daysInMonth;
    final rows = (cells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - startOffset + 1;
              if (day < 1 || day > daysInMonth) {
                return const SizedBox(width: 40, height: 44);
              }

              final isToday = day == today.day &&
                  viewMonth == today.month &&
                  viewYear == today.year;
              final isSelected = day == selectedDay;
              final isFriday = col == 5;

              return GestureDetector(
                onTap: () => onDayTap(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected && isToday
                        ? figma.accentGoldAmber
                        : isSelected
                            ? figma.accentGoldAmber.withValues(
                                alpha: 0.15,
                              )
                            : isToday
                                ? figma.accentGoldSurface
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday || isSelected
                          ? figma.accentGoldAmber
                          : Colors.transparent,
                      width: isToday || isSelected ? 1.2 : 0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (isFriday)
                        Positioned(
                          left: 2,
                          top: 8,
                          bottom: 8,
                          child: Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: figma.accentGoldAmber,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 14,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected && isToday
                                ? Colors.white
                                : isToday || isSelected
                                    ? figma.accentGoldAmber
                                    : isFriday
                                        ? figma.accentGoldAmber
                                            .withValues(alpha: 0.8)
                                        : figma.textBody,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: row * 30 + col * 15)).fadeIn(duration: 300.ms).slideY(begin: 0.1);
            }),
          ),
        );
      }),
    );
  }
}

class _SelectedDayInfo extends StatelessWidget {
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  const _SelectedDayInfo({
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final hijri = HijriDate(day: hijriDay, month: hijriMonth, year: hijriYear);
    final gregDate = _hijriToGregorian(hijriDay, hijriMonth, hijriYear);
    final gregFormatted = DateFormat('d MMMM yyyy').format(gregDate);

    return Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 16, color: figma.accentGoldAmber),
        const SizedBox(width: 8),
        Text(
          '${hijri.formatted}  ·  $gregFormatted',
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: figma.textHeading,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TASBEEH COUNTER WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class _TasbeehCounterWidget extends StatelessWidget {
  final int count;
  final String dhikrName;
  final int selectedIndex;
  final bool showCustom;
  final String customText;
  final int? target;
  final Animation<double> pulseAnimation;
  final ValueChanged<int> onDhikrSelect;
  final VoidCallback onCustomToggle;
  final ValueChanged<String> onCustomChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;
  final ValueChanged<int?> onTargetChanged;

  const _TasbeehCounterWidget({
    required this.count,
    required this.dhikrName,
    required this.selectedIndex,
    required this.showCustom,
    required this.customText,
    required this.target,
    required this.pulseAnimation,
    required this.onDhikrSelect,
    required this.onCustomToggle,
    required this.onCustomChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
    required this.onTargetChanged,
  });

  static const _dhikrPresets = [
    'SubhanAllah',
    'Alhamdulillah',
    'Allahu Akbar',
    'La ilaha illallah',
    'Astaghfirullah',
  ];

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final progress =
        target != null && target! > 0 ? (count / target!).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
        boxShadow: figma.cardShadows,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: figma.accentGoldAmber,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Tasbeeh Counter',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: figma.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dhikr preset pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _dhikrPresets.length; i++)
                _DhikrPill(
                  label: _dhikrPresets[i],
                  selected: !showCustom && i == selectedIndex,
                  onTap: () => onDhikrSelect(i),
                ),
              _DhikrPill(
                label: 'Custom',
                selected: showCustom,
                onTap: onCustomToggle,
                icon: Icons.edit_rounded,
              ),
            ],
          ),
          if (showCustom) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: onCustomChanged,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 14,
                color: figma.textHeading,
              ),
              decoration: InputDecoration(
                hintText: 'Type your dhikr…',
                hintStyle: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 14,
                  color: figma.textMuted.withValues(alpha: 0.8),
                ),
                filled: true,
                fillColor: figma.surfaceBackground,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
                  borderSide: const BorderSide(
                    color: FigmaTokens.brandMidGreen,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Counter circle
          Center(
            child: GestureDetector(
              onTap: onIncrement,
              child: AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        figma.surfacePanelMint,
                        figma.accentGoldSurface,
                      ],
                    ),
                    border: Border.all(
                      color: figma.accentGoldAmber.withValues(alpha: 0.4),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: figma.accentGoldAmber.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dhikrName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: FigmaTokens.fontFamilyArabicSerif,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: FigmaTokens.brandDeepGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: figma.accentGoldAmber,
                          height: 1,
                        ),
                      ),
                      if (target != null && target! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '/ $target',
                            style: TextStyle(
                              fontFamily: FigmaTokens.fontFamilyUiSans,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: figma.textMuted.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (target != null && target! > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: figma.surfaceBackground,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? FigmaTokens.brandMidGreen
                      : figma.accentGoldAmber,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterBtn(
                icon: Icons.refresh_rounded,
                onTap: onReset,
                tooltip: 'Reset',
              ),
              const SizedBox(width: 14),
              _CounterBtn(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
                tooltip: 'Decrement',
              ),
              const SizedBox(width: 14),
              _TargetDropdown(
                currentTarget: target,
                onChanged: onTargetChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Tap the circle to count',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                color: figma.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const _DhikrPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Material(
      color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        side: BorderSide(
          color: selected
              ? FigmaTokens.brandMidGreen
              : figma.borderHairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        hoverColor: selected
            ? FigmaTokens.brandMidGreen
            : figma.surfacePanelMint,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color:
                      selected ? FigmaTokens.textOnDark : figma.textBody,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? FigmaTokens.textOnDark
                      : figma.textBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _CounterBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: FigmaTokens.primaryButtonGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Icon(icon, color: figma.accentGoldLight, size: 22),
          ),
        ),
      ),
    );
  }
}

class _TargetDropdown extends StatelessWidget {
  final int? currentTarget;
  final ValueChanged<int?> onChanged;
  const _TargetDropdown({required this.currentTarget, required this.onChanged});

  static const _targets = [0, 33, 50, 100, 500, 1000];

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: figma.surfacePanelMint,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        border: Border.all(color: figma.borderHairline),
      ),
      child: DropdownButton<int?>(
        value: _targets.contains(currentTarget) ? currentTarget : 0,
        underline: const SizedBox.shrink(),
        isDense: true,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          size: 18,
          color: FigmaTokens.brandDeepGreen,
        ),
        style: TextStyle(
          fontFamily: FigmaTokens.fontFamilyUiSans,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: figma.textHeading,
        ),
        items: [
          const DropdownMenuItem(
            value: 0,
            child: Text('No target'),
          ),
          for (final t in _targets.where((t) => t > 0))
            DropdownMenuItem(value: t, child: Text('Target $t')),
        ],
        onChanged: (v) => onChanged(v == 0 ? null : v),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// UPCOMING EVENTS
// ══════════════════════════════════════════════════════════════════════════════

class _UpcomingEventsWidget extends StatelessWidget {
  final bool expanded;
  final VoidCallback? onToggleExpand;
  const _UpcomingEventsWidget({required this.expanded, this.onToggleExpand});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final today = HijriDate.today;
    final allOccasions = HijriDate.islamicOccasions(today.year);

    // Filter to events within next 1 year
    final now = DateTime.now();
    final oneYearLater = now.add(const Duration(days: 365));

    final upcoming = <Map<String, dynamic>>[];
    for (final o in allOccasions) {
      final om = o['month'] as int;
      final od = o['day'] as int;
      final greg = _hijriToGregorian(od, om, today.year);
      if (greg.isAfter(now.subtract(const Duration(days: 1))) &&
          greg.isBefore(oneYearLater)) {
        upcoming.add({...o, 'gregDate': greg});
      }
    }
    // Also check next Hijri year's events
    final nextYearOccasions = HijriDate.islamicOccasions(today.year + 1);
    for (final o in nextYearOccasions) {
      final om = o['month'] as int;
      final od = o['day'] as int;
      final greg = _hijriToGregorian(od, om, today.year + 1);
      if (greg.isAfter(now) && greg.isBefore(oneYearLater)) {
        upcoming.add({...o, 'gregDate': greg});
      }
    }

    upcoming.sort((a, b) {
      final ga = a['gregDate'] as DateTime;
      final gb = b['gregDate'] as DateTime;
      return ga.compareTo(gb);
    });

    final visible = expanded ? upcoming : upcoming.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
        boxShadow: figma.cardShadows,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                color: figma.accentGoldAmber,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Upcoming Islamic Events',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: figma.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No upcoming events in the next year.',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 14,
                    color: figma.textMuted.withValues(alpha: 0.8),
                  ),
                ),
              ),
            )
          else
            ...visible.asMap().entries.map((entry) {
              final o = entry.value;
              final greg = o['gregDate'] as DateTime;
              final diffDays = greg.difference(now).inDays;
              final daysText = diffDays > 0
                  ? '$diffDays days away'
                  : diffDays == 0
                      ? 'Today'
                      : '${diffDays.abs()} days ago';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EventCard(
                  name: o['name'] as String,
                  month: o['month'] as int,
                  day: o['day'] as int,
                  hijriYear: today.year,
                  gregDate: greg,
                  daysText: daysText,
                ),
              );
            }),
          if (upcoming.length > 3 && !expanded) ...[
            const SizedBox(height: 4),
            Center(
              child: TextButton.icon(
                onPressed: onToggleExpand,
                icon: const Icon(Icons.expand_more_rounded, size: 20),
                label: const Text('View More'),
                style: TextButton.styleFrom(
                  foregroundColor: FigmaTokens.brandMidGreen,
                  textStyle: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String name;
  final int month;
  final int day;
  final int hijriYear;
  final DateTime gregDate;
  final String daysText;

  const _EventCard({
    required this.name,
    required this.month,
    required this.day,
    required this.hijriYear,
    required this.gregDate,
    required this.daysText,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final hDate = HijriDate(day: day, month: month, year: hijriYear);
    final gregFormatted = DateFormat('d MMM y').format(gregDate);
    final icon = _occasionIcon(name);

    return Container(
      decoration: BoxDecoration(
        color: figma.surfaceBackground,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(color: figma.borderHairline),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: figma.accentGoldSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: figma.accentGoldAmber.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
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
                    color: figma.textHeading,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${hDate.formatted} · $gregFormatted',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 11,
                    color: figma.textMuted.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: figma.accentGoldSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: figma.accentGoldAmber.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              daysText,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: figma.accentGoldAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _occasionIcon(String name) {
  if (name.contains('New Year')) return '\u{1F319}';
  if (name.contains('Ashura')) return '\u{1F54C}';
  if (name.contains('Mawlid')) return '\u2B50';
  if (name.contains('Isra')) return '\u2728';
  if (name.contains("Bara'ah")) return '\u{1F932}';
  if (name.contains('Ramadan')) return '\u{1F319}';
  if (name.contains('Qadr')) return '\u2728';
  if (name.contains('Fitr')) return '\u{1F389}';
  if (name.contains('Arafah')) return '\u{1F54B}';
  if (name.contains('Adha')) return '\u{1F38A}';
  return '\u{1F4C5}';
}

// ══════════════════════════════════════════════════════════════════════════════
// PRAYER TIMES
// ══════════════════════════════════════════════════════════════════════════════

class _PrayerTimesWidget extends StatelessWidget {
  const _PrayerTimesWidget();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final svc = PrayerService();
    final prayers = svc.todayPrayers;

    return Container(
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
        boxShadow: figma.cardShadows,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                color: figma.accentGoldAmber,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                "Today's Prayer Times",
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: figma.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              color: figma.textMuted.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          if (prayers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 40,
                      color: figma.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enable location to see prayer times.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 14,
                        color: figma.textMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            for (final p in prayers) ...[
              _PrayerRow(
                name: p.name,
                time: p.timeFormatted,
                isNext: p.isNext,
              ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: prayers.indexOf(p) * 60)).slideY(begin: 0.08),
              if (p != prayers.last)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: figma.borderHairline,
                  ),
                ),
            ],
            // Sunrise row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: figma.borderHairline,
              ),
            ),
            _PrayerRow(
              name: 'Sunrise',
              time: svc.sunriseFormatted,
              isNext: false,
              isSunrise: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final bool isNext;
  final bool isSunrise;
  const _PrayerRow({
    required this.name,
    required this.time,
    required this.isNext,
    this.isSunrise = false,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: isNext
          ? BoxDecoration(
              color: figma.accentGoldSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
              border: Border.all(
                color: figma.accentGoldAmber.withValues(alpha: 0.3),
              ),
            )
          : null,
      child: Row(
        children: [
          if (isNext) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: figma.accentGoldAmber,
                borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
              ),
              child: const Text(
                'NEXT',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ] else if (isSunrise) ...[
            const SizedBox(width: 64),
          ],
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 15,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                color: isSunrise
                    ? figma.textMuted
                    : isNext
                        ? figma.textHeading
                        : figma.textBody,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 16,
              fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
              color: isNext
                  ? figma.accentGoldAmber
                  : isSunrise
                      ? figma.textMuted
                      : figma.textHeading,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HIJRI ↔ GREGORIAN HELPERS (duplicated from IbadahScreen)
// ══════════════════════════════════════════════════════════════════════════════

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

// ══════════════════════════════════════════════════════════════════════════════
// TASBEEH DEEP-LINK PAGE (kept for route compatibility)
// ══════════════════════════════════════════════════════════════════════════════

class TasbeehPage extends StatelessWidget {
  const TasbeehPage({super.key});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    setPageTitle('Tasbeeh — Digital Dhikr Counter · Ask Iman');
    return Container(
      color: figma.surfaceBackground,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
        physics: webScrollPhysics,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      gradient: figma.heroGradient,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasbeeh',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: figma.textHeading,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Count your adhkar with the digital dhikr counter.',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 14,
                            color: figma.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: _TasbeehPageBody(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const WebFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasbeehPageBody extends StatefulWidget {
  @override
  State<_TasbeehPageBody> createState() => _TasbeehPageBodyState();
}

class _TasbeehPageBodyState extends State<_TasbeehPageBody>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _selectedIndex = 0;
  String _customDhikr = '';
  bool _showCustom = false;
  int? _target;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _dhikrPresets = [
    'SubhanAllah',
    'Alhamdulillah',
    'Allahu Akbar',
    'La ilaha illallah',
    'Astaghfirullah',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _currentName =>
      _showCustom && _customDhikr.isNotEmpty
          ? _customDhikr
          : _dhikrPresets[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return _TasbeehCounterWidget(
      count: _count,
      dhikrName: _currentName,
      selectedIndex: _selectedIndex,
      showCustom: _showCustom,
      customText: _customDhikr,
      target: _target,
      pulseAnimation: _pulseAnimation,
      onDhikrSelect: (i) => setState(() {
        _selectedIndex = i;
        _showCustom = false;
      }),
      onCustomToggle: () => setState(() => _showCustom = !_showCustom),
      onCustomChanged: (v) => setState(() => _customDhikr = v),
      onIncrement: () {
        setState(() => _count++);
        _pulseController.forward(from: 0);
      },
      onDecrement: () {
        if (_count > 0) setState(() => _count--);
      },
      onReset: () => setState(() => _count = 0),
      onTargetChanged: (v) => setState(() => _target = v),
    );
  }
}
