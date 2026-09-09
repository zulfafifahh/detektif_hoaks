import 'package:flutter/material.dart';

// ============================================================
// BUG FIX — Gray screen di release mode (materi_screen currency)
// ============================================================
// SEBELUM: build() me-return `Expanded(child: SingleChildScrollView(...))`.
// `Expanded` adalah ParentDataWidget<FlexParentData> yang HANYA boleh
// jadi direct child dari Flex widget (Column / Row).
// Widget ini dipanggil dari Center (bukan Flex), sehingga Flutter
// melempar FlutterError.
//   • Debug mode (JIT) → red screen error (ditangkap Flutter debug handler)
//   • Release mode (AOT) → GRAY SCREEN karena error handler tidak aktif
//
// SESUDAH: build() me-return LayoutBuilder → Column(mainAxisSize: min).
// LayoutBuilder membaca ruang tersedia secara dinamis sehingga ukuran
// artikel mockup adaptif dan tidak overflow di portrait maupun landscape.
// Semua fungsi (shake animation, tap detection, snackbar) tidak berubah.
// ============================================================

class InteractiveDateCheck extends StatefulWidget {
  const InteractiveDateCheck({super.key});

  @override
  State<InteractiveDateCheck> createState() => _InteractiveDateCheckState();
}

class _InteractiveDateCheckState extends State<InteractiveDateCheck>
    with SingleTickerProviderStateMixin {
  bool _berhasil = false;
  bool _salahKlik = false;

  static const _targetTop    = 0.285;
  static const _targetBottom = 0.365;
  static const _targetLeft   = 0.04;
  static const _targetRight  = 0.47;

  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details, Size boxSize) {
    if (_berhasil) return;

    final rx = details.localPosition.dx / boxSize.width;
    final ry = details.localPosition.dy / boxSize.height;

    final diZona = rx >= _targetLeft &&
        rx <= _targetRight &&
        ry >= _targetTop &&
        ry <= _targetBottom;

    if (diZona) {
      setState(() { _berhasil = true; _salahKlik = false; });
      _showBerhasil();
    } else {
      setState(() => _salahKlik = true);
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _salahKlik = false);
      });
    }
  }

  void _showBerhasil() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tepat! Tanggal publikasi = kunci pertama CRAAP Test.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _reset() => setState(() { _berhasil = false; _salahKlik = false; });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final availW = constraints.maxWidth.isFinite  ? constraints.maxWidth  : 280.0;
        final availH = constraints.maxHeight.isFinite ? constraints.maxHeight : double.infinity;

        const double chromePx = 74.0; // badge + hint + spacing total
        const double aspectRatio = 0.72; // boxH / boxW

        // Batas dari lebar
        final maxWFromWidth = availW.clamp(0.0, 300.0);
        // Batas dari tinggi yang tersedia
        final maxHForBox   = (availH - chromePx).clamp(80.0, 216.0);
        final maxWFromHeight = maxHForBox / aspectRatio;

        // Gunakan yang lebih kecil agar tidak overflow ke segala arah
        final boxW = maxWFromWidth < maxWFromHeight ? maxWFromWidth : maxWFromHeight;
        final boxH = boxW * aspectRatio;

        // Tipografi adaptif: kecilkan sedikit jika ruang sangat terbatas
        final isCompact     = availH < 300;
        final badgeFontSize = isCompact ?  9.5 : 11.0;
        final badgeIconSize = isCompact ? 12.0 : 14.0;
        final hintFontSize  = isCompact ?  9.5 : 10.0;
        final spacingSmall  = isCompact ?  4.0 :  8.0;
        final badgePadV     = isCompact ?  3.0 :  6.0;
        final badgePadH     = isCompact ?  8.0 : 12.0;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            // mainAxisSize.min ← tidak memaksakan ukuran pada parent
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Badge instruksi ────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_berhasil),
                  margin: EdgeInsets.only(bottom: spacingSmall),
                  padding: EdgeInsets.symmetric(
                    horizontal: badgePadH,
                    vertical:  badgePadV,
                  ),
                  decoration: BoxDecoration(
                    color: _berhasil
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF0277BD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _berhasil ? Icons.check_circle : Icons.touch_app,
                        color: Colors.white,
                        size: badgeIconSize,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _berhasil
                            ? 'Bagus! Kamu menemukan tanggalnya!'
                            : 'Tap pada bagian TANGGAL di artikel ini',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: badgeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Artikel mockup + shake animation ──────────────
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: _salahKlik
                      ? Offset(
                          _shakeAnim.value *
                              ((_shakeCtrl.value > 0.5) ? -1 : 1),
                          0,
                        )
                      : Offset.zero,
                  child: child,
                ),
                child: GestureDetector(
                  onTapDown: (d) => _handleTap(d, Size(boxW, boxH)),
                  child: Container(
                    width:  boxW,
                    height: boxH,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _berhasil
                            ? const Color(0xFF43A047)
                            : _salahKlik
                                ? const Color(0xFFE53935)
                                : const Color(0xFFBBBBBB),
                        width: _berhasil || _salahKlik ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        children: [
                          _buildArtikelMockup(boxW, boxH),

                          // Overlay hijau zona tanggal saat berhasil
                          if (_berhasil)
                            Positioned(
                              top:    boxH * _targetTop,
                              left:   boxW * _targetLeft,
                              width:  boxW * (_targetRight - _targetLeft),
                              height: boxH * (_targetBottom - _targetTop),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF43A047).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF43A047),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2E7D32),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Hint teks / tombol reset ───────────────────────
              SizedBox(height: spacingSmall),
              if (!_berhasil)
                Text(
                  _salahKlik
                      ? '❌ Bukan di sana. Tap pada bagian TANGGAL!'
                      : 'Petunjuk: tap pada tanggal di bawah judul artikel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: hintFontSize,
                    color:
                        _salahKlik ? Colors.redAccent : Colors.white54,
                    fontWeight: _salahKlik
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(
                    Icons.replay,
                    size: 14,
                    color: Colors.white54,
                  ),
                  label: Text(
                    'Coba lagi',
                    style: TextStyle(
                      fontSize: hintFontSize,
                      color: Colors.white54,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtikelMockup(double w, double h) {
    return CustomPaint(size: Size(w, h), painter: _ArtikelPainter());
  }
}

// ── CustomPainter tidak berubah ──────────────────────────────
class _ArtikelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.12),
      Paint()..color = const Color(0xFFB71C1C),
    );
    _drawText(
      canvas, 'BERITAVIRAL24.COM',
      Offset(w * 0.04, h * 0.02),
      fontSize: h * 0.055, color: Colors.white, bold: true,
    );

    canvas.drawLine(
      Offset(0, h * 0.13), Offset(w, h * 0.13),
      Paint()..color = const Color(0xFFE0E0E0)..strokeWidth = 1,
    );

    _drawText(
      canvas, 'WASPADA!! VIRUS BARU MENYEBAR',
      Offset(w * 0.04, h * 0.145),
      fontSize: h * 0.062, color: const Color(0xFF212121), bold: true,
    );
    _drawText(
      canvas, 'LEWAT UDARA DI PUSAT PERBELANJAAN',
      Offset(w * 0.04, h * 0.21),
      fontSize: h * 0.062, color: const Color(0xFF212121), bold: true,
    );

    _drawText(
      canvas, '12 Maret 2019',
      Offset(w * 0.04, h * 0.295),
      fontSize: h * 0.048, color: const Color(0xFF9E9E9E), bold: false,
    );
    _drawText(
      canvas, '|  Admin Ganteng',
      Offset(w * 0.52, h * 0.295),
      fontSize: h * 0.048, color: const Color(0xFF9E9E9E), bold: false,
    );

    canvas.drawLine(
      Offset(w * 0.04, h * 0.375), Offset(w * 0.96, h * 0.375),
      Paint()..color = const Color(0xFFEEEEEE)..strokeWidth = 0.8,
    );

    final linesY = [0.40, 0.455, 0.51, 0.565, 0.62];
    final linesW = [0.92, 0.88, 0.92, 0.75, 0.82];
    for (int i = 0; i < linesY.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w * 0.04, h * linesY[i], w * linesW[i], h * 0.035,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFFEEEEEE),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.685, w * 0.92, h * 0.27),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFF5F5F5),
    );
    _drawText(
      canvas, '[ Foto ilustrasi ]',
      Offset(w * 0.30, h * 0.80),
      fontSize: h * 0.042, color: const Color(0xFFBDBDBD), bold: false,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double fontSize,
    required Color color,
    required bool bold,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}