import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';
import 'package:flutter_ume_kit_env/src/icon.dart' as icon;
import 'package:flutter_ume_kit_env/src/models/env_config.dart';
import 'package:flutter_ume_kit_env/src/widgets/env_tile.dart';

// ignore: must_be_immutable
class EnvSwitcher extends StatefulWidget implements Pluggable {
  EnvSwitcher({
    Key? key,
    required this.envConfigs,
    required this.onChangeEnv,
    this.currentEnv,
  }) : super(key: key);

  /// 环境配置列表
  final List<EnvConfig> envConfigs;

  /// 切换环境回调，返回 true 表示成功，false 表示失败
  final Future<bool> Function(String envName) onChangeEnv;

  /// 当前已确认切换的环境名（选填，不传则取第一个配置的环境名）。
  ///
  /// 存储在 widget 实例上而非 State 中：UME 关闭面板时会将 widget 移出树，
  /// State 被 dispose；重新打开时创建新 State 并重新执行 initState。
  /// 而 Pluggable（即本 widget 实例）的生命周期与 PluginManager 注册一致，
  /// 因此将 currentEnv 放在此处确保环境选择在面板关闭重开后仍然保留。
  String? currentEnv;

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

class _EnvSwitcherState extends State<EnvSwitcher> {
  late String tmpEnv;

  @override
  void initState() {
    super.initState();
    // 未传 currentEnv 时取第一个配置作为默认
    widget.currentEnv ??= _defaultEnv;
    tmpEnv = widget.currentEnv!;
  }

  String get _defaultEnv => widget.envConfigs.isNotEmpty
      ? (widget.envConfigs.first.entries['CURRENT_ENV'] ??
          widget.envConfigs.first.filename)
      : '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = widget.currentEnv != tmpEnv;

    return Material(
      color: Colors.black38,
      child: DefaultTextStyle.merge(
        style: theme.textTheme.bodyMedium,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: theme.cardColor,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '环境切换',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '当前: ${widget.currentEnv ?? _defaultEnv}',
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: widget.envConfigs.length,
                          itemBuilder: (context, index) => EnvTile(
                            config: widget.envConfigs[index],
                            currentEnv: tmpEnv,
                            onSwitch: (value) => setState(() => tmpEnv = value),
                          ),
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 0.8,
                            indent: 16,
                            endIndent: 16,
                            color: theme.dividerColor.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          backgroundColor: WidgetStateProperty.all(
                            canSubmit
                                ? const Color(0xFF11B8C9)
                                : const Color(0xFFE0E1E2),
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            canSubmit ? Colors.white : Colors.black54,
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: canSubmit
                            ? () async {
                                final success =
                                    await widget.onChangeEnv(tmpEnv);
                                if (success) {
                                  widget.currentEnv = tmpEnv;
                                  setState(() {});
                                }
                              }
                            : null,
                        child: const Text('确认切换'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
