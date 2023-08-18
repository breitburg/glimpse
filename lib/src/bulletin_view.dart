import 'package:flutter/material.dart';

class DraggableBulletinView extends StatefulWidget {
  final bool draggable, dragDismissible;
  final WidgetBuilder builder;
  final VoidCallback onClose;
  final double height;
  final Color? backgroundColor;

  const DraggableBulletinView({
    super.key,
    required this.builder,
    required this.onClose,
    required this.draggable,
    required this.dragDismissible,
    required this.height,
    required this.backgroundColor,
  });

  @override
  State<DraggableBulletinView> createState() => _DraggableBulletinViewState();
}

class _DraggableBulletinViewState extends State<DraggableBulletinView>
    with SingleTickerProviderStateMixin {
  static const threshold = 0.95;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: threshold,
  );

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: _dragDetector(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.height + bottomPadding,
              maxWidth: widget.height,
            ),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 8, right: 8, bottom: bottomPadding),
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.antiAlias,
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
