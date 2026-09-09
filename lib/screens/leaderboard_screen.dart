import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../services/supabase_service.dart';
import '../widgets/common/app_widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.getLeaderboard();
  }

  Future<void> _refresh() async {
    final next = SupabaseService.getLeaderboard();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final myId = SupabaseService.currentUser?.id;

    return BlueScaffold(
      title: 'Leaderboard',
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.amber),
            );
          }

          if (snapshot.hasError) {
            return _buildError();
          }

          final data = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.amber,
            backgroundColor: AppColors.primaryDark,
            child: data.isEmpty
                ? _buildEmpty()
                : _buildList(data, myId),
          );
        },
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> data, String? myId) {
    final myIndex = myId == null
        ? -1
        : data.indexWhere((row) => row['id'] == myId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (myIndex != -1) _buildMyRankCard(data[myIndex], myIndex),
        ...List.generate(
          data.length,
          (i) => _LeaderboardTile(
            rank: i + 1,
            row: data[i],
            isMe: myId != null && data[i]['id'] == myId,
          ),
        ),
      ],
    );
  }

  Widget _buildMyRankCard(Map<String, dynamic> row, int index) {
    final rank = index + 1;
    final skor = (row['skor_total'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.military_tech, color: AppColors.amber, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Posisi Kamu',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Peringkat #$rank',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$skor',
                style: const TextStyle(
                  color: AppColors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const Text(
                'Reputasi',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.22),
      const Icon(
        Icons.leaderboard_outlined,
        color: Colors.white24,
        size: 64,
      ),
      const SizedBox(height: 16),
      const Text(
        'Papan peringkat masih kosong',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38, fontSize: 15),
      ),
      const SizedBox(height: 6),
      const Text(
        'Selesaikan kasus untuk mengumpulkan reputasi!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 13),
      ),
    ],
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white38, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat papan peringkat',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Periksa koneksi internet kamu, lalu coba lagi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white38),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> row;
  final bool isMe;

  const _LeaderboardTile({
    required this.rank,
    required this.row,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final nama = (row['nama'] as String?) ?? 'Detektif';
    final avatar = (row['avatar'] as String?) ?? 'boy';
    final skor = (row['skor_total'] as num?)?.toInt() ?? 0;

    final medalColor = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.amber.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? AppColors.amber.withValues(alpha: 0.5)
              : Colors.white12,
          width: isMe ? 1.4 : 0.8,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: medalColor != null
                ? Icon(Icons.emoji_events, color: medalColor, size: 24)
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.amber,
            child: Icon(
              avatar == 'boy' ? Icons.face : Icons.face_3,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? '$nama (Kamu)' : nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$skor',
            style: const TextStyle(
              color: AppColors.amber,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
