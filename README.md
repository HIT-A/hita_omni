# HITA Omni

面向哈尔滨工业大学学生的跨平台校园助手。Flutter 编写，核心保持极简，通过编译期插件扩展面板、页面与教务 provider。

当前处于初始骨架阶段，已打通「今日」「时间表」「我的」三条核心链路，并接入深圳校区新版教务接口。

## 设计原则

- **核心小，扩展多**：内置能力只保留课表、今日面板和账户；其他能力以插件形式注册。
- **面板化今日**：像仪表盘一样增删、排序今日面板，而不是把信息堆进一个固定首页。
- **显式数据流**：UI → Controller → Repository → API/Cache，网络与界面解耦。
- **跨平台优先**：同一套 Flutter UI 面向 Android、iOS、Windows、macOS、Linux 和 Web；平台差异尽量收敛在存储与 HTTP 适配层。
- **本地优先**：课表缓存可离线展示；密码不落盘，会话保存在应用私有目录。

## 已实现

### 今日

- 可添加、移除、拖拽排序的今日面板。
- 内置面板：下一节课、今日课程、本周进度、账户、快捷操作。
- 下一节课支持进行中/即将开始/跨日展示。
- 今日课程时间线、当前课程高亮、课程详情。
- 教学周进度与学期状态。
- 下拉刷新同步课表。

### 时间表

- 周课表网格，支持 7 天、12 节次和横向滚动。
- 学期切换、周次切换、回到本周；学期按入学年过滤，保留未来已开放学期。
- 当前时间线、今日列高亮。
- 课程详情：时间、周次、地点、教师、课程代码。
- 教务同步与本地缓存；支持多份本地课表切换、重命名和删除。
- 课表管理提供添加入口：可从教务导入指定学期课表；ICS 导入和空白课表为后续能力。

### 我的

- 深圳校区教务登录；密码仅用于本次登录，不保存。
- 会话本地持久化；退出登录仅清除会话，本地课表保留。
- 账户信息、同步状态、重新登录。
- 浅色/深色/跟随系统外观。
- 基于 Flutter `gen_l10n` / ARB 的本地化；当前内置简体中文。
- 已注册插件与面板列表。

## 校区与教务 Provider

| Provider ID | 认证方式 | 当前状态 |
| --- | --- | --- |
| `hit.shenzhen` | 新版教务 API，账号密码直连 | 已实现 |
| `hit.harbin` | WebVPN + 统一身份认证，需网页会话 Cookie | 结构已预留，未实现 |
| `hit.weihai` | WebVPN + 统一身份认证，需网页会话 Cookie | 结构已预留，未实现 |

教务能力通过编译期 provider 包接入：

- 契约与通用模型：`packages/academic_api/`
- HIT 实现：`packages/provider_hit/`
- 静态注册：`lib/app/provider_catalog.dart`
- 路由：`AuthRepository` / `TimetableRepository` 按 `providerId` 选择 provider
- 校本部/威海 provider 的 `isAvailable` 为 `false`，调用会在网络请求前明确失败，不会返回假数据

Web 端受浏览器跨域策略限制：深圳教务接口要求自定义 `authorization`/`rolecode` 请求头并携带凭据，而服务端 CORS 不允许该组合。当前 Web 登录入口会明确禁用并提示改用移动端/桌面端，避免误报“账号或密码错误”。

运行时 Wasm 插件目前只是设计稿，尚未实现。插件系统同时覆盖教务 provider 和今日面板（番茄钟、天气、作业等）；iOS 分为 App Store 构建（关闭动态加载）和侧载构建（实验性 Wasm 解释器）。插件格式、ABI、宿主能力、iOS 构建差异和安全边界见 [docs/reference/wasm-plugin-system.md](docs/reference/wasm-plugin-system.md)。

## 技术栈

- Flutter 3.47.9 / Dart 3.13.7
- `provider`：控制器注入与局部监听
- `http`：Web 端 HTTP 传输（原生端使用 `dart:io`）
- `path_provider`：应用私有存储目录
- `window_manager`：Linux X11 使用 Flutter 自绘标题栏；Wayland 保留原生标题栏（规避 nativeapi 0.5.x 的 CSD 输入区域问题）
- `flutter_localizations`：Material/Cupertino 本地化
- `intl` + `gen_l10n`：ARB 编译期本地化

没有引入代码生成、数据库或重量级状态管理。课表与设置数据量小，缓存以 JSON 文档保存在应用私有目录；数据模型增长后可替换 `KeyValueStore` 为 SQLite 实现。

## 目录结构

```text
lib/
├── main.dart                    # 入口
├── app/
│   ├── bootstrap.dart           # 组合根：存储、网络、控制器、provider catalog
│   ├── provider_catalog.dart    # 静态 provider 注册入口
│   ├── app.dart                 # MaterialApp / 本地化 / Web 字体装配
│   ├── app_shell.dart           # 移动端底部导航 + 桌面侧栏
│   └── web_fonts.dart           # Web 自托管字体加载
├── l10n/                        # ARB 源文件与 gen_l10n 生成文件
├── core/
│   ├── i18n/                    # 生成本地化访问与格式化 helper
│   ├── navigation/              # 页面导航状态与核心页面 ID
│   ├── network/                 # 平台 HTTP 适配；通用类型来自 academic_api
│   ├── plugin/                  # UI 插件 / 面板 / 页面契约与注册表
│   ├── storage/                 # 文件 / localStorage / 内存存储
│   ├── theme/                   # 主题 token、ThemeData、外观状态
│   └── utils/                   # 日期、时钟与周次范围工具
├── features/
│   ├── account/                 # 会话、登录、账户页
│   ├── dashboard/               # 今日面板系统与内置面板
│   └── timetable/               # 课表缓存、同步控制器、周网格
├── plugins/builtin_plugins.dart # 内置 UI 插件注册入口
└── shared/widgets/              # SurfaceCard、EmptyState、状态胶囊等

packages/
├── academic_api/                # Provider SDK：契约、模型、HTTP 原语
└── provider_hit/                # 静态 HIT 三校区实现
```

## 架构说明

### 依赖规则

```text
app ─────► features ─────► core
 │            │              ▲
 ├────► packages/provider_hit ───► packages/academic_api
 └────────────┴────► shared ─┘
```

- `app` 是组合根，可以依赖 `features`、`core`、`shared` 和 provider 包。
- `features` 可以依赖 `core`、`shared`、`academic_api`，不依赖 `app`。
- `provider_hit` 只依赖 `academic_api`；外部 provider 包遵循同一边界。
- `core`、`shared` 不依赖 `features`、provider 包或 `app`。
- feature 之间通过 application 控制器或公开领域模型协作，避免直接引用彼此的 data/presentation 实现。

### 数据流

```text
LoginPage / AccountPage
        │ signIn(providerId)
        ▼
AccountController ──保存会话──► SessionStore(KeyValueStore)
        │ 会话变化
        ▼
TimetableController ──► TimetableRepository ──► AcademicProvider
        │                       │
        │                       └──► TimetableCache(provider-scoped)
        ▼
DashboardPage / TimetablePage / Panels
```

- `AccountController` 与 `TimetableController` 是应用级 `ChangeNotifier`，在 `bootstrap.dart` 中创建并通过 `provider` 注入。
- 登录成功后 `TimetableController` 自动同步；退出登录只清除会话，本地课表继续可用。课表只能由教务同步成功覆盖。
- 今日课程面板、下一节课面板和时间表页只展示本地数据，不显示登录态、不跳转登录；登录与同步入口在“我的”。
- 网络层用 `HttpTransport` 隔离平台差异：原生端使用 `dart:io` 以读取 `Set-Cookie`，Web 端使用浏览器 HTTP。
- 教务解析逻辑集中在 `packages/provider_hit`，状态与会话由 `academic_api` 定义；UI 只消费 `AccountSession` 和 canonical `TimetableSnapshot`。
- 学校/校区通过 `AcademicProviderCatalog` 按 `providerId` 路由；HIT 实现编译期静态注册，未实现 provider 只保留占位。

### UI 插件与教务 Provider

两类扩展点互相独立：

- **UI 插件**：`OmniPlugin` 贡献今日面板和导航页面，注册在 `lib/plugins/builtin_plugins.dart`。
- **教务 Provider**：`AcademicProvider` 提供登录、学期和课表，注册在 `lib/app/provider_catalog.dart`。

`OmniPlugin` 不负责教务 provider，避免把 UI 生命周期和教务网络逻辑绑在一起。教务 provider 的契约、模型和 HTTP 原语位于 `packages/academic_api`。

UI 插件注册入口：

```dart
PluginRegistry createPluginRegistry() {
  return PluginRegistry([
    const CoreDashboardPlugin(),
    const MyPlugin(), // 新插件
  ]);
}
```

一个最小插件：

```dart
class MyPlugin extends OmniPlugin {
  const MyPlugin();

  @override
  String get id => 'example.plugin';
  @override
  String get name => '示例插件';
  @override
  String get description => '贡献一个今日面板。';

  @override
  List<DashboardPanelDefinition> get panels => [
    DashboardPanelDefinition(
      id: 'example.hello',
      title: '示例',
      description: '一个可以添加到今日的面板。',
      icon: Icons.extension_outlined,
      defaultEnabled: false,
      builder: (_) => const MyPanel(),
    ),
  ];
}
```

面板布局按插件注册顺序取默认值；用户增删和排序会持久化到 `dashboard.layout.v1`。新增面板默认出现在「编辑今日面板 → 添加面板」中，不会强行挤进已有布局。

当前所有 provider 和 UI 插件都是编译期依赖，新增学校需要发版。未来的运行时插件方案统一使用签名 Wasm 包，不使用下载 Dart/原生动态库；详细设计见 [docs/reference/wasm-plugin-system.md](docs/reference/wasm-plugin-system.md)。


## AI 辅助开发

项目已安装 Flutter 官方 agent skills，并在本地配置 Dart MCP server：

- Skills：`.agents/skills/`，版本锁定在 `skills-lock.json`
- OMP MCP：`.omp/mcp.json`
- 通用 MCP：`.agents/mcp_config.json`
- Codex MCP：`.codex/config.toml`
- MCP 命令：`dart mcp-server`

安装/更新 skills 使用：

```bash
npx skills add flutter/agent-plugins --skill '*' --agent universal --yes
npx skills add dart-lang/skills --skill '*' --agent universal --yes
```

这些配置只影响 AI 辅助开发，不是应用运行时依赖；应用本身仍不需要 Node/Bun。更新 MCP 配置后需重启对应的 AI 客户端。

## 本地化

应用使用 Flutter 官方 `gen_l10n` + ARB 流程，不再支持运行时导入语言包。

- ARB 源文件：`lib/l10n/app_zh.arb`
- 配置：`l10n.yaml`
- 生成文件：`lib/l10n/app_localizations*.dart`
- 访问：`context.l10n`（`AppLocalizations`）与 `core/i18n/` 中的日期/相对时间 helper
- 当前仅内置 `zh`；新增语言只需添加 `app_<locale>.arb` 并运行 `flutter gen-l10n`
- 应用名称固定为 **HITA Omni**，不参与本地化替换；桌面窗口标题不再由应用手动设置
- 教务课程名、学期名等动态数据不翻译；网络错误原文可能保持源语言
- 详细流程见 [docs/reference/localization.md](docs/reference/localization.md)

## 安全说明

- 密码只用于登录请求，不写入会话、课表缓存或本地存储。
- 会话包含 provider credentials 与 Cookie，保存在应用私有目录的 JSON 文档中，并依赖操作系统账户权限隔离；当前尚未额外加密。共享设备或高安全要求场景下应先接入平台安全存储，再上线使用。
- 退出登录或会话失效只删除会话，不删除本地课表；重新登录后才能从教务同步更新。
- Web 端会话由浏览器 Cookie 管理；在服务端未开放跨域访问时，登录不可用。

## 开发

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

### Web 端

Web 端不能依赖 `www.gstatic.com` / `fonts.gstatic.com`：在受限网络中，CanvasKit 和字体回退下载失败会让页面停在空白画布。

项目已做两层自托管：

- `web/flutter_bootstrap.js` 强制使用同源的 `canvaskit/`；
- `assets/fonts/` 内置 Roboto 和 Droid Sans Fallback，启动时通过 `FontLoader` 注册，并作为 Web 主题字体与回退字体；
- `fontFallbackBaseUrl` 指向本地的 Roboto 回退文件，不再请求 Google Fonts。

因此 Web 构建必须带本地引擎资源：

```bash
./tool/web_build.sh
# 等价于：flutter build web --no-web-resources-cdn

./tool/web_run.sh
# 等价于：flutter run -d chrome --no-web-resources-cdn
```

部署 `build/web/` 时，必须同时保留 `canvaskit/` 与 `assets/assets/fonts/`。修改 `web/flutter_bootstrap.js` 后需要重新构建。

Web 字体许可：Roboto（Apache-2.0）与 Droid Sans Fallback（Apache-2.0），说明文件在 `assets/fonts/` 下。

Web 端的教务登录仍受服务端 CORS 限制，登录页会禁用提交并提示使用移动端/桌面端；本地缓存课表仍可展示。

平台说明：

- Android 已声明 `INTERNET` 权限。
- macOS 已启用 `com.apple.security.network.client`，否则沙盒下无法访问教务接口。
- Linux 依赖 `path_provider` 提供的用户数据目录。
- Web 端存储使用 `localStorage`；教务 API 的跨域能力取决于服务端 CORS。

发布前还需要配置签名、应用图标和商店元数据；Android `applicationId`、iOS/macOS bundle ID 与 Linux application ID 已统一为 `me.ilovo.hita`。

## 文档

- [接口清单](docs/reference/api-list.md)：外部接口、请求字段、数据映射与改动检查项。
- [本地化](docs/reference/localization.md)：ARB 结构、gen_l10n 流程与新增语言步骤。
- `PROJECT_MEMORY.md`：本地项目记忆，默认不进入版本库；按仓库约定仅在用户要求提交或维护记忆时更新。
- `docs/logs/`：开发者日志，按仓库约定在提交时新增。
