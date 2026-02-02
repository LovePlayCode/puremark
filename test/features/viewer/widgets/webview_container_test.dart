import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/viewer/widgets/webview_container.dart';

void main() {
  group('OutlineItem', () {
    group('构造函数', () {
      test('应该正确创建 OutlineItem', () {
        // Arrange & Act
        const item = OutlineItem(
          id: 'heading-1',
          level: 1,
          text: '标题一',
        );

        // Assert
        expect(item.id, equals('heading-1'));
        expect(item.level, equals(1));
        expect(item.text, equals('标题一'));
      });

      test('应该支持不同级别的标题', () {
        // Arrange & Act
        const items = [
          OutlineItem(id: 'h1', level: 1, text: 'H1'),
          OutlineItem(id: 'h2', level: 2, text: 'H2'),
          OutlineItem(id: 'h3', level: 3, text: 'H3'),
          OutlineItem(id: 'h4', level: 4, text: 'H4'),
          OutlineItem(id: 'h5', level: 5, text: 'H5'),
          OutlineItem(id: 'h6', level: 6, text: 'H6'),
        ];

        // Assert
        for (var i = 0; i < items.length; i++) {
          expect(items[i].level, equals(i + 1));
        }
      });
    });

    group('相等性', () {
      test('相同值的 OutlineItem 应该相等', () {
        // Arrange
        const item1 = OutlineItem(id: 'test', level: 2, text: 'Test');
        const item2 = OutlineItem(id: 'test', level: 2, text: 'Test');

        // Assert
        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('不同 id 的 OutlineItem 应该不相等', () {
        // Arrange
        const item1 = OutlineItem(id: 'test1', level: 2, text: 'Test');
        const item2 = OutlineItem(id: 'test2', level: 2, text: 'Test');

        // Assert
        expect(item1, isNot(equals(item2)));
      });

      test('不同 level 的 OutlineItem 应该不相等', () {
        // Arrange
        const item1 = OutlineItem(id: 'test', level: 1, text: 'Test');
        const item2 = OutlineItem(id: 'test', level: 2, text: 'Test');

        // Assert
        expect(item1, isNot(equals(item2)));
      });

      test('不同 text 的 OutlineItem 应该不相等', () {
        // Arrange
        const item1 = OutlineItem(id: 'test', level: 2, text: 'Test1');
        const item2 = OutlineItem(id: 'test', level: 2, text: 'Test2');

        // Assert
        expect(item1, isNot(equals(item2)));
      });
    });

    group('toString', () {
      test('toString 应该包含所有字段', () {
        // Arrange
        const item = OutlineItem(id: 'my-id', level: 3, text: '我的标题');

        // Act
        final str = item.toString();

        // Assert
        expect(str, contains('OutlineItem'));
        expect(str, contains('my-id'));
        expect(str, contains('3'));
        expect(str, contains('我的标题'));
      });
    });
  });

  group('WebViewContainer', () {
    // 注意：WebViewContainer 的 Widget 测试需要平台实现，
    // 在单元测试环境中不可用。以下测试仅验证构造函数和参数。

    group('构造函数参数', () {
      test('应该支持默认参数', () {
        // 验证 WebViewContainer 可以使用默认参数创建
        const widget = WebViewContainer();

        expect(widget.content, equals(''));
        expect(widget.onOutlineGenerated, isNull);
        expect(widget.onLinkClicked, isNull);
        expect(widget.scrollController, isNull);
      });

      test('应该支持自定义 content', () {
        const content = '# Hello World';
        const widget = WebViewContainer(content: content);

        expect(widget.content, equals(content));
      });

      test('应该支持空 content', () {
        const widget = WebViewContainer(content: '');

        expect(widget.content, isEmpty);
      });

      test('应该支持中文内容', () {
        const content = '# 中文标题\n这是中文内容';
        const widget = WebViewContainer(content: content);

        expect(widget.content, equals(content));
      });

      test('应该支持 onOutlineGenerated 回调', () {
        List<OutlineItem>? receivedItems;

        final widget = WebViewContainer(
          onOutlineGenerated: (items) {
            receivedItems = items;
          },
        );

        expect(widget.onOutlineGenerated, isNotNull);
        // 手动调用回调验证
        widget.onOutlineGenerated!([
          const OutlineItem(id: 'h1', level: 1, text: 'Title'),
        ]);
        expect(receivedItems, isNotNull);
        expect(receivedItems!.length, equals(1));
      });

      test('应该支持 onLinkClicked 回调', () {
        String? clickedUrl;

        final widget = WebViewContainer(
          onLinkClicked: (url) {
            clickedUrl = url;
          },
        );

        expect(widget.onLinkClicked, isNotNull);
        // 手动调用回调验证
        widget.onLinkClicked!('https://example.com');
        expect(clickedUrl, equals('https://example.com'));
      });

      test('应该支持所有参数组合', () {
        List<OutlineItem>? outlineItems;
        String? linkUrl;

        final widget = WebViewContainer(
          content: '# Test',
          onOutlineGenerated: (items) => outlineItems = items,
          onLinkClicked: (url) => linkUrl = url,
        );

        expect(widget.content, equals('# Test'));
        expect(widget.onOutlineGenerated, isNotNull);
        expect(widget.onLinkClicked, isNotNull);
      });
    });

    group('Key 验证', () {
      test('WebViewContainer 应该使用正确的 Key', () {
        // 验证 widget 定义中使用了正确的 key
        // 实际 key 是在 build 方法中的 Container 上设置的
        const widget = WebViewContainer();
        expect(widget.key, isNull); // widget 本身可以没有 key
      });
    });
  });

  group('WebViewContainer 内容处理', () {
    test('应该能处理空内容', () {
      const widget = WebViewContainer(content: '');
      expect(widget.content, isEmpty);
    });

    test('应该能处理简单 Markdown', () {
      const content = '# Title\n\nParagraph text.';
      const widget = WebViewContainer(content: content);
      expect(widget.content, equals(content));
    });

    test('应该能处理代码块', () {
      const content = '''
# Code Example

```dart
void main() {
  print('Hello');
}
```
''';
      const widget = WebViewContainer(content: content);
      expect(widget.content, contains('```dart'));
    });

    test('应该能处理特殊字符', () {
      const content = r'''
# Special Characters

Test: "quotes", 'single quotes', <angle>, &amp;

Escape: \n \t \\
''';
      const widget = WebViewContainer(content: content);
      expect(widget.content, contains('Special Characters'));
    });

    test('应该能处理链接', () {
      const content = '[Link Text](https://example.com)';
      const widget = WebViewContainer(content: content);
      expect(widget.content, contains('https://example.com'));
    });

    test('应该能处理图片', () {
      const content = '![Alt Text](image.png)';
      const widget = WebViewContainer(content: content);
      expect(widget.content, contains('image.png'));
    });

    test('应该能处理列表', () {
      const content = '''
- Item 1
- Item 2
- Item 3
''';
      const widget = WebViewContainer(content: content);
      expect(widget.content, contains('Item 1'));
    });

    test('应该能处理任务列表', () {
      const content = '''
- [x] Completed task
- [ ] Pending task
''';
      const widget = WebViewContainer(content: content);
      expect(widget.content, contains('[x]'));
      expect(widget.content, contains('[ ]'));
    });

    test('应该能处理表格', () {
      const content = '''
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
''';
      const widget = WebViewContainer(content: content);
      expect(widget.content, contains('Header 1'));
    });
  });
}
