import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/tutorial_service.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/tooltip_overlay.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen>
    with SingleTickerProviderStateMixin {
  // ─── State ───────────────────────────────────────────────────────────────────
  Position? _currentPosition;
  double _compassHeading = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;

  // ─── Smooth rendering angles (what the Transform.rotate widgets use) ─────────
  double _displayNeedleAngle = 0;
  double _displayQiblahAngle = 0;

  // ─── Target angles (updated immediately on every compass/location event) ──────
  double _targetNeedleAngle = 0;
  double _targetQiblahAngle = 0;

  // ─── Whether we have received at least one compass reading ───────────────────
  bool _compassInitialized = false;

  /// Drives 60 fps smooth interpolation without an AnimationController.
  late Ticker _ticker;

  // ─── Prayer times ─────────────────────────────────────────────────────────────
  Map<String, dynamic>? _prayerTimes;

  // ─── Kaaba coordinates ────────────────────────────────────────────────────────
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  /// Cached bearing to Kaaba (degrees, [0, 360)).
  /// Updated whenever position changes so the Qiblah icon immediately
  /// reflects the new location.
  double _qiblahBearing = 0;

  // ─── THEME ───────────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF0A1F16);
  static const Color _border = Color(0xFF1D4533);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _green = Color(0xFF2D6A4F);
  static const Color _white = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _initialize();
    PrayerService().addListener(_onPrayerServiceUpdate);
    if (PrayerService().prayerTimes == null && !PrayerService().isLoading) {
      PrayerService().refresh();
    }
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    PrayerService().removeListener(_onPrayerServiceUpdate);
    _ticker.dispose();
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _onPrayerServiceUpdate() {
    if (mounted) _loadPrayerTimes();
  }

  void _loadPrayerTimes() {
    final service = PrayerService();
    final next = service.nextPrayerInfo;
    if (next != null) {
      final mins = next.minutesUntil();
      final hrs = mins ~/ 60;
      final rem = mins % 60;
      final countdownText = hrs > 0
          ? '${hrs}h ${rem}m remaining'
          : '${mins}m remaining';
      setState(() {
        _prayerTimes = {
          'nextPrayerName': next.name,
          'nextPrayerTime': next.timeFormatted,
          'remainingTime': countdownText,
        };
      });
    } else {
      setState(() => _prayerTimes = null);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SMOOTH ANIMATION — ticker callback (~60 fps)
  // ═══════════════════════════════════════════════════════════════════════════

  void _onTick(Duration _) {
    if (!mounted) return;

    final newNeedle = _lerpAngle(_displayNeedleAngle, _targetNeedleAngle, 0.15);
    final newQiblah = _lerpAngle(_displayQiblahAngle, _targetQiblahAngle, 0.15);

    final needleMoved =
        _shortestAngularDiff(newNeedle, _displayNeedleAngle).abs() > 0.01;
    final qiblahMoved =
        _shortestAngularDiff(newQiblah, _displayQiblahAngle).abs() > 0.01;

    if (needleMoved || qiblahMoved) {
      setState(() {
        _displayNeedleAngle = newNeedle;
        _displayQiblahAngle = newQiblah;
      });
    }
  }

  /// Lerp that always takes the shortest path around the circle.
  double _lerpAngle(double from, double to, double t) {
    return from + _shortestAngularDiff(to, from) * t;
  }

  /// Returns the signed shortest difference from [from] to [to] in (−180, 180].
  double _shortestAngularDiff(double to, double from) {
    double diff = ((to - from) % 360 + 360) % 360;
    if (diff > 180) diff -= 360;
    return diff;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initialize() async {
    // 1. Try to get last known position first (instant)
    final lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null && mounted) {
      setState(() {
        _currentPosition = lastPos;
        _qiblahBearing = _calculateQiblahBearing();
        _targetQiblahAngle = _qiblahBearing - _compassHeading;
        _isLoading = false;
      });
    }

    // 2. Start sensors immediately (they don't strictly require high-accuracy location to begin rendering the dial)
    _startCompass();
    _startLocationUpdates();

    // 3. Handle permissions and fresh location in background
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      // Check service and permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted && _currentPosition == null) {
          setState(() => _errorMessage = 'Location services are disabled.');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // PASSIVE CHECK: Only request if it's the FIRST time or we already have it.
      if (permission == LocationPermission.denied) {
        if (mounted && _currentPosition == null) {
          setState(() {
            _errorMessage = 'Location permission is required for Qiblah.';
            _isLoading = false;
          });
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted && _currentPosition == null) {
          setState(
            () =>
                _errorMessage = 'Location permissions are permanently denied.',
          );
        }
        return;
      }

      // If we have permission, get position
      _requestFreshLocation();
    } catch (e) {
      if (mounted && _currentPosition == null) {
        setState(() => _errorMessage = 'Error initializing location: $e');
      }
    }
  }

  /// Explicitly request permission and re-initialize. Use for the 'RETRY' button.
  Future<void> _requestPermissionAndRetry() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _initialize();
    } else {
      setState(() {
        _errorMessage = 'Location permission denied.';
        _isLoading = false;
      });
    }
  }

  void _requestFreshLocation() {
    Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        )
        .then((pos) {
          if (mounted) {
            setState(() {
              _currentPosition = pos;
              _qiblahBearing = _calculateQiblahBearing();
              _targetQiblahAngle = _qiblahBearing - _compassHeading;
              _isLoading = false;
            });
          }
        })
        .catchError((e) {
          if (mounted && _currentPosition == null) {
            setState(() => _isLoading = false);
          }
        });
  }

  void _startLocationUpdates() {
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // metres — only recalculate after moving 10 m
          ),
        ).listen((Position position) {
          if (!mounted) return;
          setState(() {
            _currentPosition = position;
            _qiblahBearing = _calculateQiblahBearing();
            // FIX: recompute with the CURRENT live compass heading every time
            // the location updates, so the Qiblah icon stays accurate.
            _targetQiblahAngle = _qiblahBearing - _compassHeading;
            _isLoading = false;
          });
        });
  }

  void _startCompass() {
    final compassStream = FlutterCompass.events;
    if (compassStream == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Your device does not support compass sensors.';
          _isLoading = false;
        });
      }
      return;
    }

    _compassSubscription = compassStream.listen(
      (CompassEvent event) {
        if (!mounted) return;

        final double? rawHeading = event.heading;
        if (rawHeading == null) return;

        // Normalize to [0, 360)
        final double heading = (rawHeading % 360 + 360) % 360;

        // ── Update target angles ────────────────────────────────────────────
        // The compass DIAL rotates opposite to the phone heading so that N
        // always points to screen-top.
        final double needleTarget = -heading;

        // The Qiblah ICON angle = absolute Qiblah bearing minus current heading.
        // This keeps the icon fixed on the Kaaba regardless of phone orientation.
        final double qiblahTarget = _qiblahBearing - heading;

        if (!_compassInitialized) {
          // Snap display angles to the first real reading so there is no
          // "spin from 0" artifact on startup.
          _displayNeedleAngle = needleTarget;
          _displayQiblahAngle = qiblahTarget;
          _compassInitialized = true;
          if (!_ticker.isActive) _ticker.start();
        }

        _targetNeedleAngle = needleTarget;
        _targetQiblahAngle = qiblahTarget;

        setState(() {
          _compassHeading = heading;
          _isLoading = false;
        });
      },
      onError: (Object e) {
        if (mounted) {
          setState(() => _errorMessage = 'Compass error: $e');
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CALCULATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  double _calculateDistance() {
    if (_currentPosition == null) return 5432;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _kaabaLat,
          _kaabaLon,
        ) /
        1000;
  }

  /// Great-circle initial bearing from the current position to the Kaaba.
  double _calculateQiblahBearing() {
    if (_currentPosition == null) return 0;

    final lat1 = _currentPosition!.latitude * math.pi / 180;
    final lon1 = _currentPosition!.longitude * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final lon2 = _kaabaLon * math.pi / 180;
    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  String _getDirectionLabel(double degrees) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((degrees + 22.5) / 45).floor() % 8];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // ── Loading ──────────────────────────────────────────────────────────────
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(child: CircularProgressIndicator(color: _white)),
      );
    }

    // ── Permission / sensor error ─────────────────────────────────────────────
    if (_errorMessage.isNotEmpty && _currentPosition == null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_off_rounded,
                  color: AppColors.gold,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: _white,
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Make sure your GPS is on and you have granted location permissions.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontFamily: 'Cairo',
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: _bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _requestPermissionAndRetry,
                    child: const Text(
                      'GRANT PERMISSION',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Main screen ───────────────────────────────────────────────────────────
    final qiblahBearing = _qiblahBearing;
    final heading = _compassHeading;
    final relativeAngle =
        (_shortestAngularDiff(qiblahBearing, heading) + 360) % 360;
    final distance = _calculateDistance();
    final isFacingQiblah = relativeAngle < 5 || relativeAngle > 355;

    return Scaffold(
      backgroundColor: _bg,
      appBar: const AskImanAppBar(showBackButton: true),
      body: TooltipOverlay(
        id: 'tut_qiblah',
        title: 'Qibla Finder',
        description: 'Find the Qibla direction from anywhere in the world',
        arrowDirection: TooltipArrowDirection.up,
        onNext: () {
          Navigator.maybePop(context);
          TutorialService.instance.next();
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Info card ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        'Distance',
                        '${distance.toStringAsFixed(0)} km',
                        Icons.location_on_outlined,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      _buildInfoItem(
                        'Qibla',
                        '${qiblahBearing.toStringAsFixed(1)}°',
                        Icons.explore_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),
              _buildCompassView(),
              const Spacer(flex: 1),

              // ── Heading label ──────────────────────────────────────────────
              Text(
                '${heading.toStringAsFixed(0)}° ${_getDirectionLabel(heading)}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: _white,
                ),
              ),
              const SizedBox(height: 4),

              // ── Facing label ───────────────────────────────────────────────
              Opacity(
                opacity: isFacingQiblah ? 1.0 : 0.7,
                child: Text(
                  isFacingQiblah
                      ? 'Facing Kaaba'
                      : 'Turn ${relativeAngle < 180 ? 'Right' : 'Left'}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: isFacingQiblah
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: isFacingQiblah
                        ? const Color(0xFF52B788)
                        : _white.withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Coordinates ────────────────────────────────────────────────
              Text(
                _currentPosition == null
                    ? 'Acquiring Location...'
                    : '${_currentPosition!.latitude.toStringAsFixed(2)}°, '
                          '${_currentPosition!.longitude.toStringAsFixed(2)}°',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _white.withValues(alpha: 0.5),
                ),
              ),

              // ── Next-prayer card ───────────────────────────────────────────
              if (_prayerTimes != null)
                Flexible(
                  child: _buildPrayerCard(
                    _prayerTimes!['nextPrayerName'] as String,
                    _prayerTimes!['nextPrayerTime'] as String,
                    _prayerTimes!['remainingTime'] as String,
                  ),
                ),

              const Spacer(flex: 3),

              // ── Accuracy progress bar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D281C),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: isFacingQiblah
                        ? 1.0
                        : (1 -
                                  (relativeAngle > 180
                                          ? 360 - relativeAngle
                                          : relativeAngle) /
                                      180)
                              .clamp(0.1, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isFacingQiblah ? const Color(0xFF52B788) : _gold,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _white.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: _white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _white,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCard(String name, String time, String remaining) {
    final loc = _currentPosition != null
        ? '${_currentPosition!.latitude.toStringAsFixed(2)}°, '
              '${_currentPosition!.longitude.toStringAsFixed(2)}°'
        : 'Current Location';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3D28), Color(0xFF122018)],
        ),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT PRAYER',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              color: _gold,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 40,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$time  •  $loc',
            style: const TextStyle(
              fontSize: 13,
              color: _green,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, color: _gold, size: 14),
                const SizedBox(width: 6),
                Text(
                  remaining,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB8D4BE),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── COMPASS VIEW ──────────────────────────────────────────────────────────
  //
  // Layer order (bottom → top):
  //   1. Static outer ring / background   — never moves
  //   2. Static dial                       — never moves
  //        • tick marks
  //        • star rose (N/S/E/W points + labels)
  //   3. Rotating needle                  — rotates by _displayNeedleAngle (-heading)
  //        • needle (green N half, dark S half)
  //   4. Qiblah icon                      — rotates by _displayQiblahAngle (_qiblahBearing - heading)
  //        • orbits on the rim, always pointing toward Mecca
  //   5. Center pivot cap                 — static decoration
  //
  Widget _buildCompassView() {
    final size = MediaQuery.of(context).size.width * 0.78;
    const markerSize = 60.0;

    return SizedBox(
      width: size + markerSize,
      height: size + markerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── 1. Static outer ring ─────────────────────────────────────────
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF1E3328), Color(0xFF0F1A14)],
                center: Alignment(-0.3, -0.3),
              ),
              border: Border.all(color: _border, width: 1.5),
            ),
          ),

          // ── 2. Static Dial with Tick Marks and Star Rose ──────────────────
          RepaintBoundary(
            child: CustomPaint(
              size: Size(size, size),
              painter: _TickMarkPainter(),
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              size: Size(size * 0.7, size * 0.7),
              painter: _StarRosePainter(),
            ),
          ),

          // ── 3. Rotating Compass Needle ────────────────────────────────────
          // The needle rotates independently to point to physical North/South
          Transform.rotate(
            angle: _displayNeedleAngle * math.pi / 180,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size(size * 0.55, size * 0.55),
                painter: _NeedlePainter(),
              ),
            ),
          ),

          // ── 4. Qiblah icon ───────────────────────────────────────────────
          // Rotates independently — angle = qiblahBearing - compassHeading,
          // so the icon stays fixed on Mecca as the phone turns.
          Transform.rotate(
            angle: _displayQiblahAngle * math.pi / 180,
            child: SizedBox(
              width: size + markerSize,
              height: size + markerSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: RepaintBoundary(
                      child: Image.asset(
                        'assets/images/qiblah_icon.png',
                        width: markerSize,
                        height: markerSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 5. Center pivot cap ───────────────────────────────────────────
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bg,
              border: Border.all(color: _gold, width: 1.5),
            ),
            child: const Center(
              child: CircleAvatar(radius: 3, backgroundColor: _gold),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PAINTERS  (shouldRepaint = false — Transform.rotate handles all motion)
// ═══════════════════════════════════════════════════════════════════════════════

class _TickMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;

    for (int i = 0; i < 360; i += 5) {
      final angle = (i - 90) * math.pi / 180;
      final major = i % 45 == 0;
      final mid = i % 15 == 0;
      final len = major
          ? 14.0
          : mid
          ? 9.0
          : 5.0;
      final strokeW = major ? 1.5 : 0.8;
      final color = major
          ? const Color(0xFFC9A84C).withValues(alpha: 0.5)
          : const Color(0xFF7AAB85).withValues(alpha: 0.2);

      canvas.drawLine(
        Offset(cx + (r - 1) * math.cos(angle), cy + (r - 1) * math.sin(angle)),
        Offset(
          cx + (r - len) * math.cos(angle),
          cy + (r - len) * math.sin(angle),
        ),
        Paint()
          ..color = color
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _StarRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    void drawPoint(double angleDeg, double length, double width, Color color) {
      final angle = (angleDeg - 90) * math.pi / 180;
      final perpAngle = angle + math.pi / 2;
      final tip = Offset(
        cx + length * math.cos(angle),
        cy + length * math.sin(angle),
      );
      final base1 = Offset(
        cx + width * math.cos(perpAngle),
        cy + width * math.sin(perpAngle),
      );
      final base2 = Offset(
        cx - width * math.cos(perpAngle),
        cy - width * math.sin(perpAngle),
      );

      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(base1.dx, base1.dy)
          ..lineTo(cx, cy)
          ..lineTo(base2.dx, base2.dy)
          ..close(),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    // Cardinal points (large)
    drawPoint(0, r * 0.85, r * 0.08, const Color(0xFFC9A84C)); // N — gold
    drawPoint(180, r * 0.85, r * 0.08, const Color(0xFF2E5038)); // S
    drawPoint(90, r * 0.85, r * 0.08, const Color(0xFF2E5038)); // E
    drawPoint(270, r * 0.85, r * 0.08, const Color(0xFF2E5038)); // W

    // Diagonal points (smaller)
    for (final a in [45.0, 135.0, 225.0, 315.0]) {
      drawPoint(
        a,
        r * 0.6,
        r * 0.045,
        const Color(0xFF3A5A42).withValues(alpha: 0.7),
      );
    }

    // N/S/E/W text labels
    const textStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );

    void drawLabel(String text, double angleDeg, Color color) {
      final angle = (angleDeg - 90) * math.pi / 180;
      final labelR = r * 0.68;
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          cx + labelR * math.cos(angle) - tp.width / 2,
          cy + labelR * math.sin(angle) - tp.height / 2,
        ),
      );
    }

    drawLabel('N', 0, const Color(0xFFC9A84C));
    drawLabel('S', 180, const Color(0xFF7AAB85));
    drawLabel('E', 90, const Color(0xFF7AAB85));
    drawLabel('W', 270, const Color(0xFF7AAB85));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final h = size.height / 2;
    final w = size.width / 12;

    // North half — bright emerald green (points UP on the rotated dial,
    // which always corresponds to geographic north on screen)
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - h * 0.98)
        ..lineTo(cx + w * 0.8, cy)
        ..lineTo(cx - w * 0.8, cy)
        ..close(),
      Paint()
        ..color = const Color(0xFF2ECC71)
        ..style = PaintingStyle.fill,
    );

    // Center-line highlight
    canvas.drawLine(
      Offset(cx, cy - h * 0.98),
      Offset(cx, cy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.0,
    );

    // South half — dark slate
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + h * 0.98)
        ..lineTo(cx + w * 0.8, cy)
        ..lineTo(cx - w * 0.8, cy)
        ..close(),
      Paint()
        ..color = const Color(0xFF2C3E50)
        ..style = PaintingStyle.fill,
    );

    // South depth shading
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + h * 0.95)
        ..lineTo(cx + w, cy)
        ..lineTo(cx, cy)
        ..close(),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );

    // Center pivot cap
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.6,
      Paint()
        ..color = const Color(0xFF0F1A14)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.6,
      Paint()
        ..color = const Color(0xFFC9A84C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
