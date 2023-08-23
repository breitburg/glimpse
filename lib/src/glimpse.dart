import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen_corners/screen_corners.dart';
import 'package:smooth_corner/smooth_corner.dart';

Future<void> initializeGlimpse() async {
  await ScreenCorners.initScreenCorners();
}

/// Shows a glimpse view (AirPods-like popup)
///
/// This function shows a glimpse view using [GlimpseModalRoute].
/// It is a wrapper around [Navigator.of(context).push].
/// It is recommended to use this function instead of [Navigator.of(context).push].
///
/// [builder] is the builder for the glimpse view. It is required.
/// [rootNavigator] determines whether the glimpse view should be pushed to the root navigator.
/// [draggable] determines whether the glimpse view can be dragged up and down.
/// [dismissible] determines whether the glimpse view can be dismissed by dragging it down or by tapping on the barrier.
/// [height] is the height of the glimpse view. It defaults to 450.
/// [backgroundColor] is the background color of the glimpse view. It defaults to the scaffold background color.
Future<void> showGlimpse({
  required BuildContext context,
  required WidgetBuilder builder,
  bool rootNavigator = true,
  bool draggable = true,
  bool dismissible = true,
  double height = 450,
  Color? backgroundColor,
}) async {
  await initializeGlimpse();

  await Navigator.of(
    context,
    rootNavigator: rootNavigator,
  ).push(
    GlimpseModalRoute(
      builder: builder,
      draggable: draggable,
      dismissible: dismissible,
      height: height,
      backgroundColor: backgroundColor,
    ),
  );
}

/// A modal route that shows a glimpse view (AirPods-like)
///
/// This route is used by [showGlimpse] to show a glimpse view.
///
/// The route is built using [PageRouteBuilder] and uses a [SlideTransition]
/// to animate the route in and out.
///
/// [height] is the height of the glimpse view. It defaults to 450.
/// [draggable] determines whether the glimpse view can be dragged up and down.
/// [dismissible] determines whether the glimpse view can be dismissed by dragging it down or by tapping the barrier.
/// [backgroundColor] is the background color of the glimpse view. It defaults to the scaffold background color.
/// [builder] is the builder for the glimpse view. It is required.
class GlimpseModalRoute extends PageRouteBuilder {
  final double height;
  final bool draggable, dismissible;
  final WidgetBuilder builder;
  final Color? backgroundColor;

  GlimpseModalRoute({
    required this.builder,
    this.draggable = true,
    this.dismissible = true,
    this.height = 450,
    this.backgroundColor,
    super.barrierColor = const Color.fromARGB(135, 68, 68, 68),
  }) : super(
          pageBuilder: (_, __, ___) => const SizedBox.shrink(),
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          barrierDismissible: dismissible,
          fullscreenDialog: true,
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
    return _DraggableGlimpseView(
      height: height,
      builder: builder,
      draggable: draggable,
      dragDismissible: dismissible,
      backgroundColor: backgroundColor,
      onClose: Navigator.of(context).pop,
      padding: 10.0,
    );
  }
}

/// A draggable glimpse view that is responsible for the drag animation
///
/// This widget is used by [GlimpseModalRoute] to show a glimpse view.
/// It is responsible for the drag animation and the dismiss animation.
class _DraggableGlimpseView extends StatefulWidget {
  final bool draggable, dragDismissible;
  final WidgetBuilder builder;
  final VoidCallback onClose;
  final double height;
  final Color? backgroundColor;
  final double padding;

  const _DraggableGlimpseView({
    required this.builder,
    required this.onClose,
    required this.draggable,
    required this.dragDismissible,
    required this.height,
    required this.backgroundColor,
    required this.padding,
  });

  @override
  State<_DraggableGlimpseView> createState() => _DraggableGlimpseViewState();
}

class _DraggableGlimpseViewState extends State<_DraggableGlimpseView>
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
            constraints: BoxConstraints.expand(height: widget.height),
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

  /// Wraps the child with a [GestureDetector] to detect drag events
  ///
  /// This widget is used by [_DraggableGlimpseView] to detect drag events.
  /// It is responsible for the drag animation.
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
              (threshold - _controller.value) * widget.height +
                  (1 - _controller.value) * widget.padding,
            ),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
