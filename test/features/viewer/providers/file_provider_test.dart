import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/viewer/models/file_state.dart';
import 'package:puremark/features/viewer/providers/file_provider.dart';

void main() {
  group('FileState', () {
    group('构造函数', () {
      test('默认构造函数应该创建空状态', () {
        // Act
        const state = FileState();

        // Assert
        expect(state.status, equals(FileStatus.empty));
        expect(state.filePath, isNull);
        expect(state.content, isNull);
        expect(state.errorMessage, isNull);
      });

      test('factory empty 应该创建空状态', () {
        // Act
        final state = FileState.empty();

        // Assert
        expect(state.status, equals(FileStatus.empty));
        expect(state.filePath, isNull);
        expect(state.content, isNull);
        expect(state.errorMessage, isNull);
      });

      test('factory loading 应该创建加载中状态', () {
        // Arrange
        const path = '/test/path.md';

        // Act
        final state = FileState.loading(path);

        // Assert
        expect(state.status, equals(FileStatus.loading));
        expect(state.filePath, equals(path));
        expect(state.content, isNull);
        expect(state.errorMessage, isNull);
      });

      test('factory loaded 应该创建已加载状态', () {
        // Arrange
        const path = '/test/path.md';
        const content = '# Hello World';

        // Act
        final state = FileState.loaded(filePath: path, content: content);

        // Assert
        expect(state.status, equals(FileStatus.loaded));
        expect(state.filePath, equals(path));
        expect(state.content, equals(content));
        expect(state.errorMessage, isNull);
      });

      test('factory error 应该创建错误状态', () {
        // Arrange
        const path = '/test/path.md';
        const errorMessage = '文件读取失败';

        // Act
        final state = FileState.error(
          filePath: path,
          errorMessage: errorMessage,
        );

        // Assert
        expect(state.status, equals(FileStatus.error));
        expect(state.filePath, equals(path));
        expect(state.content, isNull);
        expect(state.errorMessage, equals(errorMessage));
      });

      test('error 工厂可以不传 filePath', () {
        // Arrange
        const errorMessage = '未知错误';

        // Act
        final state = FileState.error(errorMessage: errorMessage);

        // Assert
        expect(state.status, equals(FileStatus.error));
        expect(state.filePath, isNull);
        expect(state.errorMessage, equals(errorMessage));
      });
    });

    group('copyWith', () {
      test('copyWith 应该正确复制并更新字段', () {
        // Arrange
        const original = FileState(
          status: FileStatus.loaded,
          filePath: '/original.md',
          content: 'Original content',
        );

        // Act
        final updated = original.copyWith(content: 'Updated content');

        // Assert
        expect(updated.status, equals(FileStatus.loaded));
        expect(updated.filePath, equals('/original.md'));
        expect(updated.content, equals('Updated content'));
      });

      test('copyWith 不传参数应该返回相同值', () {
        // Arrange
        const original = FileState(
          status: FileStatus.loaded,
          filePath: '/test.md',
          content: 'Test content',
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });

      test('copyWith 可以更新 status', () {
        // Arrange
        final loading = FileState.loading('/test.md');

        // Act
        final loaded = loading.copyWith(
          status: FileStatus.loaded,
          content: 'Loaded content',
        );

        // Assert
        expect(loaded.status, equals(FileStatus.loaded));
        expect(loaded.content, equals('Loaded content'));
      });
    });

    group('相等性', () {
      test('相同值的 FileState 应该相等', () {
        // Arrange
        const state1 = FileState(
          status: FileStatus.loaded,
          filePath: '/test.md',
          content: 'Test',
        );
        const state2 = FileState(
          status: FileStatus.loaded,
          filePath: '/test.md',
          content: 'Test',
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('不同值的 FileState 应该不相等', () {
        // Arrange
        const state1 = FileState(status: FileStatus.empty);
        const state2 = FileState(status: FileStatus.loading);

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('toString 应该包含状态信息', () {
        // Arrange
        final state = FileState.loading('/test.md');

        // Act
        final str = state.toString();

        // Assert
        expect(str, contains('FileState'));
        expect(str, contains('loading'));
        expect(str, contains('/test.md'));
      });
    });
  });

  group('FileStatus', () {
    test('应该有四种状态', () {
      expect(FileStatus.values.length, equals(4));
      expect(FileStatus.values, contains(FileStatus.empty));
      expect(FileStatus.values, contains(FileStatus.loading));
      expect(FileStatus.values, contains(FileStatus.loaded));
      expect(FileStatus.values, contains(FileStatus.error));
    });
  });

  group('FileProvider', () {
    late ProviderContainer container;
    late Directory tempDir;

    setUp(() async {
      container = ProviderContainer();
      tempDir = await Directory.systemTemp.createTemp('puremark_test_');
    });

    tearDown(() async {
      container.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('初始状态', () {
      test('初始状态应该是 empty', () async {
        // Act
        final asyncState = container.read(fileProvider);

        // Assert - 等待初始化完成
        await container.read(fileProvider.future);
        final state = container.read(fileProvider).value;

        expect(state?.status, equals(FileStatus.empty));
        expect(state?.filePath, isNull);
        expect(state?.content, isNull);
      });
    });

    group('openFile', () {
      test('打开存在的文件应该设置 loaded 状态', () async {
        // Arrange
        final testFile = File('${tempDir.path}/test.md');
        await testFile.writeAsString('# Test Content');

        // Act
        await container.read(fileProvider.notifier).openFile(testFile.path);

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.loaded));
        expect(state?.filePath, equals(testFile.path));
        expect(state?.content, equals('# Test Content'));
      });

      test('打开不存在的文件应该设置 error 状态', () async {
        // Arrange
        const nonExistentPath = '/non/existent/file.md';

        // Act
        await container.read(fileProvider.notifier).openFile(nonExistentPath);

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.error));
        expect(state?.filePath, equals(nonExistentPath));
        expect(state?.errorMessage, contains('文件不存在'));
      });

      test('打开文件时应该先设置 loading 状态', () async {
        // Arrange
        final testFile = File('${tempDir.path}/test.md');
        await testFile.writeAsString('# Test');
        var loadingStateObserved = false;

        // Act - 监听状态变化
        container.listen<AsyncValue<FileState>>(
          fileProvider,
          (previous, next) {
            if (next.value?.status == FileStatus.loading) {
              loadingStateObserved = true;
            }
          },
          fireImmediately: true,
        );

        await container.read(fileProvider.notifier).openFile(testFile.path);

        // Assert
        expect(loadingStateObserved, isTrue);
      });

      test('打开空文件应该成功', () async {
        // Arrange
        final emptyFile = File('${tempDir.path}/empty.md');
        await emptyFile.writeAsString('');

        // Act
        await container.read(fileProvider.notifier).openFile(emptyFile.path);

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.loaded));
        expect(state?.content, equals(''));
      });

      test('打开包含中文的文件应该正确读取', () async {
        // Arrange
        final chineseFile = File('${tempDir.path}/chinese.md');
        await chineseFile.writeAsString('# 中文标题\n这是中文内容');

        // Act
        await container.read(fileProvider.notifier).openFile(chineseFile.path);

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.loaded));
        expect(state?.content, equals('# 中文标题\n这是中文内容'));
      });
    });

    group('setContent', () {
      test('loaded 状态下应该能更新内容', () async {
        // Arrange
        final testFile = File('${tempDir.path}/test.md');
        await testFile.writeAsString('# Original');
        await container.read(fileProvider.notifier).openFile(testFile.path);

        // Act
        container.read(fileProvider.notifier).setContent('# Updated');

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.content, equals('# Updated'));
        expect(state?.status, equals(FileStatus.loaded));
      });

      test('empty 状态下 setContent 应该无效', () async {
        // Arrange - 确保是 empty 状态
        await container.read(fileProvider.future);

        // Act
        container.read(fileProvider.notifier).setContent('# New Content');

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.empty));
        expect(state?.content, isNull);
      });

      test('error 状态下 setContent 应该无效', () async {
        // Arrange
        await container.read(fileProvider.notifier).openFile('/non/existent');

        // Act
        container.read(fileProvider.notifier).setContent('# New Content');

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.error));
      });
    });

    group('closeFile', () {
      test('closeFile 应该重置为 empty 状态', () async {
        // Arrange
        final testFile = File('${tempDir.path}/test.md');
        await testFile.writeAsString('# Test');
        await container.read(fileProvider.notifier).openFile(testFile.path);

        // Act
        container.read(fileProvider.notifier).closeFile();

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.empty));
        expect(state?.filePath, isNull);
        expect(state?.content, isNull);
      });

      test('从 error 状态 closeFile 应该成功', () async {
        // Arrange
        await container.read(fileProvider.notifier).openFile('/non/existent');

        // Act
        container.read(fileProvider.notifier).closeFile();

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.empty));
      });

      test('多次 closeFile 应该安全', () async {
        // Act
        await container.read(fileProvider.future);
        container.read(fileProvider.notifier).closeFile();
        container.read(fileProvider.notifier).closeFile();
        container.read(fileProvider.notifier).closeFile();

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.empty));
      });
    });

    group('连续操作', () {
      test('打开文件后关闭再打开应该正常工作', () async {
        // Arrange
        final file1 = File('${tempDir.path}/file1.md');
        final file2 = File('${tempDir.path}/file2.md');
        await file1.writeAsString('# File 1');
        await file2.writeAsString('# File 2');

        // Act
        await container.read(fileProvider.notifier).openFile(file1.path);
        container.read(fileProvider.notifier).closeFile();
        await container.read(fileProvider.notifier).openFile(file2.path);

        // Assert
        final state = container.read(fileProvider).value;
        expect(state?.status, equals(FileStatus.loaded));
        expect(state?.content, equals('# File 2'));
      });
    });

    group('Provider 类型验证', () {
      test('fileProvider 应该是 AsyncNotifierProvider', () {
        expect(
          fileProvider,
          isA<AsyncNotifierProvider<FileNotifier, FileState>>(),
        );
      });
    });
  });
}
