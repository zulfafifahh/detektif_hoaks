import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';


class _RetryContent {
  final String title;
  final String body;
  final String buttonLabel;
  final IconData titleIcon;

  const _RetryContent({
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.titleIcon,
  });
}

_RetryContent _getContent(int level, int retryLeft) {
  if (level == 1) {
    switch (retryLeft) {
      case 3:
        return const _RetryContent(
          title: 'Misi Perbaikan Skor!',
          body:
              'Skor kamu belum sempurna. Detektif pusat memberimu 3 kali kesempatan untuk menyelidiki ulang kasus ini dan meraih ★★★. Buktikan ketelitianmu!',
          buttonLabel: 'Mulai Penyelidikan (3 Sisa)',
          titleIcon: Icons.manage_search,
        );
      case 2:
        return const _RetryContent(
          title: 'Jangan Menyerah, Kadet!',
          body:
              'Hampir saja! Baca lagi materi atau perhatikan petunjuk visualnya lebih detail. Kamu masih punya 2 kesempatan lagi untuk membongkar kebenaran.',
          buttonLabel: 'Coba Lagi (2 Sisa)',
          titleIcon: Icons.search,
        );
      case 1:
        return const _RetryContent(
          title: 'Kesempatan Terakhir!',
          body:
              'Ini kesempatan terakhirmu untuk mendapatkan gelar Master di kasus ini! Tarik napas, tenangkan pikiran, dan jangan sampai terkecoh trik hoaks. Kamu pasti bisa!',
          buttonLabel: 'Investigasi Final (1 Sisa)',
          titleIcon: Icons.warning_amber_rounded,
        );
      default:
        return const _RetryContent(
          title: 'Berkas Kasus Ditutup',
          body:
              'Kesempatanmu untuk mengulang kasus ini sudah habis. Tidak apa-apa, bahkan Sherlock Holmes pun pernah salah! Fokus ke kasus selanjutnya dan jadikan ini pelajaran.',
          buttonLabel: 'Lanjut Kasus Lain',
          titleIcon: Icons.folder_off,
        );
    }
  }

  if (level == 2) {
    switch (retryLeft) {
      case 3:
        return const _RetryContent(
          title: 'Operasi Pengulangan Dimulai!',
          body:
              'Agenmu belum temukan semua bukti. Markas besar mengizinkan 3 operasi ulang untuk membongkar kasus visual ini sepenuhnya. Tingkatkan kewaspadaanmu!',
          buttonLabel: 'Mulai Operasi (3 Sisa)',
          titleIcon: Icons.radar,
        );
      case 2:
        return const _RetryContent(
          title: 'Fokus, Agen!',
          body:
              'Jangan terkecoh manipulasi visual dan deepfake! Perhatikan detail foto dan video lebih cermat. Masih ada 2 kesempatan untuk menyelesaikan misi ini.',
          buttonLabel: 'Lanjutkan Misi (2 Sisa)',
          titleIcon: Icons.remove_red_eye,
        );
      case 1:
        return const _RetryContent(
          title: 'Misi Kritis!',
          body:
              'Ini operasi terakhirmu di kasus visual ini! Gunakan semua jurusmu — reverse image search, forensik foto, dan cek metadata. Jangan sampai gagal!',
          buttonLabel: 'Operasi Final (1 Sisa)',
          titleIcon: Icons.crisis_alert,
        );
      default:
        return const _RetryContent(
          title: 'Misi Dihentikan',
          body:
              'Operasi pengulangan untuk kasus ini telah berakhir. Jangan berkecil hati — bahkan agen terbaik pun butuh waktu. Jadikan ini bekal untuk kasus berikutnya!',
          buttonLabel: 'Kembali ke Markas',
          titleIcon: Icons.lock_outline,
        );
    }
  }

  switch (retryLeft) {
    case 3:
      return const _RetryContent(
        title: 'Investigasi Ulang Diizinkan!',
        body:
            'Master Detektif harus sempurna! Kamu mendapat 3 kesempatan terakhir untuk membongkar konspirasi kompleks ini dan meraih gelar Master sejati. Gunakan dengan bijak!',
        buttonLabel: 'Buka Kembali Kasus (3 Sisa)',
        titleIcon: Icons.psychology,
      );
    case 2:
      return const _RetryContent(
        title: 'Tetap Tajam, Master!',
        body:
            'Konspirasi ini memang rumit. Ingat: analisis Purpose, kenali Echo Chamber, dan waspadai Post-Truth. Masih ada 2 kesempatan untuk membuktikan dirimu!',
        buttonLabel: 'Lanjutkan Investigasi (2 Sisa)',
        titleIcon: Icons.lightbulb_outline,
      );
    case 1:
      return const _RetryContent(
        title: 'Ujian Master Terakhir!',
        body:
            'Ini ujian final seorang Master Detektif sejati! Segala ilmu literasi digitalmu harus dikerahkan sekarang. Tidak ada ruang untuk salah — buktikan kamu layak!',
        buttonLabel: 'Ujian Final Master (1 Sisa)',
        titleIcon: Icons.emoji_events,
      );
    default:
      return const _RetryContent(
        title: 'Arsip Kasus Disegel',
        body:
            'Investigasi ulang kasus ini telah ditutup. Seorang Master sejati belajar dari setiap kegagalan. Hasil penyelidikanmu tetap tersimpan sebagai catatan detektif!',
        buttonLabel: 'Tutup Arsip',
        titleIcon: Icons.lock_person,
      );
  }
}

Widget _buildLives(int retryLeft) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (i) {
      final filled = i < retryLeft;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          filled ? Icons.favorite : Icons.favorite_border,
          color: filled ? Colors.redAccent : Colors.grey.shade400,
          size: 28,
        ),
      );
    }),
  );
}

Future<void> showRetryDialog({
  required BuildContext context,
  required int level,
  required int retryLeft,
  required VoidCallback onConfirm,
  VoidCallback? onClose,
}) async {
  final content = _getContent(level, retryLeft);
  final canPlay = retryLeft > 0;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon utama
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: canPlay
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                content.titleIcon,
                size: 32,
                color: canPlay ? AppColors.primary : Colors.grey,
              ),
            ),
            const SizedBox(height: 14),

            // Nyawa / hati
            _buildLives(retryLeft),
            const SizedBox(height: 6),
            Text(
              retryLeft == 0
                  ? 'Kesempatan habis'
                  : '$retryLeft kesempatan tersisa',
              style: TextStyle(
                fontSize: 12,
                color: retryLeft == 0
                    ? Colors.grey
                    : retryLeft == 1
                        ? Colors.redAccent
                        : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // Judul
            Text(
              content.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                color: canPlay ? AppColors.primary : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Isi pesan
            Text(
              content.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),

            // Tombol aksi utama
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canPlay ? AppColors.amber : Colors.grey.shade400,
                  foregroundColor: canPlay ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (canPlay) {
                    onConfirm();
                  } else {
                    onClose?.call();
                  }
                },
                child: Text(
                  content.buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Tombol batal (hanya muncul jika masih bisa retry)
            if (canPlay) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onClose?.call();
                },
                child: const Text(
                  'Belum dulu',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
