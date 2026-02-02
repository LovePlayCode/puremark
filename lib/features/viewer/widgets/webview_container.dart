import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Markdown 大纲标题项。
///
/// 用于表示从 Markdown 内容中提取的标题信息。
class OutlineItem {
  /// 创建一个大纲标题项。
  const OutlineItem({
    required this.id,
    required this.level,
    required this.text,
  });

  /// 标题的唯一标识符
  final String id;

  /// 标题级别 (1-6)
  final int level;

  /// 标题文本
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutlineItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          level == other.level &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ level.hashCode ^ text.hashCode;

  @override
  String toString() => 'OutlineItem(id: $id, level: $level, text: $text)';
}

/// WebView 容器 Widget。
///
/// 用于渲染 Markdown 内容的 WebView 容器。
/// 支持大纲生成、链接拦截和滚动控制。
///
/// 使用示例：
/// ```dart
/// WebViewContainer(
///   content: '# Hello World',
///   isDarkMode: true,
///   onOutlineGenerated: (items) {
///     print('Outline: $items');
///   },
///   onLinkClicked: (url) {
///     // 处理外部链接
///   },
/// )
/// ```
class WebViewContainer extends StatefulWidget {
  /// 创建一个 WebView 容器。
  const WebViewContainer({
    super.key,
    this.content = '',
    this.isDarkMode = true,
    this.onOutlineGenerated,
    this.onLinkClicked,
    this.scrollController,
  });

  /// Markdown 内容
  final String content;

  /// 是否为暗色模式
  final bool isDarkMode;

  /// 大纲生成回调
  final void Function(List<OutlineItem> items)? onOutlineGenerated;

  /// 链接点击回调
  final void Function(String url)? onLinkClicked;

  /// 滚动控制器
  final ScrollController? scrollController;

  @override
  State<WebViewContainer> createState() => WebViewContainerState();
}

/// WebView 容器状态。
///
/// 管理 WebView 的初始化、内容更新和 JavaScript 通信。
class WebViewContainerState extends State<WebViewContainer> {
  InAppWebViewController? _webViewController;
  bool _isWebViewReady = false;
  String _pendingContent = '';
  bool _pageLoaded = false;

  @override
  void didUpdateWidget(WebViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 主题变化时更新样式
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      debugPrint('[WebView] Theme changed to ${widget.isDarkMode ? "dark" : "light"}');
      _updateTheme();
    }
    
    if (oldWidget.content != widget.content) {
      debugPrint('[WebView] didUpdateWidget: content changed, isReady=$_isWebViewReady, pageLoaded=$_pageLoaded');
      if (_isWebViewReady && _pageLoaded) {
        _updateContent();
      } else {
        // 如果 WebView 还没准备好，保存待处理的内容
        _pendingContent = widget.content;
        debugPrint('[WebView] Saved pending content, length=${_pendingContent.length}');
      }
    }
  }
  
  void _updateTheme() {
    if (_webViewController == null || !_isWebViewReady) return;
    
    final isDark = widget.isDarkMode;
    _webViewController?.evaluateJavascript(
      source: 'setTheme(${isDark ? "true" : "false"});',
    );
  }

  /// 滚动到指定标题。
  ///
  /// [headingId] 标题的 ID
  Future<void> scrollToHeading(String headingId) async {
    if (_webViewController != null && _isWebViewReady) {
      await _webViewController?.evaluateJavascript(
        source: 'scrollToHeading("$headingId");',
      );
    }
  }

  /// 滚动到顶部。
  Future<void> scrollToTop() async {
    if (_webViewController != null && _isWebViewReady) {
      await _webViewController?.evaluateJavascript(
        source: 'window.scrollTo(0, 0);',
      );
    }
  }

  /// 滚动到底部。
  Future<void> scrollToBottom() async {
    if (_webViewController != null && _isWebViewReady) {
      await _webViewController?.evaluateJavascript(
        source: 'window.scrollTo(0, document.body.scrollHeight);',
      );
    }
  }

  void _updateContent() {
    if (_webViewController == null) {
      debugPrint('[WebView] _updateContent: controller is null');
      return;
    }
    
    final contentToRender = _pendingContent.isNotEmpty ? _pendingContent : widget.content;
    if (contentToRender.isEmpty) {
      debugPrint('[WebView] _updateContent: content is empty');
      return;
    }

    debugPrint('[WebView] _updateContent: rendering content, length=${contentToRender.length}');

    // 转义 Markdown 内容中的特殊字符
    final escapedContent = contentToRender
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    _webViewController?.evaluateJavascript(
      source: 'updateMarkdown("$escapedContent");',
    );
    
    // 清空待处理内容
    if (_pendingContent.isNotEmpty) {
      _pendingContent = '';
    }
  }

  void _handleOutlineGenerated(List<dynamic> items) {
    final outlineItems = items.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return OutlineItem(
        id: map['id'] as String,
        level: map['level'] as int,
        text: map['text'] as String,
      );
    }).toList();

    widget.onOutlineGenerated?.call(outlineItems);
  }

  String _getHtmlContent() {
    final isDark = widget.isDarkMode;
    final mermaidTheme = isDark ? 'dark' : 'default';
    
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
    ${_getCssContent()}
  </style>
</head>
<body>
  <div id="content"></div>
  <script>
    // 初始化 Mermaid
    mermaid.initialize({
      startOnLoad: false,
      theme: '$mermaidTheme',
      securityLevel: 'loose',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    });
    
    var currentMermaidTheme = '$mermaidTheme';
    
    ${_getJavaScriptContent()}
  </script>
</body>
</html>
''';
  }

  String _getCssContent() {
    final isDark = widget.isDarkMode;
    
    // 暗色主题颜色
    const darkBgPrimary = '#1A1A1C';
    const darkBgSurface = '#242426';
    const darkCodeBg = '#2A2A2C';
    const darkTextPrimary = '#F5F5F0';
    const darkTextSecondary = '#6E6E70';
    const darkBorderPrimary = '#3A3A3C';
    const darkAccentPrimary = '#8B9EFF';
    
    // 亮色主题颜色
    const lightBgPrimary = '#FFFFFF';
    const lightBgSurface = '#F5F5F5';
    const lightCodeBg = '#F0F0F0';
    const lightTextPrimary = '#1A1A1C';
    const lightTextSecondary = '#6E6E70';
    const lightBorderPrimary = '#E0E0E0';
    const lightAccentPrimary = '#5B6BFF';
    
    final bgPrimary = isDark ? darkBgPrimary : lightBgPrimary;
    final bgSurface = isDark ? darkBgSurface : lightBgSurface;
    final codeBg = isDark ? darkCodeBg : lightCodeBg;
    final textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    final textSecondary = isDark ? darkTextSecondary : lightTextSecondary;
    final borderPrimary = isDark ? darkBorderPrimary : lightBorderPrimary;
    final accentPrimary = isDark ? darkAccentPrimary : lightAccentPrimary;
    
    return '''
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

:root {
  --bg-primary: $bgPrimary;
  --bg-surface: $bgSurface;
  --code-bg: $codeBg;
  --text-primary: $textPrimary;
  --text-secondary: $textSecondary;
  --border-primary: $borderPrimary;
  --accent-primary: $accentPrimary;
}

html, body {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  font-size: 16px;
  line-height: 1.6;
  padding: 24px;
  overflow-x: hidden;
}

#content {
  max-width: 800px;
  margin: 0 auto;
}

h1, h2, h3, h4, h5, h6 {
  color: var(--text-primary);
  font-weight: 600;
  margin-top: 1.5em;
  margin-bottom: 0.5em;
  line-height: 1.3;
}

h1 { font-size: 2em; border-bottom: 1px solid var(--border-primary); padding-bottom: 0.3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid var(--border-primary); padding-bottom: 0.3em; }
h3 { font-size: 1.25em; }
h4 { font-size: 1em; }
h5 { font-size: 0.875em; }
h6 { font-size: 0.85em; color: var(--text-secondary); }

p {
  margin-bottom: 1em;
}

a {
  color: var(--accent-primary);
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

code {
  background-color: var(--code-bg);
  padding: 0.2em 0.4em;
  border-radius: 4px;
  font-family: "SF Mono", Monaco, "Cascadia Code", "Roboto Mono", monospace;
  font-size: 0.9em;
}

pre {
  background-color: var(--code-bg);
  border-radius: 8px;
  padding: 16px;
  overflow-x: auto;
  margin-bottom: 1em;
}

pre code {
  background: none;
  padding: 0;
  font-size: 0.875em;
}

blockquote {
  border-left: 4px solid var(--accent-primary);
  padding-left: 16px;
  margin: 1em 0;
  color: var(--text-secondary);
}

ul, ol {
  margin-bottom: 1em;
  padding-left: 2em;
}

li {
  margin-bottom: 0.25em;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1em;
}

th, td {
  border: 1px solid var(--border-primary);
  padding: 8px 12px;
  text-align: left;
}

th {
  background-color: var(--bg-surface);
  font-weight: 600;
}

tr:nth-child(even) {
  background-color: var(--bg-surface);
}

hr {
  border: none;
  border-top: 1px solid var(--border-primary);
  margin: 2em 0;
}

img {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
}

.task-list-item {
  list-style: none;
  margin-left: -1.5em;
}

.task-list-item input[type="checkbox"] {
  margin-right: 0.5em;
}

/* Mermaid 图表样式 */
.mermaid {
  background-color: var(--bg-surface);
  border-radius: 8px;
  padding: 16px;
  margin: 1em 0;
  overflow-x: auto;
  text-align: center;
}

.mermaid svg {
  max-width: 100%;
  height: auto;
}
''';
  }

  String _getJavaScriptContent() {
    // 使用 raw string 避免 $ 符号转义问题
    return r'''
// 简单的 Markdown 解析器
var mermaidCounter = 0;
var codeBlocks = [];
var inlineCodeBlocks = [];

function parseMarkdown(text) {
  if (!text) return '';
  
  let html = text;
  mermaidCounter = 0;
  codeBlocks = [];
  inlineCodeBlocks = [];
  
  // 第一步：提取所有代码块并替换为占位符
  // 处理 ``` 代码块（支持有无语言标识）
  html = html.replace(/```(\w*)\s*\n([\s\S]*?)```/g, function(match, lang, code) {
    const index = codeBlocks.length;
    let replacement;
    
    // Mermaid 图表特殊处理
    if (lang === 'mermaid') {
      mermaidCounter++;
      replacement = '<div class="mermaid" id="mermaid-' + mermaidCounter + '">' + code.trim() + '</div>';
    } else {
      const langClass = lang ? ' class="language-' + lang + '"' : '';
      replacement = '<pre><code' + langClass + '>' + escapeHtml(code.trim()) + '</code></pre>';
    }
    
    codeBlocks.push(replacement);
    return '%%CODEBLOCK_' + index + '%%';
  });
  
  // 第二步：提取行内代码并替换为占位符
  html = html.replace(/`([^`\n]+)`/g, function(match, code) {
    const index = inlineCodeBlocks.length;
    inlineCodeBlocks.push('<code>' + escapeHtml(code) + '</code>');
    return '%%INLINECODE_' + index + '%%';
  });
  
  // 第三步：处理其他 Markdown 语法
  
  // 标题 (同时生成 ID)
  html = html.replace(/^#{6}\s+(.*)$/gm, function(match, text) {
    const id = generateHeadingId(text);
    return '<h6 id="' + id + '">' + text + '</h6>';
  });
  html = html.replace(/^#{5}\s+(.*)$/gm, function(match, text) {
    const id = generateHeadingId(text);
    return '<h5 id="' + id + '">' + text + '</h5>';
  });
  html = html.replace(/^#{4}\s+(.*)$/gm, function(match, text) {
    const id = generateHeadingId(text);
    return '<h4 id="' + id + '">' + text + '</h4>';
  });
  html = html.replace(/^#{3}\s+(.*)$/gm, function(match, text) {
    const id = generateHeadingId(text);
    return '<h3 id="' + id + '">' + text + '</h3>';
  });
  html = html.replace(/^#{2}\s+(.*)$/gm, function(match, text) {
    const id = generateHeadingId(text);
    return '<h2 id="' + id + '">' + text + '</h2>';
  });
  html = html.replace(/^#{1}\s+(.*)$/gm, function(match, text) {
    const id = generateHeadingId(text);
    return '<h1 id="' + id + '">' + text + '</h1>';
  });
  
  // 粗体和斜体
  html = html.replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>');
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');
  html = html.replace(/___(.+?)___/g, '<strong><em>$1</em></strong>');
  html = html.replace(/__(.+?)__/g, '<strong>$1</strong>');
  html = html.replace(/_(.+?)_/g, '<em>$1</em>');
  
  // 删除线
  html = html.replace(/~~(.+?)~~/g, '<del>$1</del>');
  
  // 链接
  html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" onclick="handleLinkClick(event, \'$2\')">$1</a>');
  
  // 图片
  html = html.replace(/!\[([^\]]*?)\]\(([^)]+)\)/g, '<img src="$2" alt="$1">');
  
  // 引用
  html = html.replace(/^>\s+(.*)$/gm, '<blockquote>$1</blockquote>');
  
  // 水平线
  html = html.replace(/^([-*_]){3,}$/gm, '<hr>');
  
  // 无序列表
  html = html.replace(/^[*\-+]\s+(.*)$/gm, '<li>$1</li>');
  
  // 有序列表
  html = html.replace(/^\d+\.\s+(.*)$/gm, '<li>$1</li>');
  
  // 任务列表
  html = html.replace(/<li>\[x\]\s+(.*)$/gmi, '<li class="task-list-item"><input type="checkbox" checked disabled>$1');
  html = html.replace(/<li>\[ \]\s+(.*)$/gm, '<li class="task-list-item"><input type="checkbox" disabled>$1');
  
  // 段落 (换行)
  html = html.replace(/\n\n/g, '</p><p>');
  html = '<p>' + html + '</p>';
  
  // 清理空段落
  html = html.replace(/<p><\/p>/g, '');
  html = html.replace(/<p>(<h[1-6])/g, '$1');
  html = html.replace(/(<\/h[1-6]>)<\/p>/g, '$1');
  html = html.replace(/<p>(%%CODEBLOCK)/g, '$1');
  html = html.replace(/(%%)<\/p>/g, '$1');
  html = html.replace(/<p>(<blockquote)/g, '$1');
  html = html.replace(/(<\/blockquote>)<\/p>/g, '$1');
  html = html.replace(/<p>(<hr>)/g, '$1');
  html = html.replace(/(<hr>)<\/p>/g, '$1');
  html = html.replace(/<p>(<li)/g, '<ul>$1');
  html = html.replace(/(<\/li>)<\/p>/g, '$1</ul>');
  html = html.replace(/<p>(<div class="mermaid")/g, '$1');
  html = html.replace(/(<\/div>)<\/p>/g, '$1');
  
  // 第四步：恢复代码块
  for (let i = 0; i < codeBlocks.length; i++) {
    html = html.replace('%%CODEBLOCK_' + i + '%%', codeBlocks[i]);
  }
  
  // 第五步：恢复行内代码
  for (let i = 0; i < inlineCodeBlocks.length; i++) {
    html = html.replace('%%INLINECODE_' + i + '%%', inlineCodeBlocks[i]);
  }
  
  return html;
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function generateHeadingId(text) {
  return text.toLowerCase()
    .replace(/[^a-z0-9\u4e00-\u9fa5]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

async function updateMarkdown(content) {
  const contentEl = document.getElementById('content');
  contentEl.innerHTML = parseMarkdown(content);
  
  // 渲染 Mermaid 图表
  await renderMermaidDiagrams();
  
  extractOutline();
}

async function renderMermaidDiagrams() {
  const mermaidElements = document.querySelectorAll('.mermaid');
  if (mermaidElements.length === 0) return;
  
  try {
    await mermaid.run({
      nodes: mermaidElements
    });
  } catch (e) {
    console.error('Mermaid render error:', e);
  }
}

function extractOutline() {
  const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
  const outline = [];
  
  headings.forEach(function(heading) {
    outline.push({
      id: heading.id,
      level: parseInt(heading.tagName.charAt(1)),
      text: heading.textContent
    });
  });
  
  // 通过 Flutter handler 发送大纲
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onOutlineGenerated', outline);
  }
}

function scrollToHeading(headingId) {
  const element = document.getElementById(headingId);
  if (element) {
    element.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
}

function handleLinkClick(event, url) {
  event.preventDefault();
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onLinkClicked', url);
  }
}

async function setTheme(isDark) {
  const root = document.documentElement;
  if (isDark) {
    root.style.setProperty('--bg-primary', '#1A1A1C');
    root.style.setProperty('--bg-surface', '#242426');
    root.style.setProperty('--code-bg', '#2A2A2C');
    root.style.setProperty('--text-primary', '#F5F5F0');
    root.style.setProperty('--text-secondary', '#6E6E70');
    root.style.setProperty('--border-primary', '#3A3A3C');
    root.style.setProperty('--accent-primary', '#8B9EFF');
  } else {
    root.style.setProperty('--bg-primary', '#FFFFFF');
    root.style.setProperty('--bg-surface', '#F5F5F5');
    root.style.setProperty('--code-bg', '#F0F0F0');
    root.style.setProperty('--text-primary', '#1A1A1C');
    root.style.setProperty('--text-secondary', '#6E6E70');
    root.style.setProperty('--border-primary', '#E0E0E0');
    root.style.setProperty('--accent-primary', '#5B6BFF');
  }
  document.body.style.backgroundColor = isDark ? '#1A1A1C' : '#FFFFFF';
  
  // 更新 Mermaid 主题
  const newTheme = isDark ? 'dark' : 'default';
  if (currentMermaidTheme !== newTheme) {
    currentMermaidTheme = newTheme;
    mermaid.initialize({
      startOnLoad: false,
      theme: newTheme,
      securityLevel: 'loose',
    });
    // 重新渲染 Mermaid 图表
    await renderMermaidDiagrams();
  }
}

// 初始化时通知 Flutter WebView 已就绪
document.addEventListener('DOMContentLoaded', function() {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onWebViewReady');
  }
});
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('webviewContainer'),
      color: Colors.transparent,
      child: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: _getHtmlContent(),
          mimeType: 'text/html',
          encoding: 'utf-8',
        ),
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          javaScriptEnabled: true,
          supportZoom: false,
          disableHorizontalScroll: true,
          disableVerticalScroll: false,
          // macOS 特定设置
          allowsBackForwardNavigationGestures: false,
          isInspectable: true,
          // 禁用可能导致崩溃的功能
          mediaPlaybackRequiresUserGesture: true,
          allowsInlineMediaPlayback: false,
        ),
        onWebViewCreated: (controller) {
          debugPrint('[WebView] onWebViewCreated');
          _webViewController = controller;

          // 注册 JavaScript handler: 大纲生成
          controller.addJavaScriptHandler(
            handlerName: 'onOutlineGenerated',
            callback: (args) {
              debugPrint('[WebView] onOutlineGenerated callback, args count: ${args.length}');
              if (args.isNotEmpty) {
                _handleOutlineGenerated(args[0] as List<dynamic>);
              }
            },
          );

          // 注册 JavaScript handler: 链接点击
          controller.addJavaScriptHandler(
            handlerName: 'onLinkClicked',
            callback: (args) {
              if (args.isNotEmpty) {
                widget.onLinkClicked?.call(args[0] as String);
              }
            },
          );

          // 注册 JavaScript handler: WebView 就绪
          controller.addJavaScriptHandler(
            handlerName: 'onWebViewReady',
            callback: (args) {
              debugPrint('[WebView] onWebViewReady handler called');
              if (!_isWebViewReady) {
                setState(() {
                  _isWebViewReady = true;
                });
              }
              // 处理待渲染的内容或当前内容
              _updateContent();
            },
          );
        },
        onLoadStart: (controller, url) {
          debugPrint('[WebView] onLoadStart, url=$url');
        },
        onLoadStop: (controller, url) async {
          debugPrint('[WebView] onLoadStop, url=$url, isReady=$_isWebViewReady');
          
          // 标记页面已加载
          _pageLoaded = true;
          
          // 页面加载完成后，确保 WebView 已就绪
          if (!_isWebViewReady) {
            // 延迟一小段时间等待 JavaScript 初始化完成
            await Future.delayed(const Duration(milliseconds: 200));
            debugPrint('[WebView] Setting isWebViewReady = true');
            setState(() {
              _isWebViewReady = true;
            });
          }
          
          // 主动调用 JavaScript 来触发 WebView 就绪通知（处理 DOMContentLoaded 已错过的情况）
          await controller.evaluateJavascript(
            source: '''
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('onWebViewReady');
              }
            ''',
          );
          
          // 更新内容 - 处理待渲染的内容或当前内容
          _updateContent();
        },
        onReceivedError: (controller, request, error) {
          debugPrint('[WebView] onReceivedError: ${error.type} - ${error.description}');
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint('[WebView] Console: ${consoleMessage.messageLevel} - ${consoleMessage.message}');
        },
      ),
    );
  }
}
