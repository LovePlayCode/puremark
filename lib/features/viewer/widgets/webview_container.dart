import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../search/models/search_state.dart';

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
    this.searchQuery = '',
    this.currentMatch = 0,
    this.searchOptions = const SearchOptions(),
    this.searchVersion = 0,
    this.onOutlineGenerated,
    this.onLinkClicked,
    this.onSearchResults,
    this.scrollController,
  });

  /// Markdown 内容
  final String content;

  /// 是否为暗色模式
  final bool isDarkMode;

  /// 搜索查询词
  final String searchQuery;

  /// 当前匹配索引
  final int currentMatch;

  /// 搜索选项
  final SearchOptions searchOptions;

  /// 搜索版本号（用于防止竞态条件）
  final int searchVersion;

  /// 大纲生成回调
  final void Function(List<OutlineItem> items)? onOutlineGenerated;

  /// 链接点击回调
  final void Function(String url)? onLinkClicked;

  /// 搜索结果回调，包含匹配数量和搜索版本号
  final void Function(int totalMatches, int version)? onSearchResults;

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
    
    // 搜索查询或选项变化时执行搜索
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.searchOptions != widget.searchOptions) {
      _performSearch();
    }
    
    // 当前匹配变化时跳转
    if (oldWidget.currentMatch != widget.currentMatch) {
      debugPrint('[WebView] currentMatch changed: ${oldWidget.currentMatch} -> ${widget.currentMatch}');
      if (widget.currentMatch > 0) {
        _goToMatch(widget.currentMatch);
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
  
  void _performSearch() {
    if (_webViewController == null || !_isWebViewReady) return;
    
    final query = widget.searchQuery;
    final options = widget.searchOptions;
    final version = widget.searchVersion;
    
    if (query.isEmpty) {
      _webViewController?.evaluateJavascript(source: 'clearSearch();');
      // 延迟到构建完成后更新状态
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSearchResults?.call(0, version);
      });
    } else {
      final escapedQuery = query
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n');
      
      // 传递搜索选项和版本号
      _webViewController?.evaluateJavascript(
        source: '''performSearch("$escapedQuery", {
          caseSensitive: ${options.caseSensitive},
          wholeWord: ${options.wholeWord},
          useRegex: ${options.useRegex},
          version: $version
        });''',
      );
    }
  }
  
  void _goToMatch(int matchIndex) {
    if (_webViewController == null || !_isWebViewReady) return;
    debugPrint('[WebView] _goToMatch called with index: $matchIndex');
    _webViewController?.evaluateJavascript(
      source: 'goToMatch($matchIndex);',
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
  <script src="https://cdn.jsdelivr.net/npm/markdown-it@14/dist/markdown-it.min.js"></script>
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

.table-wrapper {
  overflow-x: auto;
  margin-bottom: 1em;
}
table {
  width: 100%;
  border-collapse: collapse;
  min-width: 100%;
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

/* 搜索高亮样式 */
.search-highlight {
  background-color: rgba(255, 213, 79, 0.4);
  border-radius: 2px;
  padding: 0 1px;
}

.search-highlight-current {
  background-color: rgba(255, 152, 0, 0.6);
  outline: 2px solid #FF9800;
}
''';
  }

  String _getJavaScriptContent() {
    // 使用 raw string 避免 $ 符号转义问题
    return r'''
// markdown-it 解析器（CommonMark/GFM）
var md = window.markdownit({ html: true, linkify: true, typographer: true });

function postProcessContent(contentEl) {
  // 为标题添加 id，供大纲与滚动使用
  contentEl.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(function(h) {
    if (!h.id) h.id = generateHeadingId(h.textContent);
  });
  // 将 markdown-it 输出的 language-mermaid 代码块替换为 div.mermaid，供 mermaid.run() 渲染
  contentEl.querySelectorAll('pre > code.language-mermaid').forEach(function(code) {
    var pre = code.parentElement;
    var div = document.createElement('div');
    div.className = 'mermaid';
    div.textContent = code.textContent;
    pre.parentNode.replaceChild(div, pre);
  });
  // 链接点击交由 Flutter 处理
  contentEl.querySelectorAll('a[href]').forEach(function(a) {
    var url = a.getAttribute('href');
    a.addEventListener('click', function(e) {
      e.preventDefault();
      handleLinkClick(e, url);
    });
  });
}

function generateHeadingId(text) {
  return text.toLowerCase()
    .replace(/[^a-z0-9\u4e00-\u9fa5]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

async function updateMarkdown(content) {
  const contentEl = document.getElementById('content');
  contentEl.innerHTML = md.render(content);
  postProcessContent(contentEl);
  
  // 重置搜索的原始内容缓存
  resetOriginalContent();
  
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

// 搜索相关变量
var searchMatches = [];
var currentSearchIndex = 0;
var originalContent = '';

function performSearch(query, options) {
  // options: { caseSensitive, wholeWord, useRegex, version }
  clearSearch();
  
  if (!query || query.trim() === '') {
    notifySearchResults(0, options ? options.version : 0);
    return;
  }
  
  const contentEl = document.getElementById('content');
  if (!contentEl) {
    notifySearchResults(0, options ? options.version : 0);
    return;
  }
  
  // 每次搜索都保存当前内容（clearSearch 已恢复为干净状态）
  originalContent = contentEl.innerHTML;
  
  let pattern;
  if (options && options.useRegex) {
    try {
      pattern = query;
    } catch (e) {
      console.error('Invalid regex:', e);
      notifySearchResults(0, options.version);
      return;
    }
  } else {
    pattern = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
  
  // 整词匹配
  if (options && options.wholeWord) {
    pattern = '\\b' + pattern + '\\b';
  }
  
  const flags = (options && options.caseSensitive) ? 'g' : 'gi';
  
  try {
    const regex = new RegExp(pattern, flags);
    let matchCount = 0;
    
    // 使用 TreeWalker 遍历所有文本节点，避免修改 HTML 标签内容
    const walker = document.createTreeWalker(
      contentEl,
      NodeFilter.SHOW_TEXT,
      null,
      false
    );
    
    const textNodes = [];
    let node;
    while (node = walker.nextNode()) {
      if (node.nodeValue.trim()) {
        textNodes.push(node);
      }
    }
    
    // 对每个文本节点进行搜索和高亮
    textNodes.forEach(function(textNode) {
      const text = textNode.nodeValue;
      const matches = [];
      let match;
      
      // 重置 regex 的 lastIndex
      regex.lastIndex = 0;
      
      while ((match = regex.exec(text)) !== null) {
        matches.push({
          index: match.index,
          length: match[0].length,
          text: match[0]
        });
        // 防止无限循环（对于零长度匹配）
        if (match[0].length === 0) {
          regex.lastIndex++;
        }
      }
      
      if (matches.length === 0) return;
      
      // 从后向前替换，避免索引偏移问题
      const parent = textNode.parentNode;
      const fragment = document.createDocumentFragment();
      let lastIndex = 0;
      
      matches.forEach(function(m) {
        // 添加匹配前的文本
        if (m.index > lastIndex) {
          fragment.appendChild(document.createTextNode(text.substring(lastIndex, m.index)));
        }
        
        // 添加高亮的匹配文本
        matchCount++;
        const span = document.createElement('span');
        span.className = 'search-highlight';
        span.setAttribute('data-match-index', matchCount);
        span.textContent = m.text;
        fragment.appendChild(span);
        
        lastIndex = m.index + m.length;
      });
      
      // 添加最后剩余的文本
      if (lastIndex < text.length) {
        fragment.appendChild(document.createTextNode(text.substring(lastIndex)));
      }
      
      // 替换原文本节点
      parent.replaceChild(fragment, textNode);
    });
    
    searchMatches = Array.from(document.querySelectorAll('.search-highlight'));
    
    console.log('[JS] performSearch found', searchMatches.length, 'matches');
    notifySearchResults(searchMatches.length, options ? options.version : 0);
    
    if (searchMatches.length > 0) {
      currentSearchIndex = 0;
      searchMatches[0].classList.add('search-highlight-current');
      searchMatches[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  } catch (e) {
    console.error('Search error:', e);
    notifySearchResults(0, options ? options.version : 0);
  }
}

function clearSearch() {
  const contentEl = document.getElementById('content');
  if (contentEl && originalContent) {
    contentEl.innerHTML = originalContent;
  }
  searchMatches = [];
  currentSearchIndex = 0;
}

function resetOriginalContent() {
  originalContent = '';
}

function goToMatch(matchIndex) {
  console.log('[JS] goToMatch called with:', matchIndex, 'total matches:', searchMatches.length);
  if (searchMatches.length === 0) return;
  
  // 边界检查和循环
  let newIndex = matchIndex - 1; // 转换为0索引
  if (newIndex < 0) newIndex = searchMatches.length - 1;
  if (newIndex >= searchMatches.length) newIndex = 0;
  
  console.log('[JS] Moving from index', currentSearchIndex, 'to', newIndex);
  
  // 移除之前的当前匹配样式
  if (currentSearchIndex >= 0 && currentSearchIndex < searchMatches.length) {
    searchMatches[currentSearchIndex].classList.remove('search-highlight-current');
  }
  
  // 设置新的当前匹配
  currentSearchIndex = newIndex;
  searchMatches[currentSearchIndex].classList.add('search-highlight-current');
  searchMatches[currentSearchIndex].scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function notifySearchResults(count, version) {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onSearchResults', count, version);
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

          // 注册 JavaScript handler: 搜索结果
          controller.addJavaScriptHandler(
            handlerName: 'onSearchResults',
            callback: (args) {
              debugPrint('[WebView] onSearchResults callback, args: $args');
              if (args.isNotEmpty) {
                final totalMatches = args[0] as int;
                final version = args.length > 1 ? args[1] as int : widget.searchVersion;
                // 延迟到构建完成后更新状态，避免在构建期间修改 Provider
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onSearchResults?.call(totalMatches, version);
                });
              }
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
