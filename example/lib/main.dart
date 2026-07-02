import 'package:dio/dio.dart';
import 'package:example/custom_router_pluggable.dart';
import 'package:example/detail_page.dart';
import 'package:example/home_page.dart';
import 'package:example/ume_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';
import 'package:flutter_ume_kit_env/flutter_ume_kit_env.dart';
import 'package:flutter_ume_kit_ui/flutter_ume_kit_ui.dart';
import 'package:flutter_ume_kit_perf/flutter_ume_kit_perf.dart';
import 'package:flutter_ume_kit_show_code/flutter_ume_kit_show_code.dart';
import 'package:flutter_ume_kit_device/flutter_ume_kit_device.dart';
import 'package:flutter_ume_kit_console/flutter_ume_kit_console.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ume_kit_dio/flutter_ume_kit_dio.dart';
import 'package:flutter_ume_kit_channel_monitor/flutter_ume_kit_channel_monitor.dart';

final Dio dio = Dio()..options = BaseOptions();
final DioConfig dioConfig = DioConfig(dio: dio, tag: 'Default');

final navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(const UMEApp());

class UMEApp extends StatefulWidget {
  const UMEApp({Key? key}) : super(key: key);

  @override
  State<UMEApp> createState() => _UMEAppState();
}

class _UMEAppState extends State<UMEApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomRouterPluggable().navKey = navigatorKey;
    });
    if (kDebugMode) {
      PluginManager.instance
        ..register(EnvSwitcher(
          envConfigs: [
            EnvConfig(
              filename: 'prod',
              entries: {
                'CURRENT_ENV': 'prod',
                'API_URL': 'https://api.prod.com',
                'APP_NAME': 'My App (Production)',
              },
            ),
            EnvConfig(
              filename: 'staging',
              entries: {
                'CURRENT_ENV': 'staging',
                'API_URL': 'https://api.staging.com',
                'APP_NAME': 'My App (Staging)',
              },
            ),
            EnvConfig(
              filename: 'dev',
              entries: {
                'CURRENT_ENV': 'dev',
                'API_URL': 'https://api.dev.com',
                'APP_NAME': 'My App (Development)',
              },
            ),
          ],
          onChangeEnv: (String envName) async {
            debugPrint('Switch to $envName');
            return true;
          },
          currentEnv: 'staging',
        ))
        ..register(WidgetInfoInspector())
        ..register(WidgetDetailInspector())
        ..register(ColorSucker())
        ..register(AlignRuler())
        ..register(ColorPicker())
        ..register(TouchIndicator())
        ..register(Performance())
        ..register(ShowCode())
        ..register(MemoryInfoPage())
        ..register(CpuInfoPage())
        ..register(DeviceInfoPanel())
        ..register(Console())
        ..register(DioInspector(
          configs: [dioConfig],
          actions: [
            DioAction(
              text: 'Copy📋',
              onAction: (response) async {
                ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                  const SnackBar(content: Text('Copied Successfully')),
                );
              },
            ),
            //   DioAction(
            //     text: 'Upload⏫',
            //     onAction: (response) async {
            //       ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            //         const SnackBar(content: Text('Upload Successfully')),
            //       );
            //     },
            //   ),
          ],
        ))
        ..register(CustomRouterPluggable())
        ..register(ChannelPlugin());
    }
  }

  Widget _buildApp(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'UME Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(title: 'UME Demo Home Page'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'detail':
            return MaterialPageRoute(builder: (_) => const DetailPage());
          default:
            return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = _buildApp(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UMESwitch()),
      ],
      builder: (BuildContext context, _) {
        if (kDebugMode) {
          return UMEWidget(
            enable: context.watch<UMESwitch>().enable,
            child: body,
          );
        }
        return body;
      },
    );
  }
}
