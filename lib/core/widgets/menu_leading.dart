import 'package:flutter/material.dart';

/// Leading de los AppBar de sección: botón ☰ y, si cabe, flecha atrás.
///
/// Con `leadingWidth: 48` solo se ve el menú; con 96 aparece también la
/// flecha cuando hay [onBack] o una ruta que cerrar. Si la pantalla es un
/// detalle apilado, el menú primero vuelve a la raíz y luego abre el drawer.
class MenuLeading extends StatelessWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onBack;

  const MenuLeading({super.key, this.onOpenDrawer, this.onBack});

  static const double compactWidth = 48;
  static const double fullWidth = 96;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navigator = Navigator.of(context);
        final showBack = constraints.maxWidth >= fullWidth &&
            (onBack != null || navigator.canPop());

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              onPressed: onOpenDrawer == null
                  ? null
                  : () {
                      navigator.popUntil((route) => route.isFirst);
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => onOpenDrawer!());
                    },
            ),
            if (showBack)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack ?? navigator.pop,
              ),
          ],
        );
      },
    );
  }
}
