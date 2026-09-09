import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/content_model.dart';
import '../providers/game_provider.dart';
import '../widgets/common/app_widgets.dart';
import 'review_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filterLevel = 0;

  static const _levelNames = {
    1: 'Kasus 01 — CRAAP Test',
    2: 'Kasus 02 — Investigasi',
    3: 'Kasus 03 — Sidang Akhir',
  };

  static const _levelColors = {
    1: Color(0xFF29B6F6),
    2: Color(0xFFFFB300),
    3: Color(0xFFCE93D8),
  };

  @override
  Widget build(BuildContext context) {
    final gd = Provider.of<GameProvider>(context);
    final riwayat = _filterLevel == 0
        ? gd.riwayat
        : gd.getRiwayatByLevel(_filterLevel);

    return BlueScaffold(
      title: 'Riwayat Sesi',
      actions: [
        if (gd.riwayat.isNotEmpty)
          IconButton(
            icon:    const Icon(Icons.delete_outline, color: Colors.white60),
            tooltip: 'Hapus semua riwayat',
            onPressed: () => _confirmClear(context, gd),
          ),
      ],
      body: Column(
        children: [
          _buildFilterRow(),
          if (riwayat.isNotEmpty) _buildSummaryBar(riwayat),
          Expanded(
            child: riwayat.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: riwayat.length,
                    itemBuilder: (_, i) => _SesiCard(sesi: riwayat[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Row(
      children: [
        Expanded(child: _chip('Semua',    0)),
        const SizedBox(width: 6),
        Expanded(child: _chip('Kasus 01', 1)),
        const SizedBox(width: 6),
        Expanded(child: _chip('Kasus 02', 2)),
        const SizedBox(width: 6),
        Expanded(child: _chip('Kasus 03', 3)),
      ],
    ),
  );

  Widget _chip(String label, int level) {
    final isActive = _filterLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _filterLevel = level),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white12,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.white : Colors.white24,
            width: isActive ? 1.5 : 0.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:      isActive ? Colors.white : Colors.white54,
              fontSize:   12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Summary bar
  Widget _buildSummaryBar(List<SesiHasil> list) {
    final total   = list.length;
    final avg     = total == 0
        ? 0
        : (list.map((s) => s.skorSkala100).reduce((a, b) => a + b) / total)
              .round();
    final best    = total == 0
        ? 0
        : list.map((s) => s.skorSkala100).reduce((a, b) => a > b ? a : b);
    final bintang = list.fold<int>(0, (sum, s) => sum + s.bintang);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sumItem('$total',      'Sesi',      Icons.history),
          _sumItem('$avg',        'Rata-rata', Icons.bar_chart),
          _sumItem('$best',       'Terbaik',   Icons.emoji_events),
          _sumItem('$bintang ★',  'Total ★',   Icons.star),
        ],
      ),
    );
  }

  Widget _sumItem(String val, String lbl, IconData icon) => Column(
    children: [
      Icon(icon, color: Colors.white54, size: 16),
      const SizedBox(height: 2),
      Text(
        val,
        style: const TextStyle(
          color:      Colors.white,
          fontSize:   16,
          fontWeight: FontWeight.bold,
          height:     1,
        ),
      ),
      Text(lbl, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ],
  );

  // Empty state
  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.history_toggle_off, color: Colors.white24, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Belum ada sesi yang tercatat',
          style: TextStyle(color: Colors.white38, fontSize: 15),
        ),
        const SizedBox(height: 6),
        Text(
          _filterLevel == 0
              ? 'Selesaikan kuis pertamamu!'
              : 'Belum ada sesi untuk level ini.',
          style: const TextStyle(color: Colors.white24, fontSize: 13),
        ),
      ],
    ),
  );

  // Konfirmasi hapus
  void _confirmClear(BuildContext context, GameProvider gd) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   const Text('Hapus Riwayat?'),
        content: const Text(
          'Semua riwayat sesi akan dihapus permanen.\n'
          'Data bintang dan skor tidak terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await gd.clearRiwayat();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static String levelName(int level) => _levelNames[level] ?? 'Level $level';
  static Color  levelColor(int level) =>
      _levelColors[level] ?? const Color(0xFF29B6F6);
}

class _SesiCard extends StatelessWidget {
  final SesiHasil sesi;
  const _SesiCard({required this.sesi});

  @override
  Widget build(BuildContext context) {
    final accentColor = _HistoryScreenState.levelColor(sesi.level);
    final levelName   = _HistoryScreenState.levelName(sesi.level);
    final tgl         = sesi.tanggal;
    final tanggalStr  =
        '${tgl.day.toString().padLeft(2, '0')}/'
        '${tgl.month.toString().padLeft(2, '0')}/${tgl.year}  '
        '${tgl.hour.toString().padLeft(2, '0')}:'
        '${tgl.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(
            hasilSoalList: sesi.detailSoal,
            level:         sesi.level,
            skorSkala100:  sesi.skorSkala100,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color:  Colors.black38,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                border: Border(
                  bottom: BorderSide(
                      color: accentColor.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width:  36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:  accentColor.withValues(alpha: 0.15),
                      shape:  BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${sesi.level}',
                        style: TextStyle(
                          color:      accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize:   16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          levelName,
                          style: GoogleFonts.fredoka(
                            fontSize:   15,
                            color:      AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tanggalStr,
                          style: TextStyle(
                            fontSize: 11,
                            color:    Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${sesi.skorSkala100}',
                        style: TextStyle(
                          color:      accentColor,
                          fontSize:   26,
                          fontWeight: FontWeight.bold,
                          height:     1,
                        ),
                      ),
                      Text(
                        '/ 100',
                        style: TextStyle(
                          color:    Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body: bintang + stat + tombol review
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => Icon(
                        i < sesi.bintang ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size:  20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _miniStat('${sesi.jumlahBenar}', '✓', const Color(0xFF43A047)),
                        _miniStat('${sesi.jumlahSalah}', '✗', const Color(0xFFE53935)),
                        _miniStat('${sesi.jumlahSkip}',  '⏭', Colors.orange),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:        AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.fact_check_outlined,
                            color: AppColors.primary, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Review',
                          style: TextStyle(
                            color:      AppColors.primary,
                            fontSize:   11,
                            fontWeight: FontWeight.bold,
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

  Widget _miniStat(String value, String icon, Color color) => Row(
    children: [
      Text(icon, style: TextStyle(color: color, fontSize: 12)),
      const SizedBox(width: 3),
      Text(
        value,
        style: TextStyle(
          color:      color,
          fontSize:   13,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
