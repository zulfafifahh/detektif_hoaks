import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../models/content_model.dart';
import '../providers/game_provider.dart';
import '../services/sound_manager.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/retry_dialog.dart';
import 'home_screen.dart';
import 'materi_screen.dart';
import 'quiz_screen.dart';
import 'review_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score, totalSoal, level;
  final List<HasilSoal> hasilSoalList;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalSoal,
    required this.level,
    required this.hasilSoalList,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ConfettiController _confetti;
  late final bool _isLulus;
  late final int _skorSkala100;
  late final int _stars;

  @override
  void initState() {
    super.initState();
    _skorSkala100 = widget.totalSoal == 0
        ? 0
        : ((widget.score / widget.totalSoal) * 100).round();
    _stars = _hitungBintang(_skorSkala100);
    _isLulus = _stars > 0;
    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isLulus) {
        SoundManager.stopBgm();
        SoundManager.playWin();
        _confetti.play();
      } else {
        SoundManager.stopBgm();
        SoundManager.playLose();
      }

      Provider.of<GameProvider>(context, listen: false).completeLevel(
        widget.level,
        _stars,
        SesiHasil(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          level: widget.level,
          skor: widget.score,
          totalSoal: widget.totalSoal,
          skorSkala100: _skorSkala100,
          bintang: _stars,
          tanggal: DateTime.now(),
          detailSoal: widget.hasilSoalList,
        ),
      );
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  static int _hitungBintang(int skor) {
    if (skor >= AppConstants.bintang3) return 3;
    if (skor >= AppConstants.bintang2) return 2;
    if (skor >= AppConstants.bintang1) return 1;
    return 0;
  }

  Path _starPath(Size size) {
    double rad(double d) => d * (pi / 180);
    const n = 5;
    final hw = size.width / 2, er = hw, ir = hw / 2.5;
    final step = rad(360 / n);
    final path = Path()..moveTo(size.width, hw);
    for (double s = 0; s < rad(360); s += step) {
      path
        ..lineTo(hw + er * cos(s), hw + er * sin(s))
        ..lineTo(hw + ir * cos(s + step / 2), hw + ir * sin(s + step / 2));
    }
    return path..close();
  }

  @override
  Widget build(BuildContext context) {
    final benar = widget.hasilSoalList.where((s) => s.isBenar).length;
    final salah = widget.hasilSoalList
        .where((s) => !s.isBenar && !s.isTimeout)
        .length;
    final skip = widget.hasilSoalList.where((s) => s.isTimeout).length;

    return Scaffold(
      backgroundColor: _isLulus ? AppColors.primary : Colors.redAccent.shade700,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Icon(
                    _isLulus
                        ? Icons.emoji_events
                        : Icons.sentiment_very_dissatisfied,
                    size: 90,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLulus ? 'MISI SUKSES!' : 'MISI GAGAL!',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 46,
                      color: Colors.white,
                    ),
                  ),
                  if (_isLulus) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Icon(
                          i < _stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 46,
                          shadows: const [
                            Shadow(blurRadius: 10, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildScoreCard(benar, salah, skip),
                  const SizedBox(height: 14),
                  Text(
                    _isLulus
                        ? 'Luar biasa Detektif! Kasus selanjutnya menantimu.'
                        : 'Jangan menyerah! Analisis bukti lebih teliti lagi.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  AppFullButton(
                    label: 'Lihat Review Jawaban',
                    icon: const Icon(Icons.fact_check_outlined),
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(
                          hasilSoalList: widget.hasilSoalList,
                          level: widget.level,
                          skorSkala100: _skorSkala100,
                        ),
                      ),
                    ),
                  ),
                  if (!_isLulus || _stars < 3) ...[ 
                    const SizedBox(height: 12),
                    Consumer<GameProvider>(
                      builder: (ctx, gd, _) {
                        final retryLeft = gd.getRetryLeft(widget.level);
                        final canRetry = gd.canRetry(widget.level);

                        // ──────────────────────────────────────────
                        // Nyawa habis → arahkan ke MateriScreen
                        // untuk recovery (baca ulang → retry direset)
                        // ──────────────────────────────────────────
                        if (!canRetry) {
                          return AppFullButton(
                            label: 'Pelajari Ulang & Mulai Baru',
                            icon: const Icon(Icons.menu_book_rounded),
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            onPressed: () {
                              gd.resetRetry(widget.level);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MateriScreen(level: widget.level),
                                ),
                                (r) => false,
                              );
                            },
                          );
                        }

                        return AppFullButton(
                          label: 'Coba Lagi ($retryLeft kesempatan)',
                          icon: const Icon(Icons.replay),
                          backgroundColor: AppColors.amber,
                          foregroundColor: Colors.black,
                          onPressed: () {
                            showRetryDialog(
                              context: context,
                              level: widget.level,
                              retryLeft: retryLeft,
                              onConfirm: () {
                                gd.incrementRetry(widget.level);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        QuizScreen(level: widget.level),
                                  ),
                                );
                              },
                              onClose: () {},
                            );
                          },
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppFullButton(
                    label: 'Kembali ke Markas',
                    icon: const Icon(Icons.home),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (r) => false,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (_isLulus)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                ],
                createParticlePath: _starPath,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int benar, int salah, int skip) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white24),
    ),
    child: Column(
      children: [
        Text(
          '$_skorSkala100',
          style: GoogleFonts.bebasNeue(
            fontSize: 64,
            color: Colors.white,
            height: 1,
          ),
        ),
        const Text(
          'SKOR REPUTASI',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatChip(
              value: '$benar',
              label: 'Benar',
              color: AppColors.statBenar,
              icon: Icons.check_circle,
            ),
            StatChip(
              value: '$salah',
              label: 'Salah',
              color: AppColors.statSalah,
              icon: Icons.cancel,
            ),
            StatChip(
              value: '$skip',
              label: 'Dilewati',
              color: AppColors.statSkip,
              icon: Icons.timer_off,
            ),
          ],
        ),
      ],
    ),
  );
}
