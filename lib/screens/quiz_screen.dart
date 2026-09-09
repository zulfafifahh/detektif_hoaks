import 'dart:async';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../models/content_model.dart';
import '../services/supabase_service.dart';
import '../services/sound_manager.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int level;
  const QuizScreen({super.key, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Soal> _daftarSoal = [];
  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = AppConstants.timerDetik;
  Timer? _timer;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool _isTimeout = false;
  bool _isLoading = true;
  // FIX: Mencegah double-tap race condition (spam-touch) di release mode.
  // _isAnswered saja tidak cukup karena GestureDetector bisa fire 2x sebelum
  // setState selesai rebuild. _isProcessing di-set SYNCHRONOUS (tanpa setState)
  // sehingga tap kedua langsung ditolak bahkan sebelum frame berikutnya.
  bool _isProcessing = false;
  String? _error;

  final List<HasilSoal> _hasilSoalList = [];
  int get _kuota => AppConstants.kuota(widget.level);

  // Animasi poin — butir 23 instrumen validasi
  bool _showPointAnim = false;
  int _pointAnimKey = 0; // diincrement tiap trigger agar animasi restart

  static const double _topGap = 8.0;
  static const double _cardBtnGap = 8.0;
  static const double _btnGap = 8.0;
  static const double _botPad = 8.0;
  static const double _overhead = _topGap + _cardBtnGap + _btnGap * 3 + _botPad;
  static const double _ratioCard = 0.30;
  static const double _ratioBtn = 0.70;
  static const int _nOptions = 4;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSoal() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentIndex = 0;
        _score = 0;
        _isAnswered = false;
        _isTimeout = false;
        _isProcessing = false;
        _selectedAnswerIndex = null;
        _showPointAnim = false;
        _pointAnimKey = 0;
        _daftarSoal.clear();
        _hasilSoalList.clear();
      });
    }
    try {
      final allSoal = await SupabaseService.getSoalByLevel(widget.level);
      if (allSoal.isEmpty) {
        _setError(
          'Soal tidak ditemukan. Pastikan data soal sudah diisi di Supabase.',
        );
        return;
      }
      allSoal.shuffle(Random());
      final soalFinal = allSoal.take(_kuota).toList();
      if (soalFinal.isEmpty) {
        _setError('Jumlah soal tidak mencukupi untuk memulai kuis.');
        return;
      }
      if (mounted) {
        setState(() {
          _daftarSoal = soalFinal;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      _setError(
        'Gagal memuat soal.\n\nError: ${e.toString()}\n\nPeriksa koneksi internet dan coba lagi.',
      );
    }
  }

  void _setError(String msg) {
    if (mounted) {
      setState(() {
        _error = msg;
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = AppConstants.timerDetik;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_isAnswered || _isProcessing || _daftarSoal.isEmpty) return;
    if (_currentIndex >= _daftarSoal.length) return;
    _isProcessing = true; 
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _isTimeout = true;
      _selectedAnswerIndex = null;
    });
    _recordHasil(-1, isTimeout: true);
    SoundManager.playTimeOut();
    Future.delayed(const Duration(milliseconds: 800), _nextQuestion);
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered || _isProcessing || _isTimeout || _daftarSoal.isEmpty) return;
    if (_currentIndex >= _daftarSoal.length) return;
    _isProcessing = true; 
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _isTimeout = false;
      _selectedAnswerIndex = selectedIndex;
    });
    final isCorrect = selectedIndex == _daftarSoal[_currentIndex].answerIndex;
    if (isCorrect) {
      _score++;
      SoundManager.playCorrect();
      _triggerPointAnim();
    } else {
      SoundManager.playWrong();
    }
    _recordHasil(selectedIndex);
    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  void _recordHasil(int jawabanUser, {bool isTimeout = false}) {
    _hasilSoalList.add(
      HasilSoal(
        pertanyaan: _daftarSoal[_currentIndex].text,
        pilihan: _daftarSoal[_currentIndex].options,
        jawabanBenar: _daftarSoal[_currentIndex].answerIndex,
        jawabanUser: jawabanUser,
        isTimeout: isTimeout,
      ),
    );
  }

  void _triggerPointAnim() {
    setState(() {
      _showPointAnim = true;
      _pointAnimKey++;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showPointAnim = false);
    });
  }

  Widget _buildPointAnim() {
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            key: ValueKey(_pointAnimKey),
            opacity: _showPointAnim ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 350),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.correct,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white54, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.correctDark.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+1 Poin!',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _nextQuestion() {
    if (!mounted || _daftarSoal.isEmpty) return;
    if (_currentIndex < _daftarSoal.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _isTimeout = false;
        _selectedAnswerIndex = null;
      });
      _startTimer();

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isProcessing = false);
      });
    } else {
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: _score,
            totalSoal: _daftarSoal.length,
            level: widget.level,
            hasilSoalList: _hasilSoalList,
          ),
        ),
      );
    }
  }

  void _showImageViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (_, bc) => Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    clipBehavior: Clip.none,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: bc.maxWidth,
                        maxHeight: bc.maxHeight,
                      ),
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (c, child, p) => p == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.amber,
                                      ),
                                    ),
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 64,
                              ),
                            )
                          : Image.asset(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pinch, color: Colors.white70, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Cubit untuk zoom',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapZoomable(Widget imageChild, String imageUrl) {
    return GestureDetector(
      onTap: () => _showImageViewer(context, imageUrl),
      child: Stack(
        children: [
          imageChild,
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.zoom_in, color: Colors.white70, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_daftarSoal.isEmpty || _currentIndex >= _daftarSoal.length) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator(color: AppColors.amber)),
      );
    }

    final soal = _daftarSoal[_currentIndex];
    final progress = (_currentIndex + 1) / _daftarSoal.length;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.accent],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(progress),
                  if (_isTimeout) _buildTimeoutBanner(),
                  Expanded(
                    child: soal.image.isEmpty
                        ? _buildNoImage(soal)
                        : _buildWithImage(soal),
                  ),
                ],
              ),
            ),
          ),
          _buildPointAnim(),
        ],
      ),
    );
  }

  Widget _buildNoImage(Soal soal) {
    return LayoutBuilder(
      builder: (ctx, bc) {
        final isLandscape = bc.maxWidth > bc.maxHeight;

        if (isLandscape) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 45,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          soal.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            color: AppColors.primary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  flex: 55,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _nOptions,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: _buildBtnNoImage(i, soal, verticalPad: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final available = bc.maxHeight;
        final flexH = available - _overhead;
        final cardH = flexH * _ratioCard;
        final btnH = (flexH * _ratioBtn) / _nOptions;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: _topGap),
              SizedBox(height: cardH, child: _buildCardNoImage(soal)),
              SizedBox(height: _cardBtnGap),
              SizedBox(height: btnH, child: _buildBtnNoImage(0, soal)),
              SizedBox(height: _btnGap),
              SizedBox(height: btnH, child: _buildBtnNoImage(1, soal)),
              SizedBox(height: _btnGap),
              SizedBox(height: btnH, child: _buildBtnNoImage(2, soal)),
              SizedBox(height: _btnGap),
              SizedBox(height: btnH, child: _buildBtnNoImage(3, soal)),
              SizedBox(height: _botPad),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardNoImage(Soal soal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            soal.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: 14,
              color: AppColors.primary,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBtnNoImage(int index, Soal soal, {double verticalPad = 0}) {
    final text = soal.options[index];
    final correctIndex = soal.answerIndex;

    Color bg = Colors.white;
    Color shadow = Colors.grey.shade400;
    Color fg = AppColors.primary;
    IconData? icon;

    if (_isAnswered) {
      if (_isTimeout) {
        bg = Colors.grey.shade200;
        shadow = Colors.grey.shade300;
        fg = Colors.grey;
      } else if (index == correctIndex) {
        bg = AppColors.correct;
        shadow = AppColors.correctDark;
        fg = Colors.white;
        icon = Icons.check_circle;
      } else if (index == _selectedAnswerIndex) {
        bg = AppColors.wrong;
        shadow = AppColors.wrongDark;
        fg = Colors.white;
        icon = Icons.cancel;
      } else {
        bg = Colors.grey.shade200;
        shadow = Colors.grey.shade300;
        fg = Colors.grey;
      }
    }

    final highlighted =
        _isAnswered &&
        !_isTimeout &&
        (index == correctIndex || index == _selectedAnswerIndex);

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: highlighted ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: shadow, offset: const Offset(0, 4), blurRadius: 0),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: verticalPad),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: fg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                // FIX: WCAG AA min 14sp untuk teks konten interaktif
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWithImage(Soal soal) {
    return LayoutBuilder(
      builder: (ctx, bc) {
        final isLandscape = bc.maxWidth > bc.maxHeight;

        // ── Widget gambar dasar (tidak berubah dari kode asli) ──────────────
        Widget imageChild = ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: soal.image.startsWith('http')
              ? Image.network(
                  soal.image,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  loadingBuilder: (c, child, p) => p == null
                      ? child
                      : const SizedBox(
                          height: 80,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                  errorBuilder: (c, err, st) => const SizedBox(
                    height: 60,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                )
              : Image.asset(
                  soal.image,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
        );

        // TAMBAHAN: bungkus gambar dengan tap-to-zoom
        final Widget imageWidget = _wrapZoomable(imageChild, soal.image);

        Widget answerCol = SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              soal.options.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: _buildBtnWithImage(i, soal),
              ),
            ),
          ),
        );

        if (isLandscape) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 45,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 100),
                          child: imageWidget,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Text(
                                soal.text,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(flex: 55, child: answerCol),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: imageWidget,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    soal.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: answerCol,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBtnWithImage(int index, Soal soal) {
    final text = soal.options[index];
    final correctIndex = soal.answerIndex;

    Color bgColor = Colors.white;
    Color shadowColor = Colors.grey.shade400;
    Color textColor = AppColors.primary;
    IconData? statusIcon;

    if (_isAnswered) {
      if (_isTimeout) {
        bgColor = Colors.grey.shade200;
        shadowColor = Colors.grey.shade300;
        textColor = Colors.grey;
      } else if (index == correctIndex) {
        bgColor = AppColors.correct;
        shadowColor = AppColors.correctDark;
        textColor = Colors.white;
        statusIcon = Icons.check_circle;
      } else if (index == _selectedAnswerIndex) {
        bgColor = AppColors.wrong;
        shadowColor = AppColors.wrongDark;
        textColor = Colors.white;
        statusIcon = Icons.cancel;
      } else {
        bgColor = Colors.grey.shade200;
        shadowColor = Colors.grey.shade300;
        textColor = Colors.grey;
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                (_isAnswered &&
                    !_isTimeout &&
                    (index == correctIndex || index == _selectedAnswerIndex))
                ? Colors.white
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                // FIX: WCAG AA — min 14sp (kontras & keterbacaan soal kuis)
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            if (statusIcon != null) Icon(statusIcon, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() => const Scaffold(
    backgroundColor: AppColors.primary,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.amber),
          SizedBox(height: 16),
          Text('Memuat soal...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    ),
  );

  Widget _buildError() => Scaffold(
    backgroundColor: AppColors.primary,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loadSoal,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kembali',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeader(double progress) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(
      children: [
        GestureDetector(
          onTap: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
          // SizedBox 48×48 memenuhi Material Design minimum touch target
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.black26,
              color: AppColors.amber,
              minHeight: 15,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _timeLeft < 10 ? Colors.redAccent : Colors.white24,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white54, width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(
                '$_timeLeft',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildTimeoutBanner() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_off, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            'WAKTU HABIS — Soal dilewati',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}
