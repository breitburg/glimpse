import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen_corners/screen_corners.dart';
import 'package:smooth_corner/smooth_corner.dart';

Future<void> showBulletin({
  required BuildContext context,
  required WidgetBuilder builder,
  bool draggable = true,
  bool dismissible = true,
  double height = 450,
  Color? backgroundColor,
}) async {
  await ScreenCorners.initScreenCorners();

  await Navigator.of(context).push(
    BulletinModalRoute(
      builder: builder,
      draggable: draggable,
      dragDismissible: dismissible,
      barrierDismissible: dismissible,
      height: height,
      backgroundColor: backgroundColor,
    ),
  );
}

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
    return _DraggableBulletinView(
      height: height,
      builder: builder,
      draggable: draggable,
      dragDismissible: dragDismissible,
      backgroundColor: backgroundColor,
      onClose: Navigator.of(context).pop,

      // I don't know why, but Apple decided to give this view a 9pt padding
      padding: 9.0,
    );
  }
}

class _DraggableBulletinView extends StatefulWidget {
  final bool draggable, dragDismissible;
  final WidgetBuilder builder;
  final VoidCallback onClose;
  final double height;
  final Color? backgroundColor;
  final double padding;

  const _DraggableBulletinView({
    required this.builder,
    required this.onClose,
    required this.draggable,
    required this.dragDismissible,
    required this.height,
    required this.backgroundColor,
    required this.padding,
  });

  @override
  State<_DraggableBulletinView> createState() => _DraggableBulletinViewState();
}

class _DraggableBulletinViewState extends State<_DraggableBulletinView>
    with SingleTickerProviderStateMixin {
  static const threshold = 0.95;

  late final AnimationController _controller =
      AnimationController(vsync: this, value: threshold);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: _dragDetector(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: widget.height, maxWidth: widget.height),
            child: Padding(
              padding: EdgeInsets.all(widget.padding),
              child: Material(
                clipBehavior: Clip.antiAlias,
                shape: SmoothRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    max(30, ScreenCorners.corner.value - widget.padding),
                  ),
                  smoothness: 0.6,
                ),
                color: widget.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                child: Builder(builder: widget.builder),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragDetector({required Widget child}) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (!widget.draggable) return;
        _controller.value -= details.delta.dy / widget.height;
      },
      onVerticalDragEnd: (details) async {
        final target = widget.dragDismissible ? _controller.value.round() : 1;

        await _controller.animateTo(
          target.clamp(0, threshold).toDouble(),
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 200),
        );

        if (target == 0) widget.onClose();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(
              0,
              (1 - _controller.value * (2 - threshold)) * widget.height,
            ),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
