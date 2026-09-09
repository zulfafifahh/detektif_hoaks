import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// Tombol utama berukuran penuh
class AppFullButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? icon;
  final double height;

  const AppFullButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.amber,
    this.foregroundColor = Colors.black,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: icon != null
          ? ElevatedButton.icon(
              icon: icon!,
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: _style(),
              onPressed: onPressed,
            )
          : ElevatedButton(
              style: _style(),
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  ButtonStyle _style() => ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

// Chip statistik: nilai + label + ikon opsional
class StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData? icon;

  const StatChip({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

// Filter chip horizontal
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.2) : Colors.white12,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : Colors.white24,
            width: isActive ? 1.5 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor : Colors.white54,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Scaffold dengan background biru dongker + AppBar transparan
class BlueScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool centerTitle;

  const BlueScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
      ),
      body: body,
    );
  }
}
