import 'package:flutter/material.dart';

class VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color defaultColor;
  final double iconSize;
  final double textSize;
  final EdgeInsets padding;
  final double spacing;

  const VoteButton({
    super.key,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.defaultColor,
    this.iconSize = 16,
    this.textSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? selectedColor : defaultColor;
    final FontWeight fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: color,
            ),
            SizedBox(width: spacing),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: fontWeight,
                fontSize: textSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}