import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_ume_kit_env/src/env_parser.dart';
import 'package:flutter_ume_kit_env/src/models/env_config.dart';

class EnvExplorer {
  final String baseDirectory;

  List<String> files = [];

  EnvExplorer({this.baseDirectory = ''});

  initExplorer({required BuildContext context, bool reset = false}) async {
    if (files.isNotEmpty && !reset) {
      return;
    }

    final targetDir = '${baseDirectory}env';
    final String manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    List<String> envFiles = json.decode(manifestJson).keys.where((String key) {
      return key.startsWith(targetDir);
    }).toList();
    files = envFiles;
  }

  Future<List<EnvConfig>> loadConfigs() async {
    List<EnvConfig> configs = [];
    for (int i = 0; i < files.length; i++) {
      final filename = files[i];
      final lines = await _loadKeyValuesFromFile(filename);
      if (lines != null) {
        final entries = const EnvParser().parse(lines);
        configs.add(
          EnvConfig(
            filename: filename.replaceFirst(baseDirectory, ''),
            entries: entries,
          ),
        );
      }
    }
    return configs;
  }

  Future<List<String>?> _loadKeyValuesFromFile(String filename) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      var envString = await rootBundle.loadString(filename);
      if (envString.isEmpty) {
        throw Error();
      }
      return envString.split('\n');
    } catch (error) {
      return null;
    }
  }
}
