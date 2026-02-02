import 'package:flutter/material.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// 加载状态 Widget。
///
/// 当文件正在加载时显示此 Widget。
/// 使用骨架屏展示加载占位效果。
///
/// 使用示例：
/// ```dart
/// LoadingState()
/// ```
class LoadingState extends StatelessWidget {
  /// 创建一个加载状态 Widget。
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('loadingStateContainer'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题骨架屏
          const SkeletonLoader(
            key: Key('loadingStateTitle'),
            type: SkeletonType.title,
            width: 250,
            height: 32,
          ),
          const SizedBox(height: 24),
          // 第一段段落骨架屏
          const SkeletonLoader(
            key: Key('loadingStateParagraph1'),
            type: SkeletonType.paragraph,
            height: 16,
          ),
          const SizedBox(height: 8),
          const SkeletonLoader(
            key: Key('loadingStateParagraph2'),
            type: SkeletonType.paragraph,
            height: 16,
          ),
          const SizedBox(height: 8),
          const SkeletonLoader(
            key: Key('loadingStateParagraph3'),
            type: SkeletonType.paragraph,
            width: 200,
            height: 16,
          ),
          const SizedBox(height: 32),
          // 代码块骨架屏
          const SkeletonLoader(
            key: Key('loadingStateCodeBlock'),
            type: SkeletonType.codeBlock,
            height: 120,
          ),
          const SizedBox(height: 32),
          // 第二段段落骨架屏
          const SkeletonLoader(
            key: Key('loadingStateParagraph4'),
            type: SkeletonType.paragraph,
            height: 16,
          ),
          const SizedBox(height: 8),
          const SkeletonLoader(
            key: Key('loadingStateParagraph5'),
            type: SkeletonType.paragraph,
            height: 16,
          ),
        ],
      ),
    );
  }
}
