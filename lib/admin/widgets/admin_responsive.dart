import 'package:flutter/material.dart';

class AdminBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

class AdminResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const AdminResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AdminBreakpoints.tablet && desktop != null) {
          return desktop!(context);
        }
        if (constraints.maxWidth >= AdminBreakpoints.mobile && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

class AdminResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const AdminResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth >= AdminBreakpoints.tablet) {
          crossAxisCount = 4;
          childAspectRatio = 1.6;
        } else if (constraints.maxWidth >= AdminBreakpoints.mobile) {
          crossAxisCount = 2;
          childAspectRatio = 1.8;
        } else {
          crossAxisCount = 2; // 2x2 grid on mobile phones!
          childAspectRatio = 1.35;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}