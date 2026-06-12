import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';
import 'package:flutter_ume_kit_env/src/env_explorer.dart';
import 'package:flutter_ume_kit_env/src/icon.dart' as icon;
import 'package:flutter_ume_kit_env/src/models/env_config.dart';
import 'package:flutter_ume_kit_env/src/widgets/env_tile.dart';

class EnvSwitcher extends StatefulWidget implements Pluggable {
  const EnvSwitcher({
    Key? key,
    this.baseDirectory = '/env',
    this.currentFilename = 'prod',
    this.envConfigs,
    required this.onChangeEnv,
  }) : super(key: key);

  /// 环境路径（通过文件读取时使用）
  final String baseDirectory;

  /// 当前环境名
  final String currentFilename;

  /// 环境配置列表（直接传入，优先级高于文件读取）
  final List<EnvConfig>? envConfigs;

  /// 切换环境回调
  final Function(String envName) onChangeEnv;

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get displayName => 'env';

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'env';

  @override
  void onTrigger() {}

  @override
  _EnvSwitcherState createState() => _EnvSwitcherState();
}

class _EnvSwitcherState extends State<EnvSwitcher> with WidgetsBindingObserver {
  late final EnvExplorer _explorer;

  List<EnvConfig> configs = [];

  late String tmpEnv = widget.currentFilename;

  @override
  void initState() {
    super.initState();
    _explorer = EnvExplorer(baseDirectory: widget.baseDirectory);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    init();
  }

  init() async {
    if (widget.envConfigs != null) {
      setState(() => configs = widget.envConfigs!);
      return;
    }
    await _explorer.initExplorer(context: context);
    final loadedConfigs = await _explorer.loadConfigs();
    setState(() => configs = loadedConfigs);
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.black26,
      child: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodyMedium,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  constraints: BoxConstraints.tightFor(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height / 1.25),
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      color: Theme.of(context).cardColor),
                  child: Column(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('环境切换',
                            style: Theme.of(context).textTheme.titleMedium)),
                    Expanded(
                      child: Container(
                        color: Colors.white70,
                        child: ListView.builder(
                          itemCount: configs.length,
                          itemBuilder: (context, index) => EnvTile(
                            config: configs[index],
                            currentEnv: tmpEnv,
                            onSwitch: (value) => setState(() => tmpEnv = value),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                        child: const Text("确认切换"),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              widget.currentFilename == tmpEnv
                                  ? const Color(0xFFE0E1E2)
                                  : const Color(0xFF42CDDD)),
                        ),
                        onPressed: () => widget.currentFilename != tmpEnv
                            ? widget.onChangeEnv(tmpEnv)
                            : null),
                    const SizedBox(height: 20)
                  ])))));
}
