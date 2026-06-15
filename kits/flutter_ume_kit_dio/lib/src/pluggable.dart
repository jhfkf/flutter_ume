///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 11:24
///

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' show Dio;
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

// TODO(Alex): Implement [PluggableStream] for dot features.
/// Implement a [Pluggable] to integrate with UME.
///
/// Pass multiple [DioConfig] instances to monitor requests from
/// different Dio instances, each identified by its [DioConfig.tag].
class DioInspector extends StatefulWidget implements Pluggable {
  DioInspector({Key? key, required this.configs}) : super(key: key) {
    for (final config in configs) {
      config.dio.interceptors.add(UMEDioInterceptor(tag: config.tag));
    }
  }

  final List<DioConfig> configs;

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
