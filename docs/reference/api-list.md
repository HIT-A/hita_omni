# 接口清单

本文件记录应用当前依赖的外部接口和内部扩展边界。修改网络接口、认证流程、课表字段映射或插件契约时，必须同步核对本文件。

## 1. 范围

| 能力 | 来源 | 状态 |
| --- | --- | --- |
| 深圳校区登录 | `https://mjw.hitsz.edu.cn/incoSpringBoot` | 已接入 |
| 学期列表 | 深圳校区新版教务 API | 已接入 |
| 周课表 | 深圳校区新版教务 API | 已接入 |
| 本部校区教务 | WebVPN + 旧教务 | 未接入 |
| 威海校区教务 | WebVPN + 旧教务 | 未接入 |

实现位置：

- 认证：`packages/provider_hit/lib/src/shenzhen_auth_api.dart`
- 课表：`packages/provider_hit/lib/src/shenzhen_timetable_api.dart`
- Provider 契约与模型：`packages/academic_api/`
- 静态 provider 注册：`lib/app/provider_catalog.dart`
- 认证路由：`lib/features/account/data/auth_repository.dart`
- 课表路由：`lib/features/timetable/data/timetable_repository.dart`
- 网络与 Cookie：`packages/academic_api/lib/src/network/` + 平台适配 `lib/core/network/`
- 参考实现：父目录 `HITA_Android` 的 `EASWebSource.kt`、`ShenzhenTimetableWebSource.kt`、`WebViewLoginActivity.kt`

## 2. 深圳校区认证

### 2.1 基础信息

| 项 | 值 |
| --- | --- |
| Base URL | `https://mjw.hitsz.edu.cn/incoSpringBoot` |
| 路径拼接 | 请求路径必须以 `/incoSpringBoot` 为前缀；不能用 `Uri.resolve('/path')` 直接丢掉 base path |
| Basic Auth | `Basic aW5jb246MTIzNDU=` |
| 登录请求头 `rolecode` | `01` 或 `06`，按步骤传入 |
| 登录成功后请求头 | `authorization: bearer <access_token>` |
| Cookie | 登录流程产生的 Cookie 保存在会话中，后续请求回放 |
| 超时 | 20 秒 |
| 浏览器 | 服务端 CORS 不覆盖 `authorization`/`rolecode` 等自定义头，且 `Access-Control-Allow-Origin: *` 不能与凭据同时使用；Web 登录不可用，需代理或原生 WebView |

除 Basic Auth 外，登录步骤还携带：

```text
authorization: Basic aW5jb246MTIzNDU=
rolecode: 01 | 06
_lang: cn
Connection: keep-alive
User-Agent: <移动端教务 UA>
```

### 2.2 登录步骤

| 步骤 | 方法 | 路径 | 请求体 | 说明 |
| --- | --- | --- | --- | --- |
| 1 | POST | `/component/queryApplicationSetting/rsa` | 空表单 | `rolecode=01`，建立会话 |
| 2 | POST | `/c_raskey` | 空表单 | `rolecode=06`，返回 RSA 模数/指数 |
| 3 | POST | `/authentication/ldap` | `username`, `password` | 先明文，`rolecode` 依次 `06`、`01` |
| 4 | POST | `/authentication/ldap` | `username`, RSA 密文 | 明文失败后，对每个 RSA key 重试 |

RSA 处理：

- `/c_raskey` 当前把 **X.509 SubjectPublicKeyInfo** 放在 `CLIENT_RSA_EXPONENT`，而 `CLIENT_RSA_MODULUS` 的值是 `10001`（指数），字段名与实际含义相反。必须优先把 `CLIENT_RSA_EXPONENT` 按 Base64 DER 解析，不能只按原始模数/指数配对。
- 同时兼容字段语义正确时的原始十六进制/十进制模数与指数。
- 使用 RSA PKCS#1 v1.5（`RSA/ECB/PKCS1Padding` 等价实现）加密密码，Base64 后作为 `password` 提交。
- 最多尝试 6 个去重后的 key，`rolecode` 为 `06`、`01`。

成功响应中必须存在 `access_token`。兼容根级和 `data.access_token`。

### 2.3 登录响应映射

| 本地字段 | 响应字段 | 说明 |
| --- | --- | --- |
| `accessToken` | `access_token` 或 `data.access_token` | 必需 |
| `refreshToken` | `refresh_token` 或 `data.refresh_token` | 可选 |
| `studentType` | `data.pylx` | `1` 本科，其余研究生；缺失按本科 |
| `studentId` | `info.yhdm` / `data.yhdm` / `data.xh` / `info.xh` | 依次取第一个非空 |
| `name` | `data.yhxm` / `info.xm` / `data.xm` | 依次取第一个非空 |
| `school` | `data.bmmc` / `data.yxmc` | 依次取第一个非空 |
| `cookies` | 全部响应 Cookie | 保存在会话中 |

会话字段与持久化见 `AccountSession`。密码不进入会话，也不落盘。

## 3. 学期列表

| 项 | 值 |
| --- | --- |
| 方法 | POST（form） |
| 路径 | `/app/commapp/queryxnxqlist` |
| 认证 | `authorization: bearer <access_token>`，`rolecode=06` |
| 请求体 | 空 |

响应 `content` 为数组：

| 响应字段 | 本地字段 | 说明 |
| --- | --- | --- |
| `XN` | `Term.yearCode` | 学年代码，如 `2024-2025` |
| `XQ` | `Term.termCode` | `1` 秋、`2` 春、`3` 夏 |
| `XNXQMC` | `Term.name` | 优先作为显示名；为空时拼接学年与学期名 |
| `SFDQXQ` | `Term.isCurrent` | `1` 表示当前学期 |

若列表为空，抛出 `ApiException('未获取到学期列表')`。

## 4. 周课表

| 项 | 值 |
| --- | --- |
| 方法 | POST（JSON） |
| 路径 | `/app/Kbcx/query` |
| 认证 | `authorization: bearer <access_token>`，`rolecode=06` |
| 请求体 | `{"xn":"<yearCode>","xq":"<termCode>","zc":"<week>","type":"json"}` |
| 周次范围 | 1–25，并发 6 路 |

响应根级 `code` 必须为 `200`。`content` 数组中包含：

- `rqList[]`：本周日期，取 `RQ`（`yyyy-MM-dd`）。第 1 周第一条用于推导教学周起始日。
- `kcxxList[]`：课程行。

### 4.1 课程字段映射

| 响应字段 | 本地字段 | 说明 |
| --- | --- | --- |
| `XQJ` | `Course.weekday` | 1=周一 … 7=周日；越界丢弃 |
| `KSJC` | `Course.startPeriod` | 1-based 节次 |
| `JSJC` | `Course.endPeriod` | 小于 `KSJC` 时退化为 `KSJC` |
| `KCDM` | `Course.code` | 优先匹配 `[A-Za-z]{4}\d{4}`，否则保留原值 |
| `KCMC` | `Course.name` | 优先；为空时取 `KBXX` 第一行 |
| `JSXM` / `SKJS` / `RKJS` / `JS` / `JSMC*` | `Course.teacher` | 依次取第一个非空 |
| `KBXX` | `Course.classroom` / 课程备注 | 解析方括号中的教室与附加提示 |
| 周次 | `Course.weeks` | 当前请求周次写入；跨周合并时取并集 |

`KBXX` 解析规则：

- 课程名回退：第一行去掉所有 `[...]`。
- 教室：方括号内容含“楼/馆/场/室/教室/实验室/中心/基地”，或符合 `A101`、`T101` 等模式。
- 非教室、非周次/节次方括号作为课程提示，追加为 `课程名 [提示]`。
- 教师：优先结构化字段；否则取第一行之后、不含方括号的文本。

### 4.1.1 教师补齐

周课表若没有教师字段，再调用已选课程接口补齐：

| 项 | 值 |
| --- | --- |
| 方法 | POST（JSON） |
| 路径 | `/app/Xsxk/queryYxkc?_lang=zh_CN` |
| 认证 | `authorization: bearer <access_token>`，`rolecode=06`（失败再试 `01`） |
| 请求体 | `RoleCode`、`p_pylx`（本科 `1`，研究生 `2`）、`p_xn`、`p_xq`、`p_xnxq`、`p_gjz`、`p_kc_gjz`、`p_xkfsdm` |
| 候选 | `p_pylx` 补零形式、`p_xnxq` 的 `YYYY-YYYYT` / `YYYY-YYYY-T` / 补零形式、`p_xkfsdm=yixuan` / 空 |
| 教师字段 | `DGJSMC` / `SKJS` / `SKJSXM` / `SKJSMC` / `SKJSXX` / `JSXM` / `JSMC` / `RKJS` / `JS`（含大小写变体） |
| 映射 | 优先课程代码（`KCDM` 归一化），其次课程名称（去空白） |

该请求是可选的：失败、超时或没有已选课程数据时，继续使用周课表结果。请求总时长上限约 12 秒。

### 4.2 合并规则

- 同一 `name + code + weekday + startPeriod + endPeriod + teacher + classroom` 的行合并周次。
- 周次集合完全相同、课程信息相同、节次相邻的块合并为一个连续块。
- 周次集合不同的相邻块不合并，避免把不同周的课程错误连成同一块。

### 4.3 教学周与节次

- 起始日：第 1 周 `rqList` 第一条，归一化到周一。
- 若无法取得日期，使用当前周的周一，并标记 `calendarVerified=false`；UI 显示“教学周为估算值”。
- 总周数：`max(20, 课程最大周次)`，限制在 1–25。
- 节次结构：provider 在自己的 `defaultSlots` / 快照中提供作息；HIT 使用 `provider_hit` 内的 `HitCampusSchedule`。UI 不再按校区选择作息。

三校区默认作息来源：`HITA_Android/app/src/main/java/cn/limpu/hita/data/source/web/eas/CampusDefaultSchedule.kt`。

### 4.4 学期显示范围

`AcademicProvider.fetchTerms()` 返回完整学期列表；App 统一用 `TermFilter.forTimetableAndAssessment` 计算可见学期。课表与后续成绩/考试模块共用这一规则。

| 条件 | 行为 |
| --- | --- |
| `profile['grade']` 有入学年 | 保留 `学年起始年 >= 入学年` 的全部学期，包括教务已开放的未来学期 |
| 无 grade，但学号前四位是合法入学年 | 用学号推导入学年，再按上一行处理 |
| 无入学信息 | 只保留最近 4 个日历年（`currentYear - 3` 起） |
| 过滤结果为空 | 回退完整列表 |
| 排序 | 学年起始年降序，再按学期代码降序；按 `Term.id` 去重 |

该规则刻意不设置“当前学期”上限，避免当前学期仍为夏季时，教务已开放的下学期被误删。


## 5. 错误与登录失效

以下情况视为会话失效，抛出 `AuthExpiredException`，并由 `TimetableController` 清理会话：

- HTTP 状态 `401` / `403`。
- JSON `code` 为 `401` / `403`。
- JSON `msg` 包含 `token`、`登录` 或 `认证`。
- 响应是 HTML，且包含“登录”或“统一身份认证”。

网络错误统一包装为 `HttpTransportException`，UI 展示中文提示。

## 6. 本地持久化键

| Key | 内容 | 清除时机 |
| --- | --- | --- |
| `account.session.v2` | `providerId`、账号、凭据、Cookie、profile、登录时间；读取时兼容 v1 campus/token 形状 | 退出登录 / 会话失效 |
| `timetable.cache.v3` | `activeProviderId` + 按 provider 隔离的学期、多个本地课表及 `activeTimetableId`；读取时兼容 v2 单快照和 `timetable.cache.v1` | 不随退出登录/会话失效清除；仅应用数据清理 |
| `dashboard.layout.v1` | 今日面板 ID 顺序 | 用户手动恢复默认 |
| `app.themeMode` | `system` / `light` / `dark` | 不自动清除 |

存储实现：

- 原生：`<应用支持目录>/hita_omni_store.json`
- Web：`localStorage`
- 测试/降级：内存存储

安全边界：密码不进入上述任何键；`account.session.v2` 中的 credentials/Cookie 依赖应用沙箱与操作系统账户权限隔离，当前未做额外加密。接入平台安全存储后再用于高安全要求场景。

## 7. Provider 状态

认证与课表统一由 `AcademicProvider` 提供，按稳定 `providerId` 路由：

| Provider ID | 状态 | 说明 |
| --- | --- | --- |
| `hit.shenzhen` | 可用 | 新版教务 API，账号密码登录 |
| `hit.harbin` | 未接入 | WebVPN 占位，`isAvailable=false`，不发起请求 |
| `hit.weihai` | 未接入 | WebVPN 占位，`isAvailable=false`，不发起请求 |

实现位置：`packages/provider_hit/lib/src/providers.dart`。占位 provider 的 `login` / `fetchTerms` / `fetchSnapshot` 会抛出 `AuthException` / `ApiException`，错误文本来自 provider metadata 的 `note`，不会返回假数据。

接入本部/威海时：

1. 在 `provider_hit` 中实现 WebVPN 登录/会话 Cookie；
2. 将对应 provider 的 `isAvailable` 改为 `true`；
3. 补齐旧教务响应解析；
4. 更新 provider catalog 测试。

### 7.1 本部参考

参考 `HITA_Android`：

- WebVPN 入口：`http://i-hit-edu-cn.ivpn.hit.edu.cn:1080/portal/home/`
- 教务入口：`http://jwts-hit-edu-cn.ivpn.hit.edu.cn:1080`
- 登录：WebView 打开统一身份认证，捕获 `JSESSIONID`、`HIT` 等 Cookie。
- 同步：旧教务 HTML / JSON 接口，需移植 `BenbuEASWebSource` 与相关解析器。

### 7.2 威海参考

参考 `HITA_Android`：

- WebVPN：`https://webvpn.hitwh.edu.cn`
- 教务入口由 WebVPN 加密路径前缀拼接。
- 登录：WebView + 统一身份认证 + WebVPN Cookie API。
- 同步：旧教务页面解析；需移植 `WeihaiEASWebSource`。

两校区不应复用深圳校区的账号密码直连逻辑；WebVPN 会话 Cookie 是认证前置条件。

## 8. 内部扩展接口

### 8.1 `OmniPlugin`

```dart
abstract class OmniPlugin {
  String get id;
  String get name;
  String get description;
  String get version;
  List<DashboardPanelDefinition> get panels;
  List<AppPageDefinition> get pages;
}
```

- `id` 必须全局唯一；`PluginRegistry` 对插件、面板、页面 ID 做重复检查。
- 插件在 `lib/plugins/builtin_plugins.dart` 注册。
- 插件是编译期依赖；运行时不加载任意 Dart 代码。

### 8.2 `DashboardPanelDefinition`

| 字段 | 说明 |
| --- | --- |
| `id` | 全局唯一，持久化布局使用 |
| `title` / `description` / `icon` | 添加面板与编辑列表展示 |
| `span` | 桌面端优先列数，布局时按当前列数截断 |
| `defaultEnabled` | 首次安装是否进入默认布局 |
| `removable` | 是否允许从今日移除 |
| `builder` | 返回一个 `Widget`；通过 `provider` 读取控制器 |

### 8.3 `AppPageDefinition`

贡献一个导航页；`order` 决定在核心三页之后的排序。当前没有内置插件页面，但 Shell 已按注册表渲染。

### 8.4 Academic Provider

外部学校实现 `academic_api` 中的 `AcademicProvider`：

```dart
abstract interface class AcademicProvider {
  String get id;
  AcademicProviderInfo get info;
  Future<AuthResult> login(AuthRequest request);
  Future<List<Term>> fetchTerms(AccountSession session);
  Future<TimetableSnapshot> fetchSnapshot({
    required AccountSession session,
    required Term term,
  });
}
```

- `AcademicProviderCatalog` 按 `providerId` 路由，并拒绝重复 ID。
- `AccountSession.providerId`、课表缓存、登录页和账号页均以 provider 为单位。
- HIT 静态 provider 位于 `packages/provider_hit`；固定发版时新增学校只需新增包并在 `lib/app/provider_catalog.dart` 注册。
- 运行时 Wasm 插件尚未实现；设计见 [`wasm-plugin-system.md`](wasm-plugin-system.md)。Wasm provider 将来通过 `WasmProviderAdapter` 实现同一个 `AcademicProvider` 契约；Wasm 面板通过 `WasmPanelHost` 接入今日。iOS App Store 构建必须关闭动态加载，iOS 侧载构建可选启用解释器。
- 不要用 `Campus` 枚举作为路由键，也不要在 core/UI 中增加校区 switch。

## 9. 改动检查项

修改外部接口时：

- [ ] 更新本文件的路径、字段、认证和错误处理。
- [ ] 更新 `packages/provider_hit` 中的 `ShenzhenAuthApi` / `ShenzhenTimetableApi` 请求与解析。
- [ ] 接入新校区/学校时新增 provider 包，并在 `lib/app/provider_catalog.dart` 注册；不要在 core 中增加校区 switch。
- [ ] 检查 provider 作息、教学周起始日和课程周次合并是否仍正确。
- [ ] 补充或更新 `test/shenzhen_parser_test.dart`、`test/timetable_snapshot_test.dart`、`test/provider_catalog_test.dart`、`test/account_session_test.dart`、`test/term_filter_test.dart`。
- [ ] 确认退出登录只清除会话，课表缓存保留；同步成功才覆盖课表。
- [ ] 确认错误信息不会泄露密码、credential 或 Cookie。
- [ ] 如修改插件边界，同步更新 [`wasm-plugin-system.md`](wasm-plugin-system.md)。
