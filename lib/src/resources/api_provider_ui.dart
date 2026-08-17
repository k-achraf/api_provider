import 'package:easy_api_provider/src/controllers/api_provider_controller.dart';
import 'package:easy_api_provider/src/models/api_response.dart';
import 'package:easy_api_provider/src/widgets/empty_widget.dart';
import 'package:easy_api_provider/src/widgets/error_widget.dart';
import 'package:easy_api_provider/src/widgets/idle_widget.dart';
import 'package:easy_api_provider/src/widgets/loading_widget.dart';
import 'package:easy_api_provider/src/widgets/success_widget.dart';
import 'package:flutter/material.dart';

/// Callback that builds a [Widget] given a [BuildContext].
typedef WidgetParam = Widget Function(BuildContext context);

/// Callback that builds a [Widget] given a [BuildContext] and an
/// [ApiResponse].
typedef ResponseWidget = Widget Function(
  BuildContext context,
  ApiResponse<dynamic>? response,
);

/// A stateful widget that switches its child based on the current
/// [ApiProviderStatus] from the given [controller].
///
/// ### Example
///
/// ```dart
/// ApiProviderUi(
///   controller: controller,
///   transitionDuration: Duration(milliseconds: 400),
///   loadingWidget: (_) => const CircularProgressIndicator(),
///   successWidget: (_, response) => Text('${response?.data}'),
///   errorWidget: (_, response) => Text('Error: ${response?.message}'),
///   emptyWidget: (_) => const Text('Nothing here'),
/// )
/// ```
class ApiProviderUi extends StatefulWidget {
  /// Controller that drives the UI state transitions.
  final ApiProviderController controller;

  /// Widget shown when status is [ApiProviderStatus.idle].
  final WidgetParam? idleWidget;

  /// Widget shown when status is [ApiProviderStatus.loading].
  final WidgetParam? loadingWidget;

  /// Widget shown when status is [ApiProviderStatus.empty].
  final WidgetParam? emptyWidget;

  /// Widget shown when status is [ApiProviderStatus.success].
  final ResponseWidget? successWidget;

  /// Widget shown when status is [ApiProviderStatus.error].
  final ResponseWidget? errorWidget;

  /// Duration of the animated transition between states.
  ///
  /// Defaults to 300 ms. Pass [Duration.zero] to disable animation.
  final Duration transitionDuration;

  /// The curve applied when a new state widget switches **in**.
  ///
  /// Defaults to [Curves.easeIn].
  final Curve switchInCurve;

  /// The curve applied when the old state widget switches **out**.
  ///
  /// Defaults to [Curves.easeOut].
  final Curve switchOutCurve;

  /// A custom transition builder for the [AnimatedSwitcher].
  ///
  /// Use this to apply slide, scale, or any other transition effect instead
  /// of the default cross-fade. The signature matches
  /// [AnimatedSwitcher.transitionBuilder].
  ///
  /// Example — slide-up transition:
  /// ```dart
  /// transitionBuilder: (child, animation) => SlideTransition(
  ///   position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
  ///       .animate(animation),
  ///   child: FadeTransition(opacity: animation, child: child),
  /// ),
  /// ```
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// Creates an [ApiProviderUi] widget driven by the given [controller].
  ///
  /// All state-specific builder callbacks are optional — a sensible default
  /// widget is shown for any callback that is omitted.
  const ApiProviderUi({
    required this.controller,
    this.idleWidget,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
    this.emptyWidget,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.switchInCurve = Curves.easeIn,
    this.switchOutCurve = Curves.easeOut,
    this.transitionBuilder,
    super.key,
  });

  @override
  State<ApiProviderUi> createState() => _ApiProviderUiState();
}

class _ApiProviderUiState extends State<ApiProviderUi> {
  // P4: cache last status to skip rebuilds when the status hasn't changed
  ApiProviderStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStatusChanged);
  }

  @override
  void didUpdateWidget(ApiProviderUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fix: properly handle controller swap to avoid stale listeners
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onStatusChanged);
      widget.controller.addListener(_onStatusChanged);
      _lastStatus = null; // force a rebuild with the new controller's state
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged() {
    if (mounted && widget.controller.status != _lastStatus) {
      _lastStatus = widget.controller.status;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      switchInCurve: widget.switchInCurve,
      switchOutCurve: widget.switchOutCurve,
      transitionBuilder: widget.transitionBuilder ??
          AnimatedSwitcher.defaultTransitionBuilder,
      child: _buildCurrentState(),
    );
  }

  Widget _buildCurrentState() {
    switch (widget.controller.status) {
      case ApiProviderStatus.loading:
        return widget.loadingWidget?.call(context) ??
            const LoadingWidget(key: ValueKey('loading'));
      case ApiProviderStatus.success:
        return widget.successWidget?.call(
              context,
              widget.controller.response,
            ) ??
            const SuccessWidget(key: ValueKey('success'));
      case ApiProviderStatus.error:
        return widget.errorWidget?.call(
              context,
              widget.controller.response,
            ) ??
            const ApiErrorWidget(key: ValueKey('error'));
      case ApiProviderStatus.empty:
        return widget.emptyWidget?.call(context) ??
            const EmptyWidget(key: ValueKey('empty'));
      default:
        return widget.idleWidget?.call(context) ??
            const IdleWidget(key: ValueKey('idle'));
    }
  }
}
