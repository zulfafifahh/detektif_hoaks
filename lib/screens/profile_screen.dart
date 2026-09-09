import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/avatar_palette.dart';
import '../providers/game_provider.dart';
import '../providers/setting_provider.dart';
import '../widgets/common/avatar_widget.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _badges = [
    {'level': 1, 'name': 'Pemula', 'icon': Icons.search},
    {'level': 2, 'name': 'Investigator', 'icon': Icons.fingerprint},
    {'level': 3, 'name': 'Master', 'icon': Icons.gavel},
  ];

  @override
  Widget build(BuildContext context) {
    final gd = Provider.of<GameProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Agen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, gd),
            const SizedBox(height: 20),
            _buildBadgeGrid(context, gd),
            const Divider(thickness: 1, height: 30),
            _buildAktivitasSection(context, gd),
            const Divider(thickness: 1, height: 20),
            _buildPengaturanSection(context, gd, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, GameProvider gd) => Container(
    padding: const EdgeInsets.all(30),
    width: double.infinity,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Column(
      children: [
        GestureDetector(
          onTap: () => _showAvatarPicker(context, gd),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomAvatar(
                type: gd.avatar,
                hairColor: AvatarPalette.hexToColor(
                  gd.hairColorHex,
                  AvatarPalette.hairColors.first.value,
                ),
                bgColor: AvatarPalette.hexToColor(
                  gd.bgColorHex,
                  AvatarPalette.bgColors.first.value,
                ),
                radius: 50,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          gd.userName,
          style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.white),
        ),
        Text(
          'Total Reputasi: ${gd.score}',
          style: const TextStyle(
            color: AppColors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _buildBadgeGrid(BuildContext context, GameProvider gd) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Koleksi Lencana',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
          ),
          itemCount: _badges.length,
          itemBuilder: (_, i) {
            final level = _badges[i]['level'] as int;
            final isUnlocked = gd.getStars(level) > 0;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.amber.withValues(alpha: 0.2)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isUnlocked
                        ? Border.all(color: AppColors.amber, width: 2)
                        : null,
                  ),
                  child: Icon(
                    isUnlocked ? _badges[i]['icon'] as IconData : Icons.lock,
                    color: isUnlocked ? Colors.amber[800] : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _badges[i]['name'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? Colors.amber[800] : Colors.grey[500],
                    fontWeight: isUnlocked
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );

  Widget _buildAktivitasSection(BuildContext context, GameProvider gd) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivitas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Consumer<GameProvider>(
              builder: (_, gd2, _) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.indigo.shade400,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Riwayat Sesi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  gd2.riwayat.isEmpty
                      ? 'Belum ada sesi tercatat'
                      : '${gd2.riwayat.length} sesi tersimpan',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.leaderboard,
                  color: Colors.amber.shade700,
                  size: 22,
                ),
              ),
              title: const Text(
                'Papan Peringkat',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Lihat posisimu di antara detektif lain',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              ),
            ),
          ],
        ),
      );

  // ── Personalisasi Avatar ─────────────────────────────────────────────
  void _showAvatarPicker(BuildContext context, GameProvider gd) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AvatarPickerSheet(gd: gd),
    );
  }

  Widget _buildPengaturanSection(
    BuildContext context,
    GameProvider gd,
    SettingsProvider settings,
  ) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengaturan Sistem',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        SwitchListTile(
          title: const Text('Mode Gelap (Dark Theme)'),
          secondary: const Icon(Icons.dark_mode),
          value: settings.isDarkMode,
          activeThumbColor: AppColors.amber,
          onChanged: settings.toggleTheme,
        ),

        ListTile(
          leading: const Icon(Icons.language, color: Colors.grey),
          title: Text(
            'Bahasa Aplikasi',
            style: TextStyle(color: Colors.grey[700]),
          ),
          subtitle: const Text(
            '🇮🇩 Indonesia (versi lain segera hadir)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: const Icon(
            Icons.info_outline,
            color: Colors.grey,
            size: 18,
          ),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Multi-bahasa belum tersedia di versi ini.'),
              duration: Duration(seconds: 2),
            ),
          ),
        ),

        const SizedBox(height: 20),
        _buildLogoutButton(context, gd),
      ],
    ),
  );

  Widget _buildLogoutButton(BuildContext context, GameProvider gd) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text('Keluar', style: TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Keluar dari Aplikasi?'),
            content: const Text(
              'Anda akan keluar dari aplikasi. Yakin ingin keluar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Ya, Keluar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await gd.resetAllData();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (r) => false,
          );
        }
      },
    ),
  );
}

class _AvatarPickerSheet extends StatefulWidget {
  final GameProvider gd;
  const _AvatarPickerSheet({required this.gd});

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  late String _type = widget.gd.avatar;
  late String _hairHex = widget.gd.hairColorHex;
  late String _bgHex = widget.gd.bgColorHex;
  bool _isSaving = false;

  Color get _hairColor => AvatarPalette.hexToColor(
    _hairHex,
    AvatarPalette.hairColors.first.value,
  );
  Color get _bgColor =>
      AvatarPalette.hexToColor(_bgHex, AvatarPalette.bgColors.first.value);

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.gd.updateAvatar(_type);
      await widget.gd.updateAvatarColors(
        hairColorHex: _hairHex,
        bgColorHex: _bgHex,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan avatar. Coba lagi ya!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Personalisasi Avatar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            CustomAvatar(
              type: _type,
              hairColor: _hairColor,
              bgColor: _bgColor,
              radius: 46,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _typeOption('boy'),
                const SizedBox(width: 20),
                _typeOption('girl'),
              ],
            ),
            const SizedBox(height: 26),
            _sectionLabel('Warna Rambut'),
            const SizedBox(height: 10),
            _swatchRow(
              AvatarPalette.hairColors,
              _hairHex,
              (hex) => setState(() => _hairHex = hex),
            ),
            const SizedBox(height: 22),
            _sectionLabel('Warna Latar'),
            const SizedBox(height: 10),
            _swatchRow(
              AvatarPalette.bgColors,
              _bgHex,
              (hex) => setState(() => _bgHex = hex),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _typeOption(String type) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: CustomAvatar(
          type: type,
          hairColor: _hairColor,
          bgColor: _bgColor,
          radius: 30,
        ),
      ),
    );
  }

  Widget _swatchRow(
    List<MapEntry<String, Color>> palette,
    String selectedHex,
    ValueChanged<String> onSelect,
  ) => Wrap(
    spacing: 12,
    runSpacing: 12,
    alignment: WrapAlignment.center,
    children: palette.map((entry) {
      final isSelected = entry.key == selectedHex;
      return GestureDetector(
        onTap: () => onSelect(entry.key),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: entry.value,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: entry.value.withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
      );
    }).toList(),
  );
}
