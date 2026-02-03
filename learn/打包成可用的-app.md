# PureMark：打包成可用的 App

## 一、当前支持的平台

项目已配置 **macOS**（`puremark/macos/`）。  
若需 Windows，需先添加平台（见下文「添加 Windows 支持」）。

---

## 二、macOS 打包（推荐）

在项目根目录下进入 `puremark` 目录后执行：

```bash
cd puremark
flutter build macos
```

**输出位置**（Release 构建）：

- **可执行应用（.app）**：  
  `puremark/build/macos/Build/Products/Release/PureMark.app`
- 双击 `PureMark.app` 即可运行；可拖到「应用程序」或任意位置使用。

**可选：打包成可分发的 .app**

- 上述 `.app` 已是完整应用，可直接复制给他人（同架构 macOS）。
- 若需「公证 + 分发」，需 Apple 开发者账号，在 Xcode 中打开 `puremark/macos/Runner.xcworkspace`，配置签名与公证后 Archive 并导出。

---

## 三、构建类型说明

| 命令 | 说明 |
|------|------|
| `flutter build macos` | 默认 **Release**，体积小、性能好，适合日常使用和分发 |
| `flutter build macos --debug` | Debug 构建，便于调试，体积大 |
| `flutter build macos --profile` | Profile 构建，用于性能分析 |

日常打包用 **`flutter build macos`** 即可。

---

## 四、添加 Windows 支持（可选）

`pubspec.yaml` 描述里写了「macOS and Windows」，但当前仓库未包含 `windows/` 目录时，需要先创建：

```bash
cd puremark
flutter create . --platforms=windows
```

然后再构建：

```bash
flutter build windows
```

**输出位置**：  
`puremark/build/windows/x64/runner/Release/` 下会生成可执行文件及依赖的 dll；整个 `Release` 文件夹一起拷贝即可在 Windows 上运行。

---

## 五、常见问题

1. **首次构建较慢**  
   会下载/编译依赖，属正常现象。

2. **提示「No valid SDK」或找不到 Flutter**  
   确保已安装 Flutter 并执行过 `flutter doctor`，且当前终端能执行 `flutter --version`。

3. **macOS 提示「无法打开，因为无法验证开发者」**  
   在「系统设置 → 隐私与安全性」中允许打开该 App，或对 `.app` 右键 → 打开。

4. **需要其他平台（iOS / Android / Linux）**  
   执行 `flutter create . --platforms=ios`（或 `android`、`linux`）再 `flutter build <平台>`；部分插件（如 window_manager）在不同平台可能有差异，需单独验证。

---

## 六、快速命令汇总

```bash
# 进入应用目录
cd puremark

# 打包 macOS 应用（最常用）
flutter build macos

# 打包完成后，应用在这里：
# build/macos/Build/Products/Release/PureMark.app
```

将 `PureMark.app` 拖到「应用程序」或直接双击即可使用。
