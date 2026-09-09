import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/game_provider.dart';
import '../services/sound_manager.dart';
import '../widgets/retry_dialog.dart';
import 'leaderboard_screen.dart';
import 'materi_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';

class _LevelConfig {
  final int level;
  final String kasus;
  final String subtitle;
  final IconData icon;
  final String chapter;
  const _LevelConfig({
    required this.level,
    required this.kasus,
    required this.subtitle,
    required this.icon,
    required this.chapter,
  });
}

const _levels = [
  _LevelConfig(
    level: 1,
    kasus: 'KASUS 01',
    subtitle: 'Teori Kebohongan',
    icon: Icons.search,
    chapter: 'Bab I — Dasar Deteksi Hoaks',
  ),
  _LevelConfig(
    level: 2,
    kasus: 'KASUS 02',
    subtitle: 'Investigasi Bukti',
    icon: Icons.fingerprint,
    chapter: 'Bab II — Investigasi Visual',
  ),
  _LevelConfig(
    level: 3,
    kasus: 'KASUS 03',
    subtitle: 'Sidang Akhir',
    icon: Icons.gavel,
    chapter: 'Bab III — Kasus Master',
  ),
];

class _BadgeConfig {
  final int level;
  final String title, description;
  final IconData icon;
  final List<Color> ringColors;
  final Color nodeColor, glowColor;
  const _BadgeConfig({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
    required this.ringColors,
    required this.nodeColor,
    required this.glowColor,
  });
}

const _badges = [
  _BadgeConfig(
    level: 1,
    title: 'Kadet Detektif',
    description: 'Menguasai 5 Jurus CRAAP Test',
    icon: Icons.search,
    ringColors: [
      Color(0xFF29B6F6),
      Color(0xFF0288D1),
      Color(0xFF4DD0E1),
      Color(0xFF29B6F6),
    ],
    nodeColor: Color(0xFF01579B),
    glowColor: Color(0xFF29B6F6),
  ),
  _BadgeConfig(
    level: 2,
    title: 'Investigator',
    description: 'Ahli Membaca Bukti Visual',
    icon: Icons.fingerprint,
    ringColors: [
      Color(0xFFFFD54F),
      Color(0xFFFF8F00),
      Color(0xFFFF6D00),
      Color(0xFFFFD54F),
    ],
    nodeColor: Color(0xFFE65100),
    glowColor: Color(0xFFFFB300),
  ),
  _BadgeConfig(
    level: 3,
    title: 'Master Detektif',
    description: 'Penakluk Semua Kasus Hoaks',
    icon: Icons.workspace_premium,
    ringColors: [
      Color(0xFFFFD700),
      Color(0xFFE040FB),
      Color(0xFF7C4DFF),
      Color(0xFFFFD700),
    ],
    nodeColor: Color(0xFF4A148C),
    glowColor: Color(0xFFCE93D8),
  ),
];

_BadgeConfig? _highestBadge(GameProvider gd) {
  _BadgeConfig? h;
  for (final b in _badges) {
    if (gd.getStars(b.level) >= 3) h = b;
  }
  return h;
}

_BadgeConfig _badgeFor(int level) =>
    _badges.firstWhere((b) => b.level == level);

class _BadgeRingPainter extends CustomPainter {
  final List<Color> colors;
  final Color glowColor;
  final double strokeWidth, animValue;
  const _BadgeRingPainter({
    required this.colors,
    required this.glowColor,
    this.strokeWidth = 4.0,
    this.animValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = glowColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6,
    );
    final angle = animValue * 2 * math.pi;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: colors,
          startAngle: -math.pi / 2 + angle,
          endAngle: 3 * math.pi / 2 + angle,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );
    for (int i = 0; i < 4; i++) {
      final a = (i / 4) * 2 * math.pi - math.pi / 4 + angle;
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(a),
          center.dy + radius * math.sin(a),
        ),
        strokeWidth * 0.7,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_BadgeRingPainter o) => o.animValue != animValue;
}

class _MapPathPainter extends CustomPainter {
  final List<Offset> positions;
  _MapPathPainter(this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    canvas.save();
    canvas.translate(0, -120);

    final path = Path()..moveTo(positions[0].dx, positions[0].dy);
    for (int i = 1; i < positions.length; i++) {
      final prev = positions[i - 1], curr = positions[i];
      final midY = (prev.dy + curr.dy) / 2;
      path.cubicTo(prev.dx, midY, curr.dx, midY, curr.dx, curr.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
    );
    _drawDashed(
      canvas,
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < m.length) {
        final len = draw ? 10.0 : 8.0;
        if (draw) canvas.drawPath(m.extractPath(d, d + len), paint);
        d += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_MapPathPainter o) => true;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringAnim;

  final List<GlobalKey> _nodeKeys = List.generate(
    _levels.length,
    (_) => GlobalKey(),
  );
  final List<Offset> _nodePositions = [];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _ringAnim = Tween<double>(begin: 0, end: 1).animate(_ringCtrl);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calcNodePositions());
    SoundManager.startBgm();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  void _calcNodePositions() {
    final pos = <Offset>[];
    for (final k in _nodeKeys) {
      final box = k.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final g = box.localToGlobal(Offset.zero);
        pos.add(Offset(g.dx + box.size.width / 2, g.dy + box.size.height / 2));
      }
    }
    if (mounted) {
      setState(() {
        _nodePositions
          ..clear()
          ..addAll(pos);
      });
    }
  }

  Widget _buildHeader(GameProvider gd) {
    final badge = _highestBadge(gd);
    final done = _levels.where((l) => gd.getStars(l.level) > 0).length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            _buildAvatarRing(gd, badge),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gd.userName,
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  badge != null
                      ? Row(
                          children: [
                            Icon(
                              badge.icon,
                              size: 12,
                              color: badge.ringColors[1],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              badge.title,
                              style: TextStyle(
                                color: badge.ringColors[1],
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Calon Detektif',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            _buildLeaderboardButton(context),
            const SizedBox(width: 6),
            _buildLevelChip(done, _levels.length),
          ],
        ),
      ),
    );
  }

  // Tombol menuju papan peringkat. Diletakkan sebagai widget tersendiri
  // (bukan di dalam GestureDetector header) agar tap-nya tidak bentrok
  // dengan navigasi ke ProfileScreen.
  Widget _buildLeaderboardButton(BuildContext context) => IconButton(
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    ),
    icon: const Icon(Icons.leaderboard, color: Colors.white70, size: 22),
    tooltip: 'Papan Peringkat',
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
  );

  Widget _buildAvatarRing(GameProvider gd, _BadgeConfig? badge) {
    const double avatarR = 26.0, ringPad = 5.0, ringStroke = 4.0;
    final double size = (avatarR + ringPad + ringStroke) * 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (badge != null)
          SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, _) => CustomPaint(
                painter: _BadgeRingPainter(
                  colors: badge.ringColors,
                  glowColor: badge.glowColor,
                  strokeWidth: ringStroke,
                  animValue: _ringAnim.value,
                ),
              ),
            ),
          ),
        Padding(
          padding: badge != null
              ? EdgeInsets.all(ringPad + ringStroke)
              : EdgeInsets.zero,
          child: CircleAvatar(
            radius: avatarR,
            backgroundColor: AppColors.amber,
            child: Icon(
              gd.avatar == 'boy' ? Icons.face : Icons.face_3,
              color: Colors.black,
              size: avatarR * 1.1,
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: badge.nodeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: badge.glowColor.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(badge.icon, color: Colors.white, size: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildLevelChip(int done, int total) {
    final Color border, label, bar;
    final IconData ico;
    final String chipLabel;

    if (done == 0) {
      border = Colors.white.withValues(alpha: 0.15);
      label = Colors.white54;
      bar = Colors.white30;
      ico = Icons.flag_outlined;
      chipLabel = 'Mulai!';
    } else if (done < total) {
      border = const Color(0xFFFFB300).withValues(alpha: 0.4);
      label = const Color(0xFFFFD54F);
      bar = const Color(0xFFFFB300);
      ico = Icons.local_fire_department;
      chipLabel = '$done/$total';
    } else {
      border = const Color(0xFF81C784).withValues(alpha: 0.5);
      label = const Color(0xFF81C784);
      bar = const Color(0xFF43A047);
      ico = Icons.emoji_events;
      chipLabel = 'Tamat!';
    }

    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ico, color: label, size: 18),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              chipLabel,
              style: TextStyle(
                color: label,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Kasus',
            style: TextStyle(color: Colors.white38, fontSize: 9, height: 1.2),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? done / total : 0,
              backgroundColor: Colors.white12,
              color: bar,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom sheet briefing
  void _showBriefing(BuildContext context, _LevelConfig cfg, GameProvider gd) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Consumer<GameProvider>(
        builder: (ctx, gameData, _) {
          final isRead = gameData.isMateriRead(cfg.level);
          final stars = gameData.getStars(cfg.level);
          final badge = _badgeFor(cfg.level);
          final hasBadge = stars >= 3;
          final maxH = MediaQuery.of(context).size.height * 0.90;
          final botPad = MediaQuery.of(context).padding.bottom;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + botPad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cfg.icon,
                          size: 34,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cfg.kasus,
                        style: GoogleFonts.fredoka(
                          fontSize: 26,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cfg.subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildBadgeInfo(badge, hasBadge),
                      const SizedBox(height: 20),
                      _buildBriefingButton(
                        icon: Icons.menu_book,
                        label: 'Buka Berkas Materi',
                        bg: Colors.blueAccent,
                        fg: Colors.white,
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MateriScreen(level: cfg.level),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildBriefingButton(
                        icon: isRead ? Icons.gamepad : Icons.lock,
                        label: isRead
                            ? 'Mulai Investigasi (Kuis)'
                            : 'Baca Materi Dulu!',
                        bg: isRead ? AppColors.amber : Colors.grey.shade300,
                        fg: isRead ? Colors.black : Colors.grey.shade600,
                        onPressed: () {
                          if (isRead) {
                            Navigator.pop(ctx);
                            final hasCompleted = gameData.hasEverCompleted(
                              cfg.level,
                            );
                            if (hasCompleted && stars < 3) {
                              final canRetry = gameData.canRetry(cfg.level);

                              if (!canRetry) {
                                gameData.resetRetry(cfg.level);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pelajari ulang materi untuk memulihkan kesempatanmu!',
                                    ),
                                    backgroundColor: Color(0xFF1565C0),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MateriScreen(level: cfg.level),
                                  ),
                                );
                                return;
                              }

                              final retryLeft = gameData.getRetryLeft(
                                cfg.level,
                              );
                              showRetryDialog(
                                context: context,
                                level: cfg.level,
                                retryLeft: retryLeft,
                                onConfirm: () {
                                  gameData.incrementRetry(cfg.level);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          QuizScreen(level: cfg.level),
                                    ),
                                  );
                                },
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(level: cfg.level),
                                ),
                              );
                            }
                          } else {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Eits! Detektif harus baca materi dulu sebelum investigasi.',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeInfo(_BadgeConfig badge, bool hasBadge) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: hasBadge
          ? badge.nodeColor.withValues(alpha: 0.08)
          : badge.ringColors[0].withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: hasBadge
            ? badge.nodeColor.withValues(alpha: 0.3)
            : badge.ringColors[0].withValues(alpha: 0.25),
        width: 0.8,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: hasBadge
                ? badge.nodeColor
                : badge.ringColors[0].withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            badge.icon,
            color: hasBadge ? Colors.white : badge.ringColors[1],
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasBadge ? badge.title : 'Target Gelar',
                style: TextStyle(
                  color: hasBadge ? badge.nodeColor : Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                hasBadge
                    ? badge.description
                    : 'Raih ★★★ untuk gelar "${badge.title}"',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
        if (hasBadge)
          const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 20),
      ],
    ),
  );

  Widget _buildBriefingButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      onPressed: onPressed,
    ),
  );

  // Node level
  Widget _buildLevelNode(
    BuildContext ctx,
    _LevelConfig cfg,
    GameProvider gd,
    int idx,
  ) {
    final isLocked = gd.isLevelLocked(cfg.level);
    final stars = gd.getStars(cfg.level);
    final isActive = !isLocked && stars == 0;

    final Color nodeBg = isLocked
        ? AppColors.nodeLocked
        : (stars > 0 ? AppColors.nodeDone : AppColors.nodeActive);
    final Color nodeShadow = isLocked
        ? AppColors.nodeLockedShadow
        : (stars > 0 ? AppColors.nodeDoneShadow : AppColors.nodeActiveShadow);
    final Color nodeBorder = isLocked
        ? AppColors.nodeLockedBorder
        : (stars > 0 ? AppColors.nodeDoneBorder : AppColors.nodeActiveBorder);

    Widget core = GestureDetector(
      onTap: () => isLocked
          ? ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('Selesaikan kasus sebelumnya terlebih dahulu!'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            )
          : _showBriefing(ctx, cfg, gd),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            key: _nodeKeys[idx],
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: nodeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: nodeBorder, width: 3),
              boxShadow: [
                BoxShadow(
                  color: nodeShadow,
                  offset: const Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: isLocked
                ? const Center(
                    child: Icon(Icons.lock, color: Color(0xFF90A4AE), size: 30),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cfg.icon, color: Colors.white, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        '${cfg.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
          ),
          if (!isLocked)
            Positioned(
              bottom: -20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: i < stars ? Colors.amber : Colors.white30,
                    size: 16,
                  ),
                ),
              ),
            ),
          if (isActive)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Text(
                  'BARU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (stars >= 3)
            const Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );

    return isActive
        ? AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) =>
                Transform.scale(scale: _pulseAnim.value, child: child),
            child: core,
          )
        : core;
  }

  Widget _buildChapterLabel(String text) => Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.amber,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    ),
  );

  Widget _buildMapItem(BuildContext ctx, GameProvider gd, int idx) {
    final cfg = _levels[idx];
    final double padL = idx.isEven ? 0 : 40;
    final double padR = idx.isEven ? 40 : 0;

    return Column(
      children: [
        _buildChapterLabel(cfg.chapter),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: padL, right: padR),
          child: Align(
            alignment: idx.isEven
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: _buildLevelNode(ctx, cfg, gd, idx),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryMid,
                ],
              ),
            ),
          ),
          ..._buildStars(),
          SafeArea(
            child: Consumer<GameProvider>(
              builder: (ctx, gd, _) => Column(
                children: [
                  _buildHeader(gd),
                  Container(
                    height: 0.5,
                    color: Colors.white.withValues(alpha: 0.12),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Stack(
                        children: [
                          if (_nodePositions.length == _levels.length)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _MapPathPainter(_nodePositions),
                              ),
                            ),
                          Column(
                            children: [
                              for (int i = _levels.length - 1; i >= 0; i--)
                                _buildMapItem(ctx, gd, i),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white30,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Mulai dari sini',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.28,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: Text(
                      'Sumber: TurnBackHoax & CRAAP Meriam Library',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4), 
                        fontSize: 10, 
                        letterSpacing: 0.5,
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

  List<Widget> _buildStars() {
    final data = [
      [0.08, 0.07, 2.5],
      [0.88, 0.04, 1.8],
      [0.28, 0.13, 1.4],
      [0.68, 0.19, 2.2],
      [0.14, 0.33, 1.6],
      [0.91, 0.38, 1.1],
      [0.48, 0.52, 2.0],
      [0.04, 0.63, 1.5],
      [0.77, 0.68, 2.8],
      [0.38, 0.79, 1.3],
      [0.93, 0.83, 1.8],
      [0.21, 0.91, 0.9],
    ];
    final size = MediaQuery.of(context).size;
    return data
        .map(
          (s) => Positioned(
            left: s[0] * size.width,
            top: s[1] * size.height,
            child: Container(
              width: s[2],
              height: s[2],
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
        )
        .toList();
  }
}