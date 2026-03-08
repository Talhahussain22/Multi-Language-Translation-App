import 'package:flutter/material.dart';

class QuizOptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const QuizOptionTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = const Color.fromRGBO(0, 51, 102, 1);

    Color borderColor = Colors.grey.shade200;
    Color bgColor = Colors.white;
    Color textColor = Colors.grey.shade900;
    IconData? icon;
    Color? iconColor;

    if (isCorrect) {
      borderColor = Colors.green.shade500;
      bgColor = Colors.green.shade50;
      icon = Icons.check_circle;
      iconColor = Colors.green.shade600;
    } else if (isWrong) {
      borderColor = Colors.red.shade400;
      bgColor = Colors.red.shade50;
      icon = Icons.cancel;
      iconColor = Colors.red.shade500;
    } else if (isSelected) {
      borderColor = base.withValues(alpha: 0.45);
      bgColor = base.withValues(alpha: 0.06);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 10),
                Icon(icon, color: iconColor, size: 22),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

