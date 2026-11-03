# 本地化

应用使用 Flutter 官方 `gen_l10n` + ARB 工作流。运行时语言包导入已移除。

## 文件

| 文件 | 作用 |
| --- | --- |
| `lib/l10n/app_zh.arb` | 中文消息模板 |
| `l10n.yaml` | gen_l10n 配置 |
| `lib/l10n/app_localizations.dart` | 生成的抽象类与 delegate |
| `lib/l10n/app_localizations_zh.dart` | 生成的中文实现 |
| `lib/core/i18n/i18n_context.dart` | `context.l10n` 与日期/校区/主题 helper |

## 使用

```dart
final l10n = context.l10n;
Text(l10n.navToday);
Text(l10n.commonWeek(3));
```

`context.l10n` 来自 `Localizations.of<AppLocalizations>`，随 `MaterialApp` 的 locale 变化自动重建。

## 新增语言

1. 在 `lib/l10n/` 添加 `app_<locale>.arb`，复制 `app_zh.arb` 的全部 key。
2. 翻译消息值；带 `placeholders` 的消息保留 `@key` 元数据。
3. 运行：

```bash
flutter gen-l10n
```

4. `AppLocalizations.supportedLocales` 会自动包含新语言，`MaterialApp` 跟随设备 locale 解析。

当前只提供 `zh`。没有设备语言匹配时，Flutter 会回退到唯一支持的语言。

## 日期、数字与复数

- 日期使用 ARB 中的 `DateTime` placeholder 和 `DateFormat` 格式，例如 `MMMd`、`yMMMMd`、`MMMEd`、`Hm`。
- 计数类文案使用 `int` placeholder；需要复数规则时，在 ARB 中使用 ICU plural，例如：

```json
"durationDays": "{count, plural, =1{1 day} other{{count} days}}",
"@durationDays": {
  "placeholders": {
    "count": { "type": "int" }
  }
}
```

- 日期符号由 `GlobalMaterialLocalizations` 在应用启动时初始化；不要在 `MaterialApp` 之外单独使用生成类格式化日期。

## 品牌

应用名称固定为 `HITA Omni`，来自 `lib/app/app_info.dart`，不放入 ARB，也不允许语言切换覆盖。桌面窗口标题不由应用手动设置。

## 约束

- 不再支持导入 JSON 语言包或运行时删除/切换自定义包。
- 不支持的语言需要新增 ARB 并重新构建。
- ARB 的 `@key` metadata 是翻译上下文和 placeholder 类型的来源，新增消息时应保留。
