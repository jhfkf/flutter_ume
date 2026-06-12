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
    final envName = config.entries['CURRENT_ENV'] ?? config.filename;
    return ExpansionTile(
      key: PageStorageKey(config.filename),
      textColor: Colors.indigo,
      iconColor: Colors.indigo,
      tilePadding: const EdgeInsets.only(right: 20),
      title: RadioListTile<String>(
        value: envName,
        groupValue: currentEnv,
        onChanged: (value) {
          onSwitch?.call(envName);
        },
        title: Text(envName),
        // selected: ,
      ),
      children: _buildList(),
    );
  }

  List<Widget> _buildList() {
    List<Widget> lists = [];
    config.entries.forEach((key, value) {
      lists.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                key,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return lists;
  }
}
