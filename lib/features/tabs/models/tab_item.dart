import 'package:path/path.dart' as p;

/// 标签页项实体。
///
/// 表示一个打开的文件标签页，包含文件路径、标题和活动状态。
///
/// 使用示例：
/// ```dart
/// final tab = TabItem(
///   id: 'unique-id',
///   filePath: '/path/to/file.md',
///   isActive: true,
/// );
/// print(tab.title); // 输出: file.md
/// ```
class TabItem {
  /// 创建一个标签页项。
  ///
  /// [id] 标签页的唯一标识符
  /// [filePath] 文件的完整路径
  /// [isActive] 是否为活动标签页
  const TabItem({
    required this.id,
    required this.filePath,
    this.isActive = false,
  });

  /// 标签页的唯一标识符
  final String id;

  /// 文件的完整路径
  final String filePath;

  /// 是否为活动标签页
  final bool isActive;

  /// 获取文件名作为标题。
  ///
  /// 从 [filePath] 中提取文件名（包含扩展名）。
  String get title => p.basename(filePath);

  /// 创建此标签页的副本，可选择性地更新某些字段。
  ///
  /// [id] 新的标签页 ID（如果提供）
  /// [filePath] 新的文件路径（如果提供）
  /// [isActive] 新的活动状态（如果提供）
  TabItem copyWith({
    String? id,
    String? filePath,
    bool? isActive,
  }) {
    return TabItem(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          filePath == other.filePath &&
          isActive == other.isActive;

  @override
  int get hashCode => id.hashCode ^ filePath.hashCode ^ isActive.hashCode;

  @override
  String toString() =>
      'TabItem(id: $id, filePath: $filePath, title: $title, isActive: $isActive)';
}
