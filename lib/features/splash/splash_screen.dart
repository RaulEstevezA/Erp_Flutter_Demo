import 'package:flutter/material.dart';

import '../../core/branding/erp_logo.dart';
import '../../core/branding/erp_wordmark.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla de arranque: el logo se "construye" barra a barra y aparece el
/// nombre de la app. Al terminar la animación llama a [onFinished].
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  late final Animation<double> _logo = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6),
  );

  late final Animation<double> _text = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.violet],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.85 + 0.15 * Curves.easeOutBack.transform(_logo.value),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(31),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35 * _logo.value),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25 * _logo.value),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ErpLogo(size: 128, progress: _logo.value),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: _text.value,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - _text.value)),
                      child: Column(
                        children: [
                          const ErpWordmark(color: Colors.white, fontSize: 32),
                          const SizedBox(height: 8),
                          Text(
                            l10n.splashTagline,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
