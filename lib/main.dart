import 'package:flutter/material.dart';

void main() {
  runApp(const FlowApp());
}

enum FlowStyle { vertical, horizontal, diagonal }

class FlowApp extends StatefulWidget {
  const FlowApp({super.key});

  @override
  State<FlowApp> createState() => _FlowAppState();
}

class _FlowAppState extends State<FlowApp> {
  FlowStyle flowStyle = FlowStyle.vertical;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              const Color(0xFF0F52BA),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Flow Example',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(
          children: [
            FlowMenu(
              flowStyle: flowStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: (flowStyle == FlowStyle.horizontal)
                        ? null
                        : MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    setState(() {
                      flowStyle = FlowStyle.horizontal;
                    });
                  },
                  child: const Text(
                    'Horizontal',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: (flowStyle == FlowStyle.vertical)
                        ? null
                        : MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    setState(() {
                      flowStyle = FlowStyle.vertical;
                    });
                  },
                  child: const Text(
                    'Vertical',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: (flowStyle == FlowStyle.diagonal)
                        ? null
                        : MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    setState(() {
                      flowStyle = FlowStyle.diagonal;
                    });
                  },
                  child: const Text(
                    'Diagonal',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FlowMenu extends StatefulWidget {
  const FlowMenu({super.key, required this.flowStyle});
  final FlowStyle flowStyle;

  @override
  State<FlowMenu> createState() => _FlowMenuState();
}

class _FlowMenuState extends State<FlowMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController menuAnimation;
  IconData lastTapped = Icons.notifications;

  final List<IconData> menuItems = <IconData>[
    Icons.home,
    Icons.pin,
    Icons.notifications,
    Icons.settings,
    Icons.menu,
  ];

  void _updateMenu(IconData icon) {
    if (icon != Icons.menu) {
      setState(() => lastTapped = icon);
    }
  }

  @override
  void initState() {
    super.initState();
    menuAnimation = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  Widget flowMenuItem(IconData icon) {
    final double buttonDiameter =
        MediaQuery.of(context).size.width * 0.7 / menuItems.length;
    return RawMaterialButton(
      fillColor: lastTapped == icon ? Colors.green : const Color(0xFF0F52BA),
      shape: const CircleBorder(),
      constraints: BoxConstraints.tight(Size(buttonDiameter, buttonDiameter)),
      onPressed: () {
        _updateMenu(icon);
        menuAnimation.status == AnimationStatus.completed
            ? menuAnimation.reverse()
            : menuAnimation.forward();
      },
      child: Icon(
        icon,
        color: Colors.white,
        size: 45.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double buttonDiameter =
        MediaQuery.of(context).size.width * 0.7 / menuItems.length;
    return Flow(
      delegate: switch (widget.flowStyle) {
        FlowStyle.vertical => FlowVerticalDelegate(
            menuAnimation: menuAnimation, buttonSize: buttonDiameter),
        FlowStyle.horizontal => FlowHorizontal(
            menuAnimation: menuAnimation, buttonSize: buttonDiameter),
        FlowStyle.diagonal => FlowDiagonalDelegate(
            menuAnimation: menuAnimation, buttonSize: buttonDiameter),
      },
      children:
          menuItems.map<Widget>((IconData icon) => flowMenuItem(icon)).toList(),
    );
  }
}

class FlowVerticalDelegate extends FlowDelegate {
  FlowVerticalDelegate({required this.menuAnimation, required this.buttonSize})
      : super(repaint: menuAnimation);

  final Animation<double> menuAnimation;
  final double buttonSize;

  @override
  bool shouldRepaint(FlowVerticalDelegate oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dy = 0.0;
    double startX = context.size.width - buttonSize - 20;
    double startY = context.size.height - buttonSize - 20;
    for (int i = 0; i < context.childCount; ++i) {
      dy = ((context.getChildSize(i)?.height ?? 0) + 8) * i;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          startX,
          startY - (dy * menuAnimation.value),
          0,
        ),
      );
    }
  }
}

class FlowHorizontal extends FlowDelegate {
  FlowHorizontal({required this.menuAnimation, required this.buttonSize})
      : super(repaint: menuAnimation);

  final Animation<double> menuAnimation;
  final double buttonSize;

  @override
  bool shouldRepaint(FlowHorizontal oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dx = 0.0;
    double startX = context.size.width - buttonSize - 20;
    double startY = context.size.height - buttonSize - 20;
    for (int i = 0; i < context.childCount; ++i) {
      dx = ((context.getChildSize(i)?.width ?? 0) + 8) * i;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          startX - (dx * menuAnimation.value),
          startY,
          0,
        ),
      );
    }
  }
}

class FlowDiagonalDelegate extends FlowDelegate {
  FlowDiagonalDelegate({required this.menuAnimation, required this.buttonSize})
      : super(repaint: menuAnimation);

  final Animation<double> menuAnimation;
  final double buttonSize;

  @override
  bool shouldRepaint(FlowDiagonalDelegate oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dx = 0.0;
    double dy = 0.0;
    double startX = context.size.width - buttonSize - 20;
    double startY = context.size.height - buttonSize - 20;
    for (int i = 0; i < context.childCount; ++i) {
      dx = ((context.getChildSize(i)?.width ?? 0) + 8) * i;
      dy = ((context.getChildSize(i)?.height ?? 0) + 8) * i;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          startX - (dx * menuAnimation.value),
          startY - (dy * menuAnimation.value),
          0,
        ),
      );
    }
  }
}
