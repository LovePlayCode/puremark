import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/viewer/providers/file_watcher_provider.dart';
import 'package:puremark/shared/services/file_watcher_service.dart';

void main() {
  group('FileWatcherState', () {
    test('应该正确创建默认实例', () {
      // Act
      const state = FileWatcherState();

      // Assert
      expect(state.isWatching, isFalse);
      expect(state.currentPath, isNull);
      expect(state.lastEvent, isNull);
    });

    test('应该正确创建带参数的实例', () {
      // Arrange
      final event = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path.md',
        timestamp: DateTime.now(),
      );

      // Act
      final state = FileWatcherState(
        isWatching: true,
        currentPath: '/test/path.md',
        lastEvent: event,
      );

      // Assert
      expect(state.isWatching, isTrue);
      expect(state.currentPath, equals('/test/path.md'));
      expect(state.lastEvent, equals(event));
    });

    test('copyWith 应该正确复制并修改属性', () {
      // Arrange
      const state = FileWatcherState(
        isWatching: true,
        currentPath: '/old/path.md',
      );

      // Act
      final newState = state.copyWith(
        currentPath: '/new/path.md',
      );

      // Assert
      expect(newState.isWatching, isTrue);
      expect(newState.currentPath, equals('/new/path.md'));
      expect(newState.lastEvent, isNull);
    });

    test('copyWith 不传参数时应该保持原值', () {
      // Arrange
      final event = FileWatchEvent(
        type: FileWatchEventType.modified,
        path: '/test/path.md',
        timestamp: DateTime.now(),
      );
      final state = FileWatcherState(
        isWatching: true,
        currentPath: '/test/path.md',
        lastEvent: event,
      );

      // Act
      final newState = state.copyWith();

      // Assert
      expect(newState.isWatching, equals(state.isWatching));
      expect(newState.currentPath, equals(state.currentPath));
      expect(newState.lastEvent, equals(state.lastEvent));
    });

    test('toString 应该返回正确的字符串表示', () {
      // Arrange
      const state = FileWatcherState(
        isWatching: true,
        currentPath: '/test/path.md',
      );

      // Act
      final result = state.toString();

      // Assert
      expect(result, contains('FileWatcherState'));
      expect(result, contains('isWatching: true'));
      expect(result, contains('/test/path.md'));
    });

    test('相同属性的状态应该相等', () {
      // Arrange
      const state1 = FileWatcherState(
        isWatching: true,
        currentPath: '/test/path.md',
      );
      const state2 = FileWatcherState(
        isWatching: true,
        currentPath: '/test/path.md',
      );

      // Assert
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('不同属性的状态应该不相等', () {
      // Arrange
      const state1 = FileWatcherState(
        isWatching: true,
        currentPath: '/test/path1.md',
      );
      const state2 = FileWatcherState(
        isWatching: true,
        currentPath: '/test/path2.md',
      );

      // Assert
      expect(state1, isNot(equals(state2)));
    });
  });

  group('fileWatcherServiceProvider', () {
    test('应该提供 FileWatcherService 实例', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final service = container.read(fileWatcherServiceProvider);

      // Assert
      expect(service, isA<FileWatcherService>());
    });

    test('应该在 dispose 时清理服务', () {
      // Arrange
      final container = ProviderContainer();
      final service = container.read(fileWatcherServiceProvider);

      // Act
      container.dispose();

      // Assert - 服务应该被 dispose
      expect(service.isWatching, isFalse);
    });
  });

  group('fileWatcherProvider', () {
    test('初始状态应该是空的', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final state = container.read(fileWatcherProvider);

      // Assert
      expect(state.isWatching, isFalse);
      expect(state.currentPath, isNull);
      expect(state.lastEvent, isNull);
    });

    test('开始监听后状态应该更新', () async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act - 使用一个不存在的路径
      await container
          .read(fileWatcherProvider.notifier)
          .startWatching('/nonexistent/test/path.md');

      // Assert
      final state = container.read(fileWatcherProvider);
      expect(state.isWatching, isTrue);
      expect(state.currentPath, equals('/nonexistent/test/path.md'));
    });

    test('停止监听后状态应该重置', () async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(fileWatcherProvider.notifier)
          .startWatching('/nonexistent/test/path.md');

      // Act
      container.read(fileWatcherProvider.notifier).stopWatching();

      // Assert
      final state = container.read(fileWatcherProvider);
      expect(state.isWatching, isFalse);
      expect(state.currentPath, isNull);
    });

    test('dispose 时不应该抛出异常', () async {
      // Arrange
      final container = ProviderContainer();

      await container
          .read(fileWatcherProvider.notifier)
          .startWatching('/nonexistent/test/path.md');

      // Act & Assert - 不应该抛出异常
      expect(() => container.dispose(), returnsNormally);
    });
  });

  group('FileWatcherNotifier 集成测试', () {
    test('服务应该被正确调用', () async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(fileWatcherServiceProvider);

      // Act
      await container
          .read(fileWatcherProvider.notifier)
          .startWatching('/test/path.md');

      // Assert - 服务状态应该反映监听状态
      // 注意：由于文件不存在，服务可能会发出 deleted 事件
      expect(container.read(fileWatcherProvider).isWatching, isTrue);
    });

    test('停止监听应该调用服务的 stopWatching', () async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(fileWatcherServiceProvider);
      await container
          .read(fileWatcherProvider.notifier)
          .startWatching('/test/path.md');

      // Act
      container.read(fileWatcherProvider.notifier).stopWatching();

      // Assert
      expect(service.isWatching, isFalse);
      expect(service.currentPath, isNull);
    });
  });
}
