import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/content_model.dart';
import '../widgets/common/app_widgets.dart';

class ReviewScreen extends StatefulWidget {
  final List<HasilSoal> hasilSoalList;
  final int level, skorSkala100;

  const ReviewScreen({
    super.key,
    required this.hasilSoalList,
    required this.level,
    required this.skorSkala100,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _filter = 'semua';

  List<HasilSoal> get _filtered => switch (_filter) {
    'benar' => widget.hasilSoalList.where((s) => s.isBenar).toList(),
    'salah' =>
      widget.hasilSoalList.where((s) => !s.isBenar && !s.isTimeout).toList(),
    'skip'  => widget.hasilSoalList.where((s) => s.isTimeout).toList(),
    _       => widget.hasilSoalList,
  };

  @override
  Widget build(BuildContext context) {
    final total = widget.hasilSoalList.length;
    final benar = widget.hasilSoalList.where((s) => s.isBenar).length;
    final salah = widget.hasilSoalList
        .where((s) => !s.isBenar && !s.isTimeout)
        .length;
    final skip  = widget.hasilSoalList.where((s) => s.isTimeout).length;

    return BlueScaffold(
      title: 'Review Jawaban — Kasus 0${widget.level}',
      body: Column(
        children: [
          _buildSkorBar(benar, salah, skip, total),
          _buildFilterRow(benar, salah, skip, total),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada soal di kategori ini',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final soal = _filtered[i];
                      return _SoalCard(
                        soal:      soal,
                        nomorAsli: widget.hasilSoalList.indexOf(soal) + 1,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkorBar(int benar, int salah, int skip, int total) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      color:        Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: Colors.white24),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _miniStat('${widget.skorSkala100}', 'Skor',   Colors.white),
        _miniStat('$benar',                'Benar',   AppColors.statBenar),
        _miniStat('$salah',                'Salah',   AppColors.statSalah),
        _miniStat('$skip',                 'Lewati',  AppColors.statSkip),
        _miniStat('$total',                'Total',   Colors.white60),
      ],
    ),
  );

  Widget _buildFilterRow(int benar, int salah, int skip, int total) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    child: Row(
      children: [
        Expanded(
          child: _chip(
            label:       'Semua ($total)',
            filter:      'semua',
            activeColor: Colors.white,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _chip(
            label:       'Benar ($benar)',
            filter:      'benar',
            activeColor: AppColors.statBenar,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _chip(
            label:       'Salah ($salah)',
            filter:      'salah',
            activeColor: AppColors.statSalah,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _chip(
            label:       'Lewati ($skip)',
            filter:      'skip',
            activeColor: AppColors.statSkip,
          ),
        ),
      ],
    ),
  );

  Widget _chip({
    required String label,
    required String filter,
    required Color  activeColor,
  }) {
    final isActive = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.18)
              : Colors.white12,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : Colors.white24,
            width: isActive ? 1.5 : 0.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
            style: TextStyle(
              color:      isActive ? activeColor : Colors.white54,
              fontSize:   11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color:      color,
          fontSize:   20,
          fontWeight: FontWeight.bold,
          height:     1,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ],
  );
}

class _SoalCard extends StatelessWidget {
  final HasilSoal soal;
  final int       nomorAsli;

  const _SoalCard({required this.soal, required this.nomorAsli});

  @override
  Widget build(BuildContext context) {
    final Color  headerColor;
    final Color  headerBg;
    final String statusLabel;
    final IconData statusIcon;

    if (soal.isTimeout) {
      headerColor = AppColors.statSkip;
      headerBg    = const Color(0xFF5D4037);
      statusLabel = 'DILEWATI';
      statusIcon  = Icons.timer_off;
    } else if (soal.isBenar) {
      headerColor = AppColors.statBenar;
      headerBg    = const Color(0xFF1B5E20);
      statusLabel = 'BENAR';
      statusIcon  = Icons.check_circle;
    } else {
      headerColor = AppColors.statSalah;
      headerBg    = const Color(0xFF7F0000);
      statusLabel = 'SALAH';
      statusIcon  = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Colors.black38, offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:        headerBg,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: headerColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Soal $nomorAsli  ·  $statusLabel',
                  style: TextStyle(
                    color:       headerColor,
                    fontWeight:  FontWeight.bold,
                    fontSize:    13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Teks pertanyaan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              soal.pertanyaan,
              style: GoogleFonts.nunito(
                fontSize:   14,
                color:      AppColors.primary,
                fontWeight: FontWeight.w700,
                height:     1.5,
              ),
            ),
          ),

          // Pilihan jawaban
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: List.generate(
                soal.pilihan.length,
                (i) => _PilihanRow(
                  index:      i,
                  teks:       soal.pilihan[i],
                  isBenar:    i == soal.jawabanBenar,
                  isUserSalah: i == soal.jawabanUser &&
                               i != soal.jawabanBenar,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PilihanRow extends StatelessWidget {
  final int    index;
  final String teks;
  final bool   isBenar, isUserSalah;

  const _PilihanRow({
    required this.index,
    required this.teks,
    required this.isBenar,
    required this.isUserSalah,
  });

  @override
  Widget build(BuildContext context) {
    final Color  bg, text, border;
    final Color  labelBg;
    Widget?      trailing;

    if (isBenar) {
      bg      = AppColors.reviewCorrectBg;
      text    = AppColors.reviewCorrectText;
      border  = AppColors.reviewCorrectBdr;
      labelBg = const Color(0xFF43A047);
      trailing = const Icon(Icons.check_circle,
          color: Color(0xFF43A047), size: 18);
    } else if (isUserSalah) {
      bg      = AppColors.reviewWrongBg;
      text    = AppColors.reviewWrongText;
      border  = AppColors.reviewWrongBdr;
      labelBg = const Color(0xFFE53935);
      trailing = const Icon(Icons.cancel,
          color: Color(0xFFE53935), size: 18);
    } else {
      bg      = Colors.grey.shade100;
      text    = Colors.grey.shade700;
      border  = Colors.grey.shade200;
      labelBg = Colors.grey.shade300;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width:  24,
            height: 24,
            decoration: BoxDecoration(color: labelBg, shape: BoxShape.circle),
            child: Center(
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontSize:   11,
                  fontWeight: FontWeight.bold,
                  color: (isBenar || isUserSalah)
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              teks,
              style: TextStyle(
                fontSize:   13,
                color:      text,
                fontWeight: isBenar ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
