import 'package:flutter/widgets.dart';
import 'package:moda/src/bulletin_view.dart';

class BulletinModalRoute extends PageRouteBuilder {
  final double height;
  final bool draggable, dragDismissible;
  final WidgetBuilder builder;
  final Color? backgroundColor;

  BulletinModalRoute({
    required this.builder,
    this.draggable = true,
    this.dragDismissible = true,
    this.height = 450,
    this.backgroundColor,
    super.barrierDismissible = true,
    super.barrierColor = const Color.fromARGB(107, 68, 68, 68),
  }) : super(
          pageBuilder: (_, __, ___) => const SizedBox.shrink(),
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: animation
          .drive(CurveTween(curve: Curves.easeOutCirc))
          .drive(Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)),
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableBulletinView(
        builder: builder,
        draggable: draggable,
        dragDismissible: dragDismissible,
        height: height,
        onClose: Navigator.of(context).pop,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
