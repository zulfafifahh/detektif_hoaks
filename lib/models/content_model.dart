class Materi {
  final String title;
  final String description;
  final String image;
  Materi({required this.title, required this.description, required this.image});
}

class Soal {
  final int id;
  final String text;
  final String image;
  final List<String> options;
  final int answerIndex;

  Soal({
    required this.id,
    required this.text,
    required this.image,
    required this.options,
    required this.answerIndex,
  });
}

class HasilSoal {
  final String pertanyaan;
  final List<String> pilihan;
  final int jawabanBenar;
  final int jawabanUser;
  final bool isTimeout;

  const HasilSoal({
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanBenar,
    required this.jawabanUser,
    required this.isTimeout,
  });

  bool get isBenar => !isTimeout && jawabanUser == jawabanBenar;

  Map<String, dynamic> toJson() => {
    'pertanyaan': pertanyaan,
    'pilihan': pilihan,
    'jawabanBenar': jawabanBenar,
    'jawabanUser': jawabanUser,
    'isTimeout': isTimeout,
  };

  factory HasilSoal.fromJson(Map<String, dynamic> j) => HasilSoal(
    pertanyaan: j['pertanyaan'] as String,
    pilihan: List<String>.from(j['pilihan'] as List),
    jawabanBenar: (j['jawabanBenar'] as num).toInt(), // AOT safe
    jawabanUser: (j['jawabanUser'] as num).toInt(),   // AOT safe
    isTimeout: j['isTimeout'] as bool,
  );
}

class SesiHasil {
  final String id;
  final int level;
  final int skor;
  final int totalSoal;
  final int skorSkala100;
  final int bintang;
  final DateTime tanggal;
  final List<HasilSoal> detailSoal;

  const SesiHasil({
    required this.id,
    required this.level,
    required this.skor,
    required this.totalSoal,
    required this.skorSkala100,
    required this.bintang,
    required this.tanggal,
    required this.detailSoal,
  });

  int get jumlahBenar => detailSoal.where((s) => s.isBenar).length;
  int get jumlahSalah =>
      detailSoal.where((s) => !s.isBenar && !s.isTimeout).length;
  int get jumlahSkip => detailSoal.where((s) => s.isTimeout).length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'skor': skor,
    'totalSoal': totalSoal,
    'skorSkala100': skorSkala100,
    'bintang': bintang,
    'tanggal': tanggal.toIso8601String(),
    'detailSoal': detailSoal.map((s) => s.toJson()).toList(),
  };

  factory SesiHasil.fromJson(Map<String, dynamic> j) => SesiHasil(
    id: j['id'] as String,
    level: (j['level'] as num).toInt(),
    skor: (j['skor'] as num).toInt(),
    totalSoal: (j['totalSoal'] as num).toInt(),
    skorSkala100: (j['skor_skala100'] as num).toInt(),
    bintang: (j['bintang'] as num).toInt(),
    tanggal: DateTime.parse(j['tanggal'] as String),
    detailSoal: (j['detailSoal'] as List)
        .map((e) => HasilSoal.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}