import '../providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/interactive_date_check.dart';

enum SlideType { materi, contoh }

class SlideData {
  final String key;
  final SlideType type;
  final String title;
  final String desc;
  final String image;
  final ContohKasus? contoh;

  const SlideData({
    required this.key,
    required this.type,
    required this.title,
    required this.desc,
    this.image = '',
    this.contoh,
  });
}

class ContohKasus {
  final String kasusLabel;
  final String kasusDesc;
  final String salahLabel;
  final List<String> salah;
  final String benarLabel;
  final List<String> benar;
  final String kesimpulan;
  final Color warnaBadge;

  const ContohKasus({
    required this.kasusLabel,
    required this.kasusDesc,
    required this.salahLabel,
    required this.salah,
    required this.benarLabel,
    required this.benar,
    required this.kesimpulan,
    this.warnaBadge = const Color(0xFFB71C1C),
  });
}

class _IconIllustration extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String label;

  const _IconIllustration({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, bc) {
        final size = bc.maxHeight < 150 ? 72.0 : 120.0;
        final icSize = bc.maxHeight < 150 ? 36.0 : 64.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, size: icSize, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: bc.maxHeight < 150 ? 9 : 12,
                fontWeight: FontWeight.bold,
                color: bgColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        );
      },
    );
  }
}

const Map<String, Map<String, dynamic>> _illustrations = {
  'intro': {
    'icon': Icons.shield,
    'bg': Color(0xFF1A237E),
    'ic': Colors.amber,
    'label': 'CRAAP TEST',
  },
  'currency': {
    'icon': Icons.calendar_today,
    'bg': Color(0xFF0277BD),
    'ic': Colors.white,
    'label': 'C - CURRENCY',
  },
  'relevance': {
    'icon': Icons.link,
    'bg': Color(0xFF00695C),
    'ic': Colors.white,
    'label': 'R - RELEVANCE',
  },
  'authority': {
    'icon': Icons.verified_user,
    'bg': Color(0xFF4527A0),
    'ic': Colors.white,
    'label': 'A - AUTHORITY',
  },
  'accuracy': {
    'icon': Icons.fact_check,
    'bg': Color(0xFFBF360C),
    'ic': Colors.white,
    'label': 'A - ACCURACY',
  },
  'purpose': {
    'icon': Icons.theater_comedy,
    'bg': Color(0xFF558B2F),
    'ic': Colors.white,
    'label': 'P - PURPOSE',
  },
  'contoh1': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'contoh2': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'contoh3': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'siap': {
    'icon': Icons.rocket_launch,
    'bg': Color(0xFFF57F17),
    'ic': Colors.white,
    'label': 'SIAP BERAKSI!',
  },

  'l2_intro': {
    'icon': Icons.image_search,
    'bg': Color(0xFF1A237E),
    'ic': Colors.amber,
    'label': 'INVESTIGASI VISUAL',
  },
  'l2_manip': {
    'icon': Icons.broken_image,
    'bg': Color(0xFF880E4F),
    'ic': Colors.white,
    'label': 'A - ACCURACY',
  },
  'l2_reverse': {
    'icon': Icons.manage_search,
    'bg': Color(0xFF004D40),
    'ic': Colors.white,
    'label': 'A - ACCURACY',
  },
  'l2_context': {
    'icon': Icons.calendar_month,
    'bg': Color(0xFF0277BD),
    'ic': Colors.white,
    'label': 'C - CURRENCY',
  },
  'l2_contoh': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'l2_contoh2': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'l2_contoh3': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'l2_siap': {
    'icon': Icons.gps_fixed,
    'bg': Color(0xFFF57F17),
    'ic': Colors.white,
    'label': 'PRAKTIK LAPANGAN',
  },

  'l3_intro': {
    'icon': Icons.gavel,
    'bg': Color(0xFF1A237E),
    'ic': Colors.amber,
    'label': 'UJIAN MASTER',
  },
  'l3_wa': {
    'icon': Icons.chat,
    'bg': Color(0xFF1B5E20),
    'ic': Colors.white,
    'label': 'A+P - AUTHORITY & PURPOSE',
  },
  'l3_purpose': {
    'icon': Icons.theater_comedy,
    'bg': Color(0xFF558B2F),
    'ic': Colors.white,
    'label': 'P - PURPOSE',
  },
  'l3_contoh': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'l3_contoh2': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'l3_contoh3': {
    'icon': Icons.cases,
    'bg': Color(0xFF6A1B9A),
    'ic': Colors.white,
    'label': 'STUDI KASUS',
  },
  'l3_sop': {
    'icon': Icons.rule,
    'bg': Color(0xFFB71C1C),
    'ic': Colors.white,
    'label': 'SOP DETEKTIF',
  },
};

Widget _buildIllustration(String key) {
  final cfg = _illustrations[key] ?? _illustrations['intro']!;
  return _IconIllustration(
    icon: cfg['icon'] as IconData,
    bgColor: cfg['bg'] as Color,
    iconColor: cfg['ic'] as Color,
    label: cfg['label'] as String,
  );
}

List<SlideData> _getSlides(int level) {
  if (level == 1) {
    return [
      const SlideData(
        key: 'intro',
        type: SlideType.materi,
        title: 'Kenalan dengan CRAAP',
        desc:
            'Sering bingung bedain berita asli atau palsu? Jangan asal share!\n\n'
            'Detektif anti-hoaks punya senjata rahasia bernama CRAAP. '
            'Ini adalah 5 jurus jitu untuk mengupas informasi palsu.\n\n'
            'Geser untuk pelajari jurusnya! 👉',
      ),
      const SlideData(
        key: 'currency',
        type: SlideType.materi,
        title: 'C — Currency (Cek Tanggal!)',
        desc:
            'Kapan berita ini dibuat?\n'
            'Hoaks sering menggunakan foto lama untuk kejadian baru.\n\n'
            '📅 Cek Tanggal: Apakah beritanya baru atau sudah basi?\n'
            '📅 Cek Situasi: Apakah link-nya masih bisa dibuka?\n\n'
            'Tips Detektif:\n'
            'Foto banjir tahun 2020 dipakai untuk berita hari ini = HOAKS!',
      ),
      const SlideData(
        key: 'relevance',
        type: SlideType.materi,
        title: 'R — Relevance (Nyambung Gak?)',
        desc:
            'Apakah Judul sesuai dengan Isinya?\n'
            'Hoaks sering pakai judul heboh (clickbait) cuma biar kamu klik.\n\n'
            '🧩 Baca Sampai Habis: Jangan cuma baca judul lalu emosi.\n'
            '🧩 Cek Isi: Judulnya "Artis Meninggal", isinya "Meninggal di sinetron".\n\n'
            'Tips Detektif:\n'
            'Judul terlalu bombastis + banyak tanda seru (!!!) = waspada!',
      ),
      const SlideData(
        key: 'authority',
        type: SlideType.materi,
        title: 'A — Authority (Siapa Sumbernya?)',
        desc:
            'Siapa yang nulis berita ini?\n'
            'Informasi valid harus punya penulis yang jelas.\n\n'
            '👮 Cek URL: Dari situs resmi (.go.id, .ac.id) atau blog gratisan?\n'
            '👮 Cek Penulis: Jurnalis asli atau "Admin Ganteng"?\n\n'
            'Tips Detektif:\n'
            'Blog pribadi tanpa nama penulis BUKAN sumber tugas sekolah!',
      ),
      const SlideData(
        key: 'accuracy',
        type: SlideType.materi,
        title: 'A — Accuracy (Mana Buktinya?)',
        desc:
            'Mana data dan buktinya?\n'
            'Informasi asli didukung fakta, bukan cuma "katanya".\n\n'
            '🎯 Cek Bukti: Ada foto asli, data statistik, atau kutipan ahli?\n'
            '🎯 Cek Typo: Hoaks sering banyak typo dan KAPITAL SEMUA.\n\n'
            'Tips Detektif:\n'
            '"Minum air panas bunuh virus" tanpa sumber medis = HOAKS!',
      ),
      const SlideData(
        key: 'purpose',
        type: SlideType.materi,
        title: 'P — Purpose (Apa Modusnya?)',
        desc:
            'Kenapa berita ini dibuat?\n'
            'Setiap info punya tujuan. Cari tahu motifnya!\n\n'
            '🎭 Informasi: Tujuannya mendidik.\n'
            '🎭 Provokasi: Tujuannya bikin kamu marah.\n'
            '🎭 Komersil: Tujuannya jualan obat.\n\n'
            'Tips Detektif:\n'
            '"SEBARKAN SEKARANG JUGA!" = tanda merah hoaks!',
      ),

      SlideData(
        key: 'contoh1',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'KASUS VIRAL 2024 — C + A',
          kasusDesc:
              'Video kepanikan warga akibat tsunami kembali viral di Facebook dengan '
              'caption "BARU TERJADI! Tsunami hantam pantai utara Jawa hari ini!". '
              'Padahal itu rekaman Tsunami Palu 2018.',
          salahLabel: '❌ Tanda-tanda Hoaks',
          salah: [
            'Tidak ada tanggal/waktu kejadian yang jelas',
            'Tidak ada nama media berita resmi sebagai sumber',
            'Caption provokatif & huruf kapital semua',
            'Tidak ditemukan di portal berita nasional',
          ],
          benarLabel: '✅ Cara Verifikasi',
          benar: [
            'Cek di Google News: "tsunami hari ini"',
            'Buka akun resmi BMKG di Twitter/Instagram',
            'Reverse image search potongan gambar video',
            'Cek TurnBackHoax.id untuk konfirmasi',
          ],
          kesimpulan:
              '⚖️ Melanggar: Currency (tanggal palsu) + Accuracy (konteks salah)',
          warnaBadge: Color(0xFFB71C1C),
        ),
      ),

      SlideData(
        key: 'contoh2',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'HOAKS KESEHATAN — A + P',
          kasusDesc:
              'Pesan berantai viral di WhatsApp: "TERBUKTI ILMIAH! Minum rebusan '
              'daun sirsak 3x sehari bisa MENYEMBUHKAN KANKER dalam 30 hari! '
              'Dibagikan oleh Prof. Dr. Ahmad Sp.PD dari RSUD Jakarta." '
              'Dokter bernama itu tidak ada dalam database IDI.',
          salahLabel: '❌ Tanda-tanda Hoaks',
          salah: [
            'Nama dokter tidak terdaftar di IDI (Ikatan Dokter Indonesia)',
            'Tidak ada nama jurnal ilmiah atau nomor DOI penelitian',
            'Klaim "menyembuhkan" tanpa uji klinis = ilegal di Indonesia',
            'Format pesan berantai: "sebarkan ke 20 orang!"',
          ],
          benarLabel: '✅ Cara Verifikasi',
          benar: [
            'Cek nama dokter di idi.or.id atau rs yang disebutkan',
            'Cari di PubMed/Google Scholar: "soursop cancer clinical trial"',
            'Buka kemkes.go.id untuk cek klaim obat tradisional',
            'Konsultasikan ke dokter atau apoteker berlisensi',
          ],
          kesimpulan:
              '⚖️ Melanggar: Authority (sumber fiktif) + Purpose (menjual harapan palsu)',
          warnaBadge: Color(0xFF1B5E20),
        ),
      ),

      SlideData(
        key: 'contoh3',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'PENIPUAN PHISHING — R + A',
          kasusDesc:
              'SMS masuk: "Selamat! Kartu BCA kamu terpilih mendapat REWARD '
              'Rp 5.000.000. Klik link berikut untuk klaim: bca-reward.site/klaim '
              'dalam 24 jam atau hadiah hangus." Link mengarah ke halaman palsu '
              'yang meminta nomor kartu dan PIN.',
          salahLabel: '❌ Tanda-tanda Penipuan',
          salah: [
            'Domain bukan bca.co.id — domain resmi BCA adalah bca.co.id',
            'Bank resmi TIDAK PERNAH minta PIN lewat link atau SMS',
            'Urgensi waktu 24 jam = teknik manipulasi psikologi',
            'Hadiah tiba-tiba tanpa pendaftaran = red flag utama',
          ],
          benarLabel: '✅ Cara Aman',
          benar: [
            'Ketik langsung bca.co.id di browser — jangan klik link SMS',
            'Hubungi 1500888 (Halo BCA) untuk konfirmasi',
            'Laporkan ke stoppenipuan.id atau lapor.go.id',
            'Aktifkan autentikasi 2 faktor di aplikasi mobile banking',
          ],
          kesimpulan:
              '⚖️ Melanggar: Relevance (judul tidak sesuai tujuan sebenarnya) + Accuracy (klaim hadiah fiktif)',
          warnaBadge: Color(0xFF0D47A1),
        ),
      ),

      const SlideData(
        key: 'siap',
        type: SlideType.materi,
        title: 'Siap Beraksi?',
        desc:
            'Sekarang kamu sudah menguasai 5 Jurus CRAAP.\n\n'
            'Ingat: Cek Tanggal, Judul, Sumber, Bukti, dan Tujuan.\n\n'
            'Sudah siap menguji kemampuanmu melawan serangan Hoaks?',
      ),
    ];
  } else if (level == 2) {
    return [
      const SlideData(
        key: 'l2_intro',
        type: SlideType.materi,
        title: 'Level 2: Investigasi Visual',
        desc:
            'Kerja bagus di Level 1, Agen!\n\n'
            'Sekarang, musuh kita lebih pintar. Mereka tidak hanya menulis '
            'kebohongan, tapi juga MEMALSUKAN FOTO dan BUKTI.\n\n'
            'Siapkan kaca pembesarmu. 🔍',
      ),

      const SlideData(
        key: 'l2_manip',
        type: SlideType.materi,
        title: 'Jurus 1: Manipulasi Gambar [A — Accuracy]',
        desc:
            'Pilar Accuracy bukan hanya soal teks — FOTO JUGA BISA DIREKAYASA.\n\n'
            'Perhatikan 3 sinyal manipulasi:\n\n'
            '1. Bayangan: Apakah arah bayangan objek sesuai arah cahaya?\n'
            '2. Proporsi: Adakah bagian tubuh atau benda yang ukurannya aneh?\n'
            '3. Resolusi: Wajah yang diedit biasanya lebih blur dari badannya.',
      ),
      const SlideData(
        key: 'l2_reverse',
        type: SlideType.materi,
        title: 'Jurus 2: Reverse Image Search [A — Accuracy]',
        desc:
            'Alat terkuat Detektif Accuracy adalah Google Images.\n\n'
            'Jika curiga dengan sebuah foto kerusuhan, unggah ke Google Images.\n\n'
            'Seringkali foto itu adalah kejadian di negara lain 5 tahun lalu!\n\n'
            '🔍 Caranya: Buka images.google.com → klik ikon kamera → '
            'unggah foto atau paste URL.',
      ),

      const SlideData(
        key: 'l2_context',
        type: SlideType.materi,
        title: 'Jurus 3: Konteks Waktu Foto [C — Currency]',
        desc:
            'Foto asli bisa jadi hoaks jika konteks waktunya diubah.\n\n'
            'Sebuah foto banjir nyata dari 2015 bisa dipakai sebagai "banjir hari ini".\n\n'
            '📅 Cara cek:\n'
            '1. Reverse image search → lihat tanggal hasil teratas\n'
            '2. Perhatikan detil musiman (baju, kendaraan, papan reklame)\n'
            '3. Cek geolokasi jika ada landmark yang terlihat\n\n'
            'Accuracy tanpa Currency = informasi yang masih cacat!',
      ),

      SlideData(
        key: 'l2_contoh',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'KASUS MANIPULASI FOTO — A',
          kasusDesc:
              'Foto hiu putih besar berenang di tengah genangan banjir '
              'Bundaran HI Jakarta viral dengan caption "Banjir Jakarta Parah!". '
              'Foto ini adalah editan gabungan foto banjir + foto hiu di laut.',
          salahLabel: '❌ Bukti Editan',
          salah: [
            'Bayangan gedung jatuh ke kiri, bayangan hiu ke kanan',
            'Warna air di sekitar hiu lebih jernih dari genangan banjir',
            'Resolusi hiu lebih tajam dari lingkungannya',
            'Tidak ada saksi atau video pendukung',
          ],
          benarLabel: '✅ Cara Membongkarnya',
          benar: [
            'Perhatikan arah bayangan semua objek',
            'Zoom foto — cari perbedaan resolusi/warna',
            'Reverse image search foto hiu tersebut',
            'Cek apakah ada berita hiu di Jakarta di media resmi',
          ],
          kesimpulan:
              '⚖️ Melanggar: Accuracy (manipulasi gambar) + Currency (konteks salah)',
          warnaBadge: Color(0xFF880E4F),
        ),
      ),

      SlideData(
        key: 'l2_contoh2',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'FOTO DAUR ULANG — C',
          kasusDesc:
              'Foto antrean panjang orang berbaju putih di depan sebuah gedung '
              'viral dengan caption "Ribuan warga mengungsi akibat gempa Lombok hari ini!". '
              'Setelah dicek, foto tersebut adalah antrean vaksinasi COVID-19 di Surabaya, 2021.',
          salahLabel: '❌ Sinyal Manipulasi Waktu',
          salah: [
            'Tidak ada nama media resmi di caption asli',
            'Google Reverse Image menunjukkan foto dari 2021',
            'Seragam putih tidak cocok dengan konteks pengungsian gempa',
            'Tidak ada berita gempa Lombok di hari yang sama di BMKG',
          ],
          benarLabel: '✅ Langkah Verifikasi',
          benar: [
            'Reverse image search → cek tanggal indeks terlama foto',
            'Buka bmkg.go.id — cari info gempa terkini',
            'Perhatikan seragam & fasilitas di latar belakang',
            'Cari di Twitter/X dengan kata kunci lokasi + tanggal',
          ],
          kesimpulan:
              '⚖️ Melanggar: Currency (foto daur ulang) + Accuracy (konteks sengaja diubah)',
          warnaBadge: Color(0xFF0277BD),
        ),
      ),

      SlideData(
        key: 'l2_contoh3',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'TANGKAPAN LAYAR PALSU — A + R',
          kasusDesc:
              'Tangkapan layar akun Twitter @KemenkesRI menyebar di Facebook: '
              '"PENTING! Pemerintah resmi larang penjualan minyak goreng curah mulai besok." '
              'Akun asli @KemenkesRI tidak pernah memposting hal tersebut.',
          salahLabel: '❌ Ciri Screenshot Palsu',
          salah: [
            'Font dan ikon pada screenshot tidak konsisten dengan desain Twitter asli',
            'Cek langsung akun @KemenkesRI — tweet tersebut tidak ada',
            'Konten kebijakan ekonomi bukan ranah Kemenkes, tapi Kemendag',
            'Tidak ada tanda centang biru (verified) yang terlihat jelas',
          ],
          benarLabel: '✅ Verifikasi Screenshot',
          benar: [
            'Buka langsung profil Twitter yang diklaim',
            'Gunakan fitur pencarian Twitter/X dengan kutipan teks',
            'Cek sumber resmi: kemendag.go.id untuk kebijakan perdagangan',
            'Laporkan screenshot palsu melalui fitur "Report" di platform',
          ],
          kesimpulan:
              '⚖️ Melanggar: Accuracy (dokumen dimanipulasi) + Relevance (atribusi ke lembaga yang salah)',
          warnaBadge: Color(0xFF4A148C),
        ),
      ),

      const SlideData(
        key: 'l2_siap',
        type: SlideType.materi,
        title: 'Siap Praktik Lapangan?',
        desc:
            'Di ujian kali ini, banyak soal membutuhkan ketelitian visualmu.\n\n'
            'Analisis setiap detail sebelum menjawab.\n\n'
            'Seorang detektif sejati tidak terburu-buru!',
      ),
    ];
  } else {
    return [
      const SlideData(
        key: 'l3_intro',
        type: SlideType.materi,
        title: 'Level 3: Ujian Master',
        desc:
            'Ini adalah tahap akhir, Master Detektif.\n\n'
            'Hoaks yang paling berbahaya adalah gabungan ketakutan (Fear) '
            'dan harapan palsu (Fake Hope) — seperti yang beredar di grup '
            'WhatsApp keluarga.',
      ),

      const SlideData(
        key: 'l3_wa',
        type: SlideType.materi,
        title: 'Analisis Berantai [A — Authority + P — Purpose]',
        desc:
            'Pesan berantai WA selalu menargetkan dua pilar sekaligus:\n\n'
            '👤 Authority: Sumber dibuat-buat ("Kata Dokter X", "Dari Kemenkes") '
            'tanpa nama lengkap, nomor SIP, atau link resmi.\n\n'
            '🎭 Purpose: Tujuannya fear-mongering (bikin takut) atau '
            'penyebaran ideologi, bukan mendidik.\n\n'
            'Ciri khas: KAPITAL berlebihan + ancaman moral "jangan berhenti di kamu".',
      ),
      const SlideData(
        key: 'l3_purpose',
        type: SlideType.materi,
        title: 'Membedah Motif [P — Purpose]',
        desc:
            'Setiap informasi punya tujuan. Lima motif paling umum:\n\n'
            '📚 Edukatif: Ingin berbagi ilmu yang benar.\n'
            '💰 Komersial: Ingin menjual produk/jasa.\n'
            '😡 Provokatif: Ingin memancing kemarahan & perpecahan.\n'
            '😨 Fear-mongering: Ingin menyebarkan rasa takut.\n'
            '😂 Satir/Parodi: Mengkritik lewat humor — bukan fakta!\n\n'
            '⚠️ Satir yang tidak berlabel = hoaks yang tidak disengaja.',
      ),

      SlideData(
        key: 'l3_contoh',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'HOAKS WA KELUARGA — A + P',
          kasusDesc:
              '"SEBARKAN! Bawang Merah Ditaruh di Sudut Kamar Bisa MENYEDOT '
              'VIRUS CORONA dari Udara!! Sudah Terbukti!! Jangan berhenti di '
              'kamu, teruskan ke minimal 20 orang!"',
          salahLabel: '❌ Ciri Hoaks Master',
          salah: [
            'Huruf KAPITAL semua + banyak tanda seru (!!)',
            'Tidak ada nama dokter/lembaga yang dikutip',
            'Kalimat "jangan berhenti di kamu" — manipulasi moral',
            'Tidak ada link ke sumber penelitian ilmiah',
            'WHO & Kemenkes tidak pernah merekomendasikan ini',
          ],
          benarLabel: '✅ Cara Memutus Rantai',
          benar: [
            'Jangan forward sebelum verifikasi',
            'Cek di who.int atau kemkes.go.id',
            'Cari di CekFakta.com atau TurnBackHoax.id',
            'Tanya balik: "Sumber ilmiahnya di mana?"',
            'Koreksi dengan sopan jika sudah terbukti hoaks',
          ],
          kesimpulan:
              '⚖️ Melanggar: Authority (sumber anonim) + Purpose (fear-mongering) + Accuracy (tidak ada bukti)',
          warnaBadge: Color(0xFF1B5E20),
        ),
      ),

      SlideData(
        key: 'l3_contoh2',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'KONTEN SATIR TANPA LABEL — P',
          kasusDesc:
              'Akun parodi @BeritaLucu_ID memposting artikel berjudul '
              '"DPR Resmi Setujui Hari Tidur Siang Nasional Setiap Selasa". '
              'Artikel tersebut disebarkan ulang tanpa konteks sebagai berita asli '
              'dan trending di Twitter selama 3 jam.',
          salahLabel: '❌ Mengapa Berbahaya',
          salah: [
            'Tidak ada label "SATIR", "PARODI", atau "FIKSI" yang jelas',
            'Format penulisan mirip artikel berita resmi',
            'Orang yang menyebarkan ulang tidak tahu itu parodi',
            'Screenshot tanpa akun asal = kehilangan konteks satir',
          ],
          benarLabel: '✅ Cara Identifikasi Satir',
          benar: [
            'Cek bio/nama akun — apakah ada indikasi parodi?',
            'Cari judul berita di Google News — tidak ada = waspada',
            'Perhatikan detail yang absurd/tidak masuk akal',
            'Beri konteks saat menyebarkan: "ini satir ya, bukan berita asli"',
          ],
          kesimpulan:
              '⚖️ Dimensi kunci: Purpose (satir tidak berlabel = hoaks tidak disengaja)',
          warnaBadge: Color(0xFF558B2F),
        ),
      ),

      SlideData(
        key: 'l3_contoh3',
        type: SlideType.contoh,
        title: 'Contoh Kasus Nyata',
        desc: '',
        contoh: const ContohKasus(
          kasusLabel: 'HOAKS PROVOKASI PEMILU — R + P',
          kasusDesc:
              'Video pendek beredar di TikTok: rekaman seorang pria berseragam '
              'aparat membakar surat suara. Caption: "KECURANGAN PEMILU 2024 '
              'TERBUKTI!!" Video aslinya adalah latihan simulasi penghitungan '
              'surat suara rusak di daerah lain, 2019.',
          salahLabel: '❌ Tanda-tanda Provokasi',
          salah: [
            'Caption all-caps + dua tanda seru (!!)',
            'Tidak ada nama lokasi, tanggal, atau sumber media',
            'Konteks dipotong — hanya bagian yang terlihat mencurigakan',
            'Akun pembuat memiliki riwayat konten politik provokatif',
          ],
          benarLabel: '✅ Cara Verifikasi Video',
          benar: [
            'Cari judul video di Google + kata "hoaks" atau "fakta"',
            'Buka kpu.go.id untuk info resmi penghitungan suara',
            'Gunakan InVID/WeVerify untuk cek konteks video',
            'Laporkan ke Bawaslu jika benar-benar mencurigakan',
          ],
          kesimpulan:
              '⚖️ Melanggar: Relevance (konteks dipotong) + Purpose (provokasi politik)',
          warnaBadge: Color(0xFFB71C1C),
        ),
      ),

      const SlideData(
        key: 'l3_sop',
        type: SlideType.materi,
        title: 'SOP Detektif Master',
        desc:
            'Jika menemukan berita yang memicu emosimu:\n\n'
            '1. BERHENTI — Jangan langsung share.\n'
            '2. TARIK NAPAS — Emosi adalah senjata hoaks.\n'
            '3. CEK FAKTA — Buka TurnBackHoax.id atau CekFakta.com.\n\n'
            'Jadilah pemutus rantai hoaks!',
      ),
    ];
  }
}

class _ContohKasusCard extends StatelessWidget {
  final ContohKasus contoh;
  final Color cardBg;

  const _ContohKasusCard({required this.contoh, required this.cardBg});

  IconData get _mainIcon {
    final l = contoh.kasusLabel.toUpperCase();
    if (l.contains('VIRAL') || l.contains('VIDEO')) {
      return Icons.play_circle_filled;
    }
    if (l.contains('KESEHATAN')) return Icons.local_hospital;
    if (l.contains('PHISHING') || l.contains('PENIPUAN')) return Icons.security;
    if (l.contains('MANIPULASI FOTO')) return Icons.broken_image;
    if (l.contains('DAUR ULANG')) return Icons.history_toggle_off;
    if (l.contains('TANGKAPAN') || l.contains('SCREENSHOT')) {
      return Icons.find_in_page;
    }
    if (l.contains('WA') || l.contains('BERANTAI')) return Icons.chat_bubble;
    if (l.contains('SATIR') || l.contains('PARODI')) {
      return Icons.theater_comedy;
    }
    if (l.contains('PROVOKASI') || l.contains('PEMILU')) {
      return Icons.how_to_vote;
    }
    return Icons.crisis_alert;
  }

  List<IconData> get _supportIcons {
    final l = contoh.kasusLabel.toUpperCase();
    if (l.contains('VIRAL') || l.contains('VIDEO')) {
      return [Icons.share, Icons.warning_amber_rounded];
    }
    if (l.contains('KESEHATAN')) {
      return [Icons.medical_services, Icons.no_accounts];
    }
    if (l.contains('PHISHING') || l.contains('PENIPUAN')) {
      return [Icons.link_off, Icons.credit_card_off];
    }
    if (l.contains('MANIPULASI FOTO')) {
      return [Icons.image_search, Icons.find_replace];
    }
    if (l.contains('DAUR ULANG')) {
      return [Icons.update, Icons.event_busy];
    }
    if (l.contains('TANGKAPAN') || l.contains('SCREENSHOT')) {
      return [Icons.verified_user, Icons.policy];
    }
    if (l.contains('WA') || l.contains('BERANTAI')) {
      return [Icons.people, Icons.block];
    }
    if (l.contains('SATIR') || l.contains('PARODI')) {
      return [Icons.label_important, Icons.label_off];
    }
    if (l.contains('PROVOKASI') || l.contains('PEMILU')) {
      return [Icons.campaign, Icons.groups];
    }
    return [Icons.search, Icons.fact_check];
  }

  Widget _buildVisualHero() {
    final icons = _supportIcons;
    return Container(
      height: 148,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            contoh.warnaBadge,
            contoh.warnaBadge.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -16,
            left: -16,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned.fill(
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _heroIcon(icons[0], size: 24, opacity: 0.65),
                _heroIconMain(_mainIcon),
                _heroIcon(icons[1], size: 24, opacity: 0.65),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 32,
              color: Colors.black.withValues(alpha: 0.30),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                contoh.kasusLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroIcon(IconData icon, {double size = 24, double opacity = 1.0}) =>
      Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      );

  Widget _heroIconMain(IconData icon) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.22),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: 0.40), width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.20),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: 40),
  );

  List<Widget> _buildCraapChips() {
    const pillarColors = {
      'Currency': Color(0xFF0277BD),
      'Relevance': Color(0xFF00695C),
      'Authority': Color(0xFF4527A0),
      'Accuracy': Color(0xFFBF360C),
      'Purpose': Color(0xFF558B2F),
    };
    final chips = <Widget>[];
    for (final entry in pillarColors.entries) {
      if (contoh.kesimpulan.contains(entry.key)) {
        chips.add(
          Container(
            margin: const EdgeInsets.only(right: 6, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: entry.value.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: entry.value.withValues(alpha: 0.70)),
            ),
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: cardBg == Colors.white ? entry.value : Colors.white,
              ),
            ),
          ),
        );
      }
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = cardBg == Colors.white;

    final wrongBg = isLight
        ? const Color.fromARGB(255, 231, 76, 76)
        : const Color(0xFFFFCDD2); 
    final wrongText = isLight
        ? const Color(0xFF7F0000)
        : const Color(0xFFB71C1C);
    final wrongBullet = const Color(0xFFE53935);

    final rightBg = isLight
        ? const Color.fromARGB(255, 65, 208, 69)
        : const Color(0xFFC8E6C9); 
    final rightText = isLight
        ? const Color(0xFF1B5E20)
        : const Color(0xFF1B5E20);
    final rightBullet = const Color(0xFF43A047);

    final descBg = isLight
        ? contoh.warnaBadge.withValues(alpha: 0.20)
        : contoh.warnaBadge.withValues(alpha: 0.22);
    final descText = isLight ? const Color(0xFF212121) : Colors.white70;

    final concBg = isLight
        ? const Color(0xFF1A237E).withValues(alpha: 0.16)
        : const Color(0xFF1A237E).withValues(alpha: 0.35);
    final concText = isLight ? const Color(0xFF1A237E) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVisualHero(),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: descBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: contoh.warnaBadge.withValues(alpha: 0.40),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote,
                  color: contoh.warnaBadge.withValues(alpha: 0.80),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contoh.kasusDesc,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: descText,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildListKolom(
                  label: contoh.salahLabel,
                  items: contoh.salah,
                  bgColor: wrongBg,
                  textColor: wrongText,
                  bulletColor: wrongBullet,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildListKolom(
                  label: contoh.benarLabel,
                  items: contoh.benar,
                  bgColor: rightBg,
                  textColor: rightText,
                  bulletColor: rightBullet,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_buildCraapChips().isNotEmpty) ...[
            Wrap(children: _buildCraapChips()),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: concBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1A237E).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.gavel, color: Color(0xFF3949AB), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contoh.kesimpulan,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: concText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListKolom({
    required String label,
    required List<String> items,
    required Color bgColor,
    required Color textColor,
    required Color bulletColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: bulletColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MateriScreen extends StatefulWidget {
  final int level;
  const MateriScreen({super.key, required this.level});

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<SlideData> _slides;

  @override
  void initState() {
    super.initState();
    _slides = _getSlides(widget.level);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final cardTitleColor = isDark ? Colors.white : const Color(0xFF1A237E);
    final cardDescColor = isDark ? Colors.white70 : Colors.black87;
    final slide = _slides[_currentIndex];
    final isContoh = slide.type == SlideType.contoh;

    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        title: Text(
          'Briefing Misi: Level ${widget.level}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final isActive = i == _currentIndex;
                final isContohI = _slides[i].type == SlideType.contoh;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isContohI
                              ? const Color(0xFFCE93D8)
                              : const Color(0xFFFBC02D))
                        : (isContohI
                              ? Colors.purple.withValues(alpha: 0.35)
                              : Colors.white38),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          if (isContoh)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cases, color: Color(0xFFCE93D8), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'STUDI KASUS — Analisis Nyata',
                          style: TextStyle(
                            color: Color(0xFFCE93D8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (ctx, i) {
                final s = _slides[i];
                final isC = s.type == SlideType.contoh;
                final cardColor = isC
                    ? (isDark
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFFFAF0FF))
                    : cardBg;

                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  padding: EdgeInsets.all(isC ? 14 : 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: isC
                        ? Border.all(
                            color: Colors.purple.withValues(alpha: 0.25),
                            width: 1.5,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: isC && s.contoh != null
                      ? _ContohKasusCard(contoh: s.contoh!, cardBg: cardColor)
                      : LayoutBuilder(
                          builder: (ctx, bc) {
                            final isLandscape = bc.maxWidth > bc.maxHeight;
                            final Widget illustration = Center(
                              child: s.image.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        s.image,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : s.key == 'currency'
                                  ? const InteractiveDateCheck()
                                  : _buildIllustration(s.key),
                            );

                            if (isLandscape) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 4, child: illustration),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.title,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: cardTitleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              s.desc,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: cardDescColor,
                                                height: 1.45,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(flex: 3, child: illustration),
                                  const SizedBox(height: 16),
                                  Text(
                                    s.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: cardTitleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    flex: 3,
                                    child: SingleChildScrollView(
                                      child: Text(
                                        s.desc,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: cardDescColor,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Row(
              children: [
                if (_currentIndex > 0) ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentIndex == _slides.length - 1
                            ? const Color(0xFFFBC02D)
                            : (isContoh
                                  ? const Color(0xFF7B1FA2)
                                  : const Color(0xFFFBC02D)),
                        foregroundColor: _currentIndex == _slides.length - 1
                            ? Colors.black
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (_currentIndex == _slides.length - 1) {
                          Provider.of<GameProvider>(
                            context,
                            listen: false,
                          ).markMateriAsRead(widget.level);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(level: widget.level),
                            ),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentIndex == _slides.length - 1
                            ? 'MULAI MISI SEKARANG'
                            : 'LANJUT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _currentIndex == _slides.length - 1
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
