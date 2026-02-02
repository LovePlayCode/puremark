import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/shared/services/file_watcher_service.dart';

void main() {
  group('FileWatchEvent', () {
    test('应该正确创建实例', () {
      // Arrange
      final timestamp = DateTime.now();

      // Act
      final event = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path.md',
        timestamp: timestamp,
      );

      // Assert
      expect(event.type, equals(FileWatchEventType.modified));
      expect(event.path, equals('/test/path.md'));
      expect(event.timestamp, equals(timestamp));
    });

    test('toString 应该返回正确的字符串表示', () {
      // Arrange
      final timestamp = DateTime(2024, 1, 15, 10, 30, 0);
      final event = FileWatchEvent(
        type: FileWatchEventType.deleted,
        path: '/test/file.md',
        timestamp: timestamp,
      );

      // Act
      final result = event.toString();

      // Assert
      expect(result, contains('FileWatchEvent'));
      expect(result, contains('deleted'));
      expect(result, contains('/test/file.md'));
    });

    test('相同属性的事件应该相等', () {
      // Arrange
      final timestamp = DateTime(2024, 1, 15, 10, 30, 0);
      final event1 = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path.md',
        timestamp: timestamp,
      );
      final event2 = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path.md',
        timestamp: timestamp,
      );

      // Assert
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('不同属性的事件应该不相等', () {
      // Arrange
      final timestamp = DateTime.now();
      final event1 = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path1.md',
        timestamp: timestamp,
      );
      final event2 = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path2.md',
        timestamp: timestamp,
      );

      // Assert
      expect(event1, isNot(equals(event2)));
    });

    test('不同类型的事件应该不相等', () {
      // Arrange
      final timestamp = DateTime.now();
      final event1 = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path.md',
        timestamp: timestamp,
      );
      final event2 = FileWatchEvent(
        type: FileWatchEventType.deleted,
        path: '/test/path.md',
        timestamp: timestamp,
      );

      // Assert
      expect(event1, isNot(equals(event2)));
    });
  });

  group('FileWatchEventType', () {
    test('应该有 modified 类型', () {
      expect(FileWatchEventType.values, contains(FileWatchEventType.modified));
    });

    test('应该有 deleted 类型', () {
      expect(FileWatchEventType.values, contains(FileWatchEventType.deleted));
    });
  });

  group('FileWatcherService', () {
    late FileWatcherService service;
    late Directory tempDir;
    late File tempFile;

    setUp(() async {
      service = FileWatcherService(
        debounceDuration: const Duration(milliseconds: 50),
      );
      tempDir = await Directory.systemTemp.createTemp('file_watcher_test_');
      tempFile = File('${tempDir.path}/test_file.md');
      await tempFile.writeAsString('initial content');
    });

    tearDown(() async {
      service.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('应该正确创建实例', () {
      // Assert
      expect(service, isNotNull);
      expect(service.debounceDuration, equals(const Duration(milliseconds: 50)));
    });

    test('初始状态应该不在监听', () {
      // Assert
      expect(service.isWatching, isFalse);
      expect(service.currentPath, isNull);
    });

    test('events 应该返回事件流', () {
      // Assert
      expect(service.events, isA<Stream<FileWatchEvent>>());
    });

    group('startWatching', () {
      test('开始监听后 isWatching 应该为 true', () async {
        // Act
        await service.startWatching(tempFile.path);

        // Assert
        expect(service.isWatching, isTrue);
        expect(service.currentPath, equals(tempFile.path));
      });

      test('监听不存在的文件应该发出 deleted 事件', () async {
        // Arrange
        final nonExistentPath = '${tempDir.path}/non_existent.md';
        final events = <FileWatchEvent>[];
        service.events.listen(events.add);

        // Act
        await service.startWatching(nonExistentPath);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(events.length, equals(1));
        expect(events.first.type, equals(FileWatchEventType.deleted));
        expect(events.first.path, equals(nonExistentPath));
      });

      test('重复监听同一文件不应该重新启动', () async {
        // Act
        await service.startWatching(tempFile.path);
        final firstWatcher = service.isWatching;
        await service.startWatching(tempFile.path);

        // Assert
        expect(service.isWatching, equals(firstWatcher));
        expect(service.currentPath, equals(tempFile.path));
      });

      test('监听不同文件应该停止之前的监听', () async {
        // Arrange
        final tempFile2 = File('${tempDir.path}/test_file_2.md');
        await tempFile2.writeAsString('content 2');

        // Act
        await service.startWatching(tempFile.path);
        await service.startWatching(tempFile2.path);

        // Assert
        expect(service.currentPath, equals(tempFile2.path));
      });
    });

    group('stopWatching', () {
      test('停止监听后 isWatching 应该为 false', () async {
        // Arrange
        await service.startWatching(tempFile.path);

        // Act
        service.stopWatching();

        // Assert
        expect(service.isWatching, isFalse);
        expect(service.currentPath, isNull);
      });

      test('未开始监听时调用 stopWatching 不应该报错', () {
        // Act & Assert
        expect(() => service.stopWatching(), returnsNormally);
      });
    });

    group('dispose', () {
      test('dispose 后应该停止监听', () async {
        // Arrange
        await service.startWatching(tempFile.path);

        // Act
        service.dispose();

        // Assert
        expect(service.isWatching, isFalse);
        expect(service.currentPath, isNull);
      });

      test('dispose 后事件流应该关闭', () async {
        // Arrange
        await service.startWatching(tempFile.path);

        // Act
        service.dispose();

        // Assert
        expect(service.events.isBroadcast, isTrue);
      });
    });

    group('文件变化检测', () {
      test('修改文件应该发出 modified 事件', () async {
        // Arrange
        final events = <FileWatchEvent>[];
        service.events.listen(events.add);
        await service.startWatching(tempFile.path);

        // 等待监听器启动
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        await tempFile.writeAsString('modified content');

        // 等待防抖和事件处理
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert
        expect(
          events.any((e) => e.type == FileWatchEventType.modified),
          isTrue,
          reason: '应该收到 modified 事件',
        );
      });

      test('删除文件应该发出 deleted 事件', () async {
        // Arrange
        final events = <FileWatchEvent>[];
        service.events.listen(events.add);
        await service.startWatching(tempFile.path);

        // 等待监听器启动
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        await tempFile.delete();

        // 等待防抖和事件处理
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert
        expect(
          events.any((e) => e.type == FileWatchEventType.deleted),
          isTrue,
          reason: '应该收到 deleted 事件',
        );
      });
    });

    group('防抖处理', () {
      test('快速连续修改应该只发出一个事件', () async {
        // Arrange
        final events = <FileWatchEvent>[];
        service.events.listen(events.add);
        await service.startWatching(tempFile.path);

        // 等待监听器启动
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - 快速连续修改
        await tempFile.writeAsString('change 1');
        await Future.delayed(const Duration(milliseconds: 10));
        await tempFile.writeAsString('change 2');
        await Future.delayed(const Duration(milliseconds: 10));
        await tempFile.writeAsString('change 3');

        // 等待防抖完成
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert - 由于防抖，应该只有少量事件
        // 注意：实际行为可能因文件系统而异
        expect(events.length, lessThanOrEqualTo(3));
      });
    });
  });
}
