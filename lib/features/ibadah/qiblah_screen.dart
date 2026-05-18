import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  Position? _currentPosition;
  double? _compassHeading;
  bool _hasPermission = false;
  bool _isLoading = true;
  String _errorMessage = '';
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Kaaba coordinates
  static const double kaabaLat = 21.4225;
  static const double kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _checkLocationPermission();
    _startCompass();
  }

  Future<void> _checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Location services are disabled';
        _isLoading = false;
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _hasPermission = true;
    });

    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  void _startCompass() {
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _compassHeading = event.heading;
      });
    });
  }

  double _calculateDistance() {
    if (_currentPosition == null) return 0;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      kaabaLat,
      kaabaLon,
    ) / 1000; // Convert to km
  }

  double _calculateQiblahBearing() {
    if (_currentPosition == null) return 0;

    final lat1 = _currentPosition!.latitude * math.pi / 180;
    final lon1 = _currentPosition!.longitude * math.pi / 180;
    final lat2 = kaabaLat * math.pi / 180;
    final lon2 = kaabaLon * math.pi / 180;

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    final degrees = (bearing * 180 / math.pi + 360) % 360;

    return degrees;
  }

  String _formatDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return '${degrees.toStringAsFixed(0)}° N';
    if (degrees >= 22.5 && degrees < 67.5) return '${degrees.toStringAsFixed(0)}° NE';
    if (degrees >= 67.5 && degrees < 112.5) return '${degrees.toStringAsFixed(0)}° E';
    if (degrees >= 112.5 && degrees < 157.5) return '${degrees.toStringAsFixed(0)}° SE';
    if (degrees >= 157.5 && degrees < 202.5) return '${degrees.toStringAsFixed(0)}° S';
    if (degrees >= 202.5 && degrees < 247.5) return '${degrees.toStringAsFixed(0)}° SW';
    if (degrees >= 247.5 && degrees < 292.5) return '${degrees.toStringAsFixed(0)}° W';
    return '${degrees.toStringAsFixed(0)}° NW';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB4B9FF),
                Color(0xFFFFD1D1),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (!_hasPermission || _errorMessage.isNotEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5D5D5D)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB4B9FF),
                Color(0xFFFFD1D1),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 80,
                      color: Color(0xFF5D5D5D),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _initialize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A67B1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Enable Location',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D5D5D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Qibla',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5D5D5D),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB4B9FF),
              Color(0xFFFFD1D1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Mountain Background at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 100),
                painter: MountainPainter(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  _buildCompass(context),
                  const Spacer(),
                  _buildDirectionInfo(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionInfo() {
    final qiblahBearing = _calculateQiblahBearing();
    final directionText = _formatDirection(qiblahBearing);

    return Column(
      children: [
        Text(
          directionText,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _currentPosition == null
              ? 'Unable to get your location'
              : 'Distance: ${_calculateDistance().toStringAsFixed(0)} km',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D5D5D),
          ),
        ),
      ],
    );
  }

  Widget _buildCompass(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.75;
    final double heading = _compassHeading ?? 0;
    final double qiblahBearing = _calculateQiblahBearing();

    return Center(
      child: SizedBox(
        width: size + 80, // Extra space for Kaaba icon
        height: size + 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Compass Disk
            AnimatedRotation(
              turns: -heading / 360,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // The Compass Disk itself
                  Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: CompassDiskPainter(),
                    ),
                  ),
                  // Kaaba Icon positioned at the Qibla bearing
                  Transform.rotate(
                    angle: qiblahBearing * (math.pi / 180),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -size * 0.15, // Positioned on the edge
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/Kaaba.png',
                                width: 50,
                                height: 50,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.mosque,
                                  size: 40,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Small triangle pointer
                              CustomPaint(
                                size: const Size(12, 8),
                                painter: TrianglePainter(),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}

class CompassDiskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = const Color(0xFFD1D1D1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw degree markers
    for (int i = 0; i < 360; i += 2) {
      final double angle = i * (math.pi / 180);
      final bool isMajor = i % 45 == 0;
      final bool isMinor = i % 10 == 0;

      final double startRadius = radius - (isMajor ? 15 : (isMinor ? 10 : 5));
      final Offset start = Offset(
        center.dx + startRadius * math.cos(angle - math.pi / 2),
        center.dy + startRadius * math.sin(angle - math.pi / 2),
      );
      final Offset end = Offset(
        center.dx + radius * math.cos(angle - math.pi / 2),
        center.dy + radius * math.sin(angle - math.pi / 2),
      );

      paint.color = isMajor ? const Color(0xFF8E8E8E) : const Color(0xFFD1D1D1);
      paint.strokeWidth = isMajor ? 1.5 : 1;
      canvas.drawLine(start, end, paint);

      // Draw degree numbers for major markers
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: const TextStyle(
              color: Color(0xFF8E8E8E),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final double textRadius = radius - 25;
        final Offset textPos = Offset(
          center.dx + textRadius * math.cos(angle - math.pi / 2) - textPainter.width / 2,
          center.dy + textRadius * math.sin(angle - math.pi / 2) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textPos);
      }
    }

    // Draw cardinal needles
    _drawNeedle(canvas, center, radius * 0.6, 0, const Color(0xFF2E7D32)); // N - Green
    _drawNeedle(canvas, center, radius * 0.6, 180, const Color(0xFF1565C0)); // S - Blue
    
    // Draw cardinal labels
    _drawCardinalLetter(canvas, center, radius * 0.35, 0, 'N');
    _drawCardinalLetter(canvas, center, radius * 0.35, 180, 'S');
    _drawCardinalLetter(canvas, center, radius * 0.8, 90, 'E', color: const Color(0xFF8E8E8E));
    _drawCardinalLetter(canvas, center, radius * 0.8, 270, 'W', color: const Color(0xFF8E8E8E));
  }

  void _drawNeedle(Canvas canvas, Offset center, double length, double degrees, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double angle = degrees * (math.pi / 180) - math.pi / 2;
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.lineTo(
      center.dx + 12 * math.cos(angle + math.pi / 2),
      center.dy + 12 * math.sin(angle + math.pi / 2),
    );
    path.lineTo(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    path.lineTo(
      center.dx + 12 * math.cos(angle - math.pi / 2),
      center.dy + 12 * math.sin(angle - math.pi / 2),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCardinalLetter(Canvas canvas, Offset center, double distance, double degrees, String text, {Color color = Colors.white}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double angle = degrees * (math.pi / 180) - math.pi / 2;
    final Offset pos = Offset(
      center.dx + distance * math.cos(angle) - textPainter.width / 2,
      center.dy + distance * math.sin(angle) - textPainter.height / 2,
    );
    textPainter.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A67B1) // Darker blue for back mountains
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(size.width * 0.1, size.height * 0.6);
    path1.lineTo(size.width * 0.3, size.height * 0.8);
    path1.lineTo(size.width * 0.5, size.height * 0.4);
    path1.lineTo(size.width * 0.7, size.height * 0.7);
    path1.lineTo(size.width * 0.9, size.height * 0.5);
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    paint.color = const Color(0xFF7B88D1); // Lighter blue for front mountains
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(size.width * 0.2, size.height * 0.7);
    path2.lineTo(size.width * 0.4, size.height * 0.9);
    path2.lineTo(size.width * 0.6, size.height * 0.6);
    path2.lineTo(size.width * 0.8, size.height * 0.85);
    path2.lineTo(size.width, size.height * 0.75);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
