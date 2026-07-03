///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 11:24
///

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' show Dio, Response;
import 'package:flutter_ume/core/pluggable.dart';

import 'models/http_interceptor.dart';
import 'widgets/icon.dart' as icon;
import 'widgets/pluggable_state.dart';

/// Configuration for a single Dio instance with an associated tag.
///
/// The [tag] will be displayed in the request list to help identify
/// which Dio instance a request originated from.
class DioConfig {
  const DioConfig({required this.dio, required this.tag});
  final Dio dio;
  final String tag;
}

typedef DioItemActionCallback = Future<void> Function(
    Response<dynamic> response);

/// An action that can be performed on a response card.
///
/// Each [DioAction] renders as a button labeled with [text], and supports
/// onTap, onDoubleTap, and onLongPress gestures.
class DioAction {
  const DioAction({
    required this.text,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  /// The button label for this action.
  final String text;

  /// Callback invoked when the action button is tapped.
  final DioItemActionCallback? onTap;

  /// Callback invoked when the action button is double-tapped.
  final DioItemActionCallback? onDoubleTap;

  /// Callback invoked when the action button is long-pressed.
  final DioItemActionCallback? onLongPress;
}

// TODO(Alex): Implement [PluggableStream] for dot features.
/// Implement a [Pluggable] to integrate with UME.
///
/// Pass multiple [DioConfig] instances to monitor requests from
/// different Dio instances, each identified by its [DioConfig.tag].
class DioInspector extends StatefulWidget implements Pluggable {
  DioInspector({
    Key? key,
    required this.configs,
    this.actions,
  }) : super(key: key) {
    for (final config in configs) {
      config.dio.interceptors.add(UMEDioInterceptor(tag: config.tag));
    }
  }

  final List<DioConfig> configs;

  /// Optional list of actions shown on each response card.
  ///
  /// Each action renders as a button with onTap/onDoubleTap/onLongPress support.
  final List<DioAction>? actions;
  @override
  DioPluggableState createState() => DioPluggableState();

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  String get name => 'DioInspector';

  @override
  String get displayName => 'DioInspector';

  @override
  void onTrigger() {}

  @override
  Widget buildWidget(BuildContext? context) => this;
}
