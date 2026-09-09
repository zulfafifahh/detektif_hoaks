abstract final class AppConstants {
  // Kuota soal per level
  static const Map<int, int> soalPerLevel = {1: 10, 2: 15, 3: 20};

  static int kuota(int level) => soalPerLevel[level] ?? 10;

  // Waktu per soal (detik)
  static const int timerDetik = 30;

  // Ambang bintang (skor skala 100)
  static const int bintang3 = 90;
  static const int bintang2 = 70;
  static const int bintang1 = 50;

  // Skor reputasi per bintang
  static const int skorPerBintang = 100;

  // Batas riwayat sesi yang disimpan
  static const int maxRiwayat = 50;
}
