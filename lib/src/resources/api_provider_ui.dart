import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:easy_api_provider/src/widgets/empty_widget.dart';
import 'package:easy_api_provider/src/widgets/idle_widget.dart';
import 'package:easy_api_provider/src/widgets/loading_widget.dart';
import 'package:easy_api_provider/src/widgets/success_widget.dart';
import 'package:easy_api_provider/src/widgets/error_widget.dart';
import 'package:flutter/material.dart';

typedef WidgetParam = Widget Function(BuildContext context);
typedef ResponseWidget =
    Widget Function(BuildContext context, ApiResponse? response);

class ApiProviderUi extends StatefulWidget {
  final ApiProviderController controller;
  final WidgetParam? idleWidget;
  final WidgetParam? loadingWidget;
  final WidgetParam? emptyWidget;
  final ResponseWidget? successWidget;
  final ResponseWidget? errorWidget;
  const ApiProviderUi({
    required this.controller,
    this.idleWidget,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
    this.emptyWidget,
    super.key,
  });

  @override
  State<ApiProviderUi> createState() => _ApiProviderUiState();
}

class _ApiProviderUiState extends State<ApiProviderUi> {
  @override
  void initState() {
    if (mounted) {
      widget.controller.listen((status) {
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.controller.status) {
      case ApiProviderStatus.loading:
        return widget.loadingWidget?.call(context) ?? LoadingWidget();
      case ApiProviderStatus.success:
        return widget.successWidget?.call(
              context,
              widget.controller.response,
            ) ??
            SuccessWidget();
      case ApiProviderStatus.error:
        return widget.errorWidget?.call(context, widget.controller.response) ??
            ApiErrorWidget();
      case ApiProviderStatus.empty:
        return widget.emptyWidget?.call(context) ?? EmptyWidget();
      default:
        return widget.idleWidget?.call(context) ?? IdleWidget();
    }
  }
}
