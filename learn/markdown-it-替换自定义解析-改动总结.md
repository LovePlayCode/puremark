# PureMark：用 markdown-it 替换自定义 Markdown 解析 — 改动总结

## 一、背景与目标

- **原状**：预览层在 WebView 内嵌了约 200+ 行自定义 JavaScript（`parseMarkdown` + 大量正则），把 Markdown 转成 HTML。难以覆盖 CommonMark/GFM 的完整边界，维护成本高，表格、占位符等曾出过问题。
- **目标**：改用成熟库解析 Markdown，同时**确保 Mermaid 正常展示**，大纲、搜索、链接拦截等现有能力不变。

## 二、方案选型结论

- **Flutter 原生**（如 flutter_markdown_plus / markdown_widget）：需重写整块预览架构、Mermaid 需单独嵌入，改动大，与现有 WebView 强耦合的搜索/大纲/链接不符。
- **WebView + JS 库（markdown-it）**：与现有架构一致，仅替换「谁把 Markdown 转成 HTML」，改动集中、风险可控。

**最终采用**：在现有 WebView 内通过 CDN 引入 **markdown-it**，用其替代自定义 `parseMarkdown()`；Mermaid 不引入插件，沿用「后处理 + mermaid.run()」保证正常展示。

## 三、具体改动（仅动一个文件）

**唯一修改文件**：`puremark/lib/features/viewer/widgets/webview_container.dart`。

### 3.1 引入 markdown-it（CDN）

在 `_getHtmlContent()` 中，在 Mermaid 的 `<script>` 之后、内联 `<script>` 之前增加一行：

```html
<script src="https://cdn.jsdelivr.net/npm/markdown-it@14/dist/markdown-it.min.js"></script>
```

使用固定版本 `@14`，与 Mermaid 一样走 jsDelivr。

### 3.2 删除的内容

- 整块自定义解析逻辑：`parseMarkdown(text)` 函数（含代码块/行内代码占位符、标题、粗斜体、链接、图片、引用、水平线、列表、任务列表、GFM 表格、段落与清理、占位符还原等）。
- 仅被解析器使用的变量与函数：`mermaidCounter`、`codeBlocks`、`inlineCodeBlocks`、`escapeHtml(text)`。

### 3.3 新增与保留

- **新增**：
  - **markdown-it 实例**：`var md = window.markdownit({ html: true, linkify: true, typographer: true });`，使用默认 preset（已含 GFM 表格、删除线等）。
  - **后处理函数 `postProcessContent(contentEl)`**：
    - **标题 id**：遍历 `#content` 内所有 `h1`–`h6`，若无 `id` 则设置 `el.id = generateHeadingId(el.textContent)`，供大纲与 `scrollToHeading` 使用。
    - **Mermaid 块**：查找 `pre > code.language-mermaid`，用其 `textContent` 创建 `<div class="mermaid">...</div>` 替换原 `pre`，再交由已有 `renderMermaidDiagrams()`（即 `mermaid.run()`）渲染。
    - **链接拦截**：对 `#content` 内所有 `a[href]` 添加 `click` 监听，`event.preventDefault()` 并调用 `handleLinkClick(event, url)`，由 Flutter 处理链接。
- **保留**：`generateHeadingId`、`updateMarkdown`、`renderMermaidDiagrams`、`extractOutline`、`scrollToHeading`、`handleLinkClick`、`setTheme`，以及搜索相关（`performSearch`、`clearSearch`、`resetOriginalContent`、`goToMatch`、`notifySearchResults`）和所有 Flutter handler（`onOutlineGenerated`、`onLinkClicked`、`onWebViewReady`、`onSearchResults`）。

### 3.4 `updateMarkdown(content)` 的新流程

1. `contentEl.innerHTML = md.render(content);` — 用 markdown-it 将 Markdown 转为 HTML。
2. `postProcessContent(contentEl);` — 为标题补 id、将 mermaid 代码块换成 `div.mermaid`、为链接绑定点击拦截。
3. `resetOriginalContent();` — 重置搜索用的原始内容缓存。
4. `await renderMermaidDiagrams();` — 渲染 Mermaid 图表。
5. `extractOutline();` — 提取大纲并通知 Flutter。

## 四、数据流（不变）

- Dart 仍只负责：读文件、把 `content` 转义后通过 `evaluateJavascript('updateMarkdown("...")')` 注入。
- 解析与后处理仍在 WebView 内嵌脚本中完成；仅「生成 HTML」的步骤从自定义 `parseMarkdown` 改为 **markdown-it + postProcessContent**。
- 搜索高亮、当前匹配跳转、大纲生成、主题切换、`onWebViewReady` 触发时机均未改。

## 五、注意事项

- **网络**：与 Mermaid 一致，首次加载依赖 CDN；若未来需要离线，可将 markdown-it.min.js 打入 assets 本地加载。
- **XSS**：若开启 `html: true`，需确认内容来源可信或再做过滤。
- **文档中的占位符**：如 `%%INLINECODE10%%` 等字面量会由 markdown-it 原样保留在 HTML 中，符合预期。

## 六、验证

- 已跑通 `flutter test test/features/viewer/`。
- 建议手动回归：普通段落/标题/列表/引用/代码块、GFM 表格、删除线、链接；\`\`\`mermaid 图表；大纲与点击大纲项滚动；搜索高亮与下一项/上一项；深色/亮色主题；链接点击由 Flutter 拦截不直接跳转。

---

*本总结置于 `learn` 文件夹，便于后续查阅与 onboarding。*
