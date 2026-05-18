import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';

// ─── PROFILE SCREEN ──────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileCard(context),
            _buildDeenStreaks(),
            _buildAskScholar(context),
            _buildAskAI(),
            _buildPrivacyBanner(),
            _buildAppSettings(context),
            _buildReportsSafety(),
            _buildHelpSupport(),
            _buildLogout(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryDarkest],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Hexagon-ish avatar (diamond shape)
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: ClipOval(
              child: Container(
                color: AppColors.primaryMid,
                child: const Icon(Icons.person, size: 44, color: AppColors.textCream),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Asfa Rani', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 20,
            fontWeight: FontWeight.w800, color: AppColors.textWhite,
          )),
          const Text('Stay consistent in your Deen 🌙', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGreenMuted,
          )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statBadge('🔥 7 DAY STREAK'),
              const SizedBox(width: 8),
              _statBadge('📖 QURAN 75%'),
            ],
          ),
          const SizedBox(height: 8),
          _statBadge('🕌 NAMAZ 92%'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('EDIT PROFILE', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w700, color: AppColors.gold,
                letterSpacing: 0.8,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(
        fontFamily: 'Cairo', fontSize: 12,
        fontWeight: FontWeight.w600, color: AppColors.textWhite,
      )),
    );
  }

  Widget _buildDeenStreaks() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final done = [true, true, true, true, true, false, false];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Deen Streaks 🔥', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) => Column(
              children: [
                Text(days[i], style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey,
                )),
                const SizedBox(height: 4),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: done[i] ? AppColors.primaryDark : AppColors.bgCream,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      done[i] ? Icons.check : Icons.circle_outlined,
                      size: 16,
                      color: done[i] ? AppColors.textWhite : AppColors.borderLight,
                    ),
                  ),
                ),
              ],
            )),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🔥 7 Day Streak — MashaAllah!', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w700, color: AppColors.goldDark,
              )),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Namaz', 'Quran', 'Adkar', 'Custom'].map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgCream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(label, style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey,
                )),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('View Full Streaks →', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.primaryDark,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAskScholar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('Ask a Scholar\n(Human Verified)', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 16,
                  fontWeight: FontWeight.w800, color: AppColors.textDark,
                )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Authentic\nAnswers', textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 9,
                      fontWeight: FontWeight.w700, color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: AppColors.gold, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expert Verifications', style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 13,
                        fontWeight: FontWeight.w700, color: AppColors.textDark,
                      )),
                      Text('One authoritative answer • No debates allowed', style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('"Is it permissible to trade digital assets in Shariah?"',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                      color: AppColors.textGrey, fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 14, color: AppColors.gold),
                      const SizedBox(width: 4),
                      const Text('SHEIKH ABDULLAH', style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 11,
                        fontWeight: FontWeight.w700, color: AppColors.primaryDark,
                      )),
                      const SizedBox(width: 4),
                      const Text('Q&R SCHOLAR', style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAskAI() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryDarkest],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bismillah. Here is what the Quran says about patience (Sabr): "O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient." [2:153]',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textCream, height: 1.5),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryMid,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Ayat Al-Baqarah', style: TextStyle(
              fontFamily: 'Cairo', fontSize: 11,
              fontWeight: FontWeight.w600, color: AppColors.textWhite,
            )),
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryMid,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('Type your question...', style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGreenMuted,
                  )),
                ),
                Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, size: 16, color: AppColors.primaryDarkest),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(
              child: Text('ASK AN ISLAMIC AI', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest, letterSpacing: 0.8,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Text(
        'A message about your privacy\nAsk Iman has a Dedicated Safety-focused approach on tracking and practice.',
        style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey, height: 1.5),
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    final settings = [
      {'icon': Icons.notifications_outlined, 'label': 'Notifications', 'badge': ''},
      {'icon': Icons.language, 'label': 'Language', 'badge': ''},
      {'icon': Icons.palette_outlined, 'label': 'Theme', 'badge': ''},
      {'icon': Icons.download_outlined, 'label': 'Downloads', 'badge': ''},
      {'icon': Icons.access_time, 'label': 'Prayer Calculation', 'badge': ''},
      {'icon': Icons.calendar_today_outlined, 'label': 'Islamic Calendar', 'badge': 'NEW'},
    ];
    return _settingsGroup('APP SETTINGS', settings);
  }

  Widget _buildReportsSafety() {
    final settings = [
      {'icon': Icons.flag_outlined, 'label': 'Report Misuse', 'badge': '!'},
      {'icon': Icons.shield_outlined, 'label': 'Trust & Safety', 'badge': ''},
    ];
    return _settingsGroup('REPORTS & SAFETY', settings);
  }

  Widget _buildHelpSupport() {
    final settings = [
      {'icon': Icons.help_outline, 'label': 'Help Center', 'badge': ''},
      {'icon': Icons.mail_outline, 'label': 'Contact Support', 'badge': ''},
    ];
    return _settingsGroup('HELP & SUPPORT', settings);
  }

  Widget _settingsGroup(String title, List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title, style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textLightGrey, letterSpacing: 0.8,
            )),
          ),
          ...items.map((item) => ListTile(
            dense: true,
            leading: Icon(item['icon'] as IconData, size: 20, color: AppColors.primaryDark),
            title: Text(item['label'] as String, style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w500, color: AppColors.textDark,
            )),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((item['badge'] as String).isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item['badge'] == 'NEW'
                          ? AppColors.gold.withOpacity(0.15)
                          : AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['badge'] as String,
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item['badge'] == 'NEW' ? AppColors.gold : AppColors.error,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textLightGrey),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLogout() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryDarkest],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('LOGOUT', style: TextStyle(
              fontFamily: 'Cairo', fontSize: 15,
              fontWeight: FontWeight.w800, color: AppColors.textWhite,
              letterSpacing: 1,
            )),
            SizedBox(width: 8),
            Icon(Icons.logout, color: AppColors.textWhite, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── EDIT PROFILE SCREEN ──────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _publicProfile = true;
  bool _shareStreaks = true;

  final _nameCtrl = TextEditingController(text: 'Asfa Rani');
  final _emailCtrl = TextEditingController(text: 'asfa@example.com');
  final _phoneCtrl = TextEditingController(text: '+971 50 123 4567');
  final _locationCtrl = TextEditingController(text: 'Dubai, UAE');
  final _bioCtrl = TextEditingController(
    text: 'Seeking knowledge and mindfulness through the wisdom of Islam. Avid reader of the Quran and student of Seerah.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(
          fontFamily: 'Cairo', fontSize: 18,
          fontWeight: FontWeight.w700, color: AppColors.textWhite,
        )),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAvatarSection(),
            _buildPersonalIdentity(),
            _buildPrivacyPreferences(),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2.5),
                ),
                child: ClipOval(
                  child: Container(
                    color: AppColors.primaryMid,
                    child: const Icon(Icons.person, size: 60, color: AppColors.textCream),
                  ),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgWhite, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: AppColors.textWhite),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Change Photo', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 14,
            fontWeight: FontWeight.w600, color: AppColors.gold,
          )),
        ],
      ),
    );
  }

  Widget _buildPersonalIdentity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Identity', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 22,
            fontWeight: FontWeight.w800, color: AppColors.textDark,
          )),
          const SizedBox(height: 4),
          const Text(
            'Your identity within the ASK Islam community helps us tailor your spiritual journey.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          _fieldLabel('Full Name'),
          _textField(_nameCtrl, 'Full Name'),
          _fieldLabel('Email Address'),
          _textField(_emailCtrl, 'Email'),
          _fieldLabel('Phone Number'),
          _textField(_phoneCtrl, 'Phone'),
          _fieldLabel('Location (City, Country)'),
          _textFieldWithIcon(_locationCtrl, 'City, Country', Icons.location_on_outlined),
          _fieldLabel('Bio'),
          _textArea(_bioCtrl),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(
        fontFamily: 'Cairo', fontSize: 13,
        fontWeight: FontWeight.w700, color: AppColors.gold,
      )),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textWhite),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.primaryDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _textFieldWithIcon(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textWhite),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textGreenMuted, size: 18),
          filled: true,
          fillColor: AppColors.primaryDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _textArea(TextEditingController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: 4,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textWhite),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.primaryDark,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPreferences() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.borderLight, height: 32),
          const Text('Privacy & Preferences', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 22,
            fontWeight: FontWeight.w800, color: AppColors.textDark,
          )),
          const SizedBox(height: 4),
          const Text(
            'Control how your progress and profile are shared with the community.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          _toggleRow(
            'Public Profile',
            'Allow others to find you in the directory',
            _publicProfile,
                (v) => setState(() => _publicProfile = v),
          ),
          const SizedBox(height: 8),
          _toggleRow(
            'Share Streaks',
            'Show your daily activity streaks on your profile',
            _shareStreaks,
                (v) => setState(() => _shareStreaks = v),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.textDark,
                )),
                Text(subtitle, style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey,
                )),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Center(
              child: Text('Save Changes', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 16,
                fontWeight: FontWeight.w800, color: AppColors.primaryDarkest,
              )),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Center(
                child: Text('Cancel', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 16,
                  fontWeight: FontWeight.w600, color: AppColors.textDark,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}