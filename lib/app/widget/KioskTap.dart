import 'package:flutter/material.dart';

typedef KioskTapBuilder = Widget Function(
  BuildContext context,
  bool pressed,
  Widget child,
);

class KioskTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final HitTestBehavior behavior;
  final EdgeInsetsGeometry touchPadding;
  final double moveTolerance;
  final double releaseTolerance;
  final Duration maxTapDuration;
  final Duration debounceDuration;
  final ValueChanged<bool>? onPressedChanged;
  final KioskTapBuilder? builder;

  const KioskTap({
    Key? key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
    this.touchPadding = EdgeInsets.zero,
    this.moveTolerance = 80,
    this.releaseTolerance = 32,
    this.maxTapDuration = const Duration(milliseconds: 900),
    this.debounceDuration = const Duration(milliseconds: 350),
    this.onPressedChanged,
    this.builder,
  }) : super(key: key);

  @override
  State<KioskTap> createState() => _KioskTapState();
}

class _KioskTapState extends State<KioskTap> {
  int? _activePointer;
  Offset? _downPosition;
  DateTime? _downTime;
  DateTime? _lastTapTime;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    widget.onPressedChanged?.call(value);
  }

  bool _containsGlobalPosition(Offset globalPosition, {double inflate = 0}) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;

    final localPosition = renderObject.globalToLocal(globalPosition);
    final rect = Offset.zero & renderObject.size;
    return rect.inflate(inflate).contains(localPosition);
  }

  bool _canTriggerTap() {
    final now = DateTime.now();
    final lastTapTime = _lastTapTime;
    if (lastTapTime == null) return true;
    return now.difference(lastTapTime) >= widget.debounceDuration;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled || widget.onTap == null || _activePointer != null) {
      return;
    }

    _activePointer = event.pointer;
    _downPosition = event.position;
    _downTime = DateTime.now();
    _setPressed(true);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;

    final downPosition = _downPosition;
    if (downPosition == null) return;

    final movedTooFar =
        (event.position - downPosition).distance > widget.moveTolerance;
    final stillNearButton = _containsGlobalPosition(
      event.position,
      inflate: widget.releaseTolerance,
    );

    _setPressed(!movedTooFar || stillNearButton);
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) return;

    final downPosition = _downPosition;
    final downTime = _downTime;
    final wasPressed = _pressed;

    _activePointer = null;
    _downPosition = null;
    _downTime = null;
    _setPressed(false);

    if (!widget.enabled ||
        widget.onTap == null ||
        downPosition == null ||
        downTime == null ||
        !wasPressed) {
      return;
    }

    final duration = DateTime.now().difference(downTime);
    final distance = (event.position - downPosition).distance;
    final releasedNearButton = _containsGlobalPosition(
      event.position,
      inflate: widget.releaseTolerance,
    );

    if (duration <= widget.maxTapDuration &&
        (distance <= widget.moveTolerance || releasedNearButton) &&
        _canTriggerTap()) {
      _lastTapTime = DateTime.now();
      widget.onTap?.call();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    _downPosition = null;
    _downTime = null;
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.builder == null
        ? widget.child
        : widget.builder!(context, _pressed, widget.child);

    return Listener(
      behavior: widget.behavior,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: Padding(
        padding: widget.touchPadding,
        child: content,
      ),
    );
  }
}
