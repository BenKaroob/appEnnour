import 'package:flutter/material.dart';
import '../utils/index.dart';

// Widget réutilisable pour afficher la Bismillah stylisée en en-tête
class BismillahHeader extends StatelessWidget {
  final bool withDivider;
  final bool isCompact;
  final Color? textColor;

  const BismillahHeader({
    Key? key,
    this.withDivider = true,
    this.isCompact = false,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorToUse = textColor ?? AppTheme.primaryColor;
    final fontSize = isCompact ? 22.0 : 28.0;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isCompact ? 8.0 : 16.0,
        horizontal: isCompact ? 8.0 : 16.0,
      ),
      child: Column(
        children: [
          // Texte Bismillah
          Text(
            AppConstants.bismillah,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: colorToUse,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Divider optionnel
          if (withDivider) ...[
            const SizedBox(height: 8),
            Container(
              width: isCompact ? 120 : 180,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    colorToUse.withOpacity(0.5),
                    colorToUse,
                    colorToUse.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Version animée de la Bismillah avec fade-in
class AnimatedBismillahHeader extends StatefulWidget {
  final bool withDivider;
  final Duration animationDuration;
  final Color? textColor;

  const AnimatedBismillahHeader({
    Key? key,
    this.withDivider = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.textColor,
  }) : super(key: key);

  @override
  State<AnimatedBismillahHeader> createState() => _AnimatedBismillahHeaderState();
}

class _AnimatedBismillahHeaderState extends State<AnimatedBismillahHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Démarrage de l'animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: BismillahHeader(
        withDivider: widget.withDivider,
        textColor: widget.textColor,
      ),
    );
  }
}