# flutter_ume_kit_env

环境切换组件

## 使用方法

```dart
EnvSwitcher(
    baseDirectory: 'env/', // 路径 
    currentFilename: SPApiConfig.currentEnv, // 当前环境
    onChangeEnv: (envName) async { // 切换环境回调
      if (UserState.userAccessToken.isNotEmpty) {
        await UserState().logout();
      }
      await SpUtils.preferences?.setString(StorageKey.currentEnv, envName);
      exit(0);
});
```