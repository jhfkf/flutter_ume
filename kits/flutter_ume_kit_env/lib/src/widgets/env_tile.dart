import 'package:flutter/material.dart';
import 'package:flutter_ume_kit_env/src/models/env_config.dart';

class EnvTile extends StatelessWidget {
  final EnvConfig config;

  final String currentEnv;

  final Function(String envName)? onSwitch;

  const EnvTile(
      {Key? key, required this.config, required this.currentEnv, this.onSwitch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final envName = config.entries['CURRENT_ENV'] ?? config.filename;
    return ExpansionTile(
      key: PageStorageKey(config.filename),
      textColor: theme.colorScheme.primary,
      iconColor: theme.colorScheme.primary,
      tilePadding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      visualDensity: const VisualDensity(vertical: -2),
      title: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSwitch?.call(envName),
        child: Row(
          children: [
            Radio<String>(
              value: envName,
              groupValue: currentEnv,
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) => onSwitch?.call(envName),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                envName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      children: _buildList(),
    );
  }

  List<Widget> _buildList() {
    List<Widget> lists = [];
    config.entries.forEach((key, value) {
      lists.add(
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                key,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.0,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      );
    });

    return lists;
  }
}
