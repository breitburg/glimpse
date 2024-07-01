import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:screen_corners/screen_corners.dart';
import 'package:smooth_corner/smooth_corner.dart';

/// Initializes Glimpse
///
/// It is recommended to call this function in [main] before calling [runApp].
/// This function is required to initialize [ScreenCorners] for iOS.
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
/// [constraints] is the constraints for the glimpse view. It defaults to a height of 450.
/// [margin] is the margin around the glimpse view. It defaults to 10.
/// [backgroundColor] is the background color of the glimpse view. It defaults to the scaffold background color.
/// [borderRadius] is the border radius for the glimpse view. It defaults to a circular border radius with a minimum of 20.
Future<void> showGlimpse({
  required BuildContext context,
  required WidgetBuilder builder,
  bool rootNavigator = true,
  bool draggable = true,
  bool dismissible = true,
  BoxConstraints constraints = const BoxConstraints.tightFor(height: 450),
  double margin = 10,
  Color? backgroundColor,
  BorderRadiusGeometry? borderRadius,
}) async {
  initializeGlimpse().then((_) {
    Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).push(GlimpseModalRoute(
      builder: builder,
      draggable: draggable,
      dismissible: dismissible,
      constraints: constraints,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
    ));
  });
}

/// A glimpse page that shows a glimpse view (AirPods-like)
///
/// This page is used by [Navigator] to show a glimpse view.
/// It is a wrapper around [GlimpseModalRoute].
///
/// [builder] is the builder for the glimpse view. It is required.
/// [key] is the key for the glimpse page.
/// [name] is the name for the glimpse page.
/// [arguments] are the arguments for the glimpse page.
/// [restorationId] is the restoration ID for the glimpse page.
/// [draggable] determines whether the glimpse view can be dragged up and down.
/// [dismissible] determines whether the glimpse view can be dismissed by dragging it down or by tapping the barrier.
/// [constraints] is the constraints for the glimpse view. It defaults to a height of 450.
/// [margin] is the margin around the glimpse view. It defaults to 10.
/// [backgroundColor] is the background color of the glimpse view. It defaults to the scaffold background color.
/// [borderRadius] is the border radius for the glimpse view. It defaults to a circular border radius with a minimum of 20.
class GlimpseModalPage extends Page<void> {
  final BoxConstraints constraints;
  final double margin;
  final BorderRadiusGeometry? borderRadius;
  final bool draggable;
  final bool dismissible;
  final Color? backgroundColor;
  final WidgetBuilder builder;

  const GlimpseModalPage({
    required this.builder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    this.draggable = true,
    this.dismissible = true,
    this.constraints = const BoxConstraints.tightFor(height: 450),
    this.margin = 10,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Route<void> createRoute(BuildContext context) {
    return GlimpseModalRoute(
      builder: builder,
      settings: this,
      draggable: draggable,
      dismissible: dismissible,
      constraints: constraints,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
    );
  }
}

/// A modal route that shows a glimpse view (AirPods-like)
///
/// This route is used by [showGlimpse] to show a glimpse view.
///
/// The route is built using [PageRouteBuilder] and uses a [SlideTransition]
/// to animate the route in and out.
///
/// [constraints] is the constraints for the glimpse view. It defaults to a height of 450.
/// [margin] is the margin around the glimpse view. It defaults to 10.
/// [draggable] determines whether the glimpse view can be dragged up and down.
/// [dismissible] determines whether the glimpse view can be dismissed by dragging it down or by tapping the barrier.
/// [backgroundColor] is the background color of the glimpse view. It defaults to the scaffold background color.
/// [builder] is the builder for the glimpse view. It is required.
/// [borderRadius] is the border radius for the glimpse view. It defaults to a circular border radius with a minimum of 20.
class GlimpseModalRoute extends PageRouteBuilder {
  final BoxConstraints constraints;
  final double margin;
  final BorderRadiusGeometry? borderRadius;
  final bool draggable;
  final bool dismissible;
  final WidgetBuilder builder;
  final Color? backgroundColor;

  GlimpseModalRoute({
    required this.builder,
    this.draggable = true,
    this.dismissible = true,
    this.constraints = const BoxConstraints.tightFor(height: 450),
    this.margin = 10,
    this.borderRadius,
    this.backgroundColor,
    super.barrierColor = const Color(0x99000000),
    super.settings,
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
      constraints: constraints,
      builder: builder,
      draggable: draggable,
      dragDismissible: dismissible,
      backgroundColor: backgroundColor,
      onClose: Navigator.of(context).pop,
      borderRadius: borderRadius ??
          BorderRadius.circular(
            max(20, ScreenCorners.corner.value - margin),
          ),
      margin: margin,
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
  final BoxConstraints constraints;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;
  final double margin;

  const _DraggableGlimpseView({
    required this.builder,
    required this.onClose,
    required this.draggable,
    required this.dragDismissible,
    required this.constraints,
    required this.backgroundColor,
    required this.borderRadius,
    required this.margin,
  });

  @override
  State<_DraggableGlimpseView> createState() => _DraggableGlimpseViewState();
}

class _DraggableGlimpseViewState extends State<_DraggableGlimpseView>
    with SingleTickerProviderStateMixin {
  /// The threshold for the drag animation
  ///
  /// This value is used to determine the threshold for the drag animation.
  /// It is used to determine when the glimpse view should be dismissed.
  static const threshold = 0.95;

  /// The controller for the drag animation
  ///
  /// This controller is used to animate the drag events.
  /// It is used to animate the glimpse view when it is dragged up and down.
  late final AnimationController _controller =
      AnimationController(vsync: this, value: threshold);

  /// Initializes the state
  ///
  /// This function is called when the state is initialized.
  /// It is used to set the system UI mode to immersive.
  @override
  void initState() {
    if (Platform.isIOS) {
      // Make the status bar and home indicator hidden on iOS
      // to match the behavior of the AirPods popup
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    super.initState();
  }

  /// Disposes the state
  ///
  /// This function is called when the state is disposed.
  /// It is used to set the system UI mode to edgeToEdge and dispose the controller.
  @override
  void dispose() {
    if (Platform.isIOS) {
      // Make the status bar and home indicator visible on iOS
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            // Center the glimpse view on large screens
            alignment: constraints.biggest.height > 900
                ? Alignment.center
                : Alignment.bottomCenter,
            child: MediaQuery.removePadding(
              context: context,
              child: _dragDetector(
                child: ConstrainedBox(
                  constraints: widget.constraints,
                  child: SmoothCard(
                    margin: EdgeInsets.all(widget.margin),
                    borderRadius: widget.borderRadius,
                    smoothness: 0.6,
                    color: widget.backgroundColor ??
                        CupertinoTheme.of(context).scaffoldBackgroundColor,
                    child: Builder(builder: widget.builder),
                  ),
                ),
              ),
            ),
          );
        },
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
        _controller.value -= details.delta.dy / widget.constraints.maxHeight;
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
              (threshold - _controller.value) * widget.constraints.maxHeight +
                  (1 - _controller.value) * widget.margin,
            ),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
