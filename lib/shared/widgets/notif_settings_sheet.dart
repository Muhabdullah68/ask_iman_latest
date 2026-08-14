import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/services/prayer_service.dart';

class NotifSettingsSheet extends StatefulWidget {
  final PrayerService service;
  const NotifSettingsSheet({super.key, required this.service});

  @override
  State<NotifSettingsSheet> createState() => _NotifSettingsSheetState();
}

class _NotifSettingsSheetState extends State<NotifSettingsSheet> {
  late bool _enabled;
  late int _minutes;

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
          const Text(
            'Prayer Reminders',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: FigmaTokens.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Enable notifications',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: FigmaTokens.textBody,
                  ),
                ),
              ),
              Switch(
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
                activeThumbColor: FigmaTokens.accentGoldAmber,
                activeTrackColor: FigmaTokens.accentGoldLight,
              ),
            ],
          ),
          if (_enabled) ...[
            const SizedBox(height: 16),
            Text(
              'Remind me $_minutes minutes before',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: FigmaTokens.textBody,
              ),
            ),
            Slider(
              value: _minutes.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              activeColor: FigmaTokens.brandDeepGreen,
              inactiveColor: FigmaTokens.borderHairline,
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
                gradient: FigmaTokens.primaryButtonGradient,
                borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
              ),
              child: const Center(
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FigmaTokens.accentGoldLight,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
