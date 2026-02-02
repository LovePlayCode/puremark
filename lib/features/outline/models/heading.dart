/// 文档标题实体类。
///
/// 用于表示 Markdown 文档中的标题（H1, H2, H3）。
///
/// 使用示例：
/// ```dart
/// final heading = Heading(
///   id: 'heading-1',
///   text: '简介',
///   level: 1,
/// );
/// ```
class Heading {
  /// 创建一个标题实例。
  const Heading({
    required this.id,
    required this.text,
    required this.level,
  });

  /// 标题唯一标识符
  final String id;

  /// 标题文本内容
  final String text;

  /// 标题级别（1, 2, 3 对应 H1, H2, H3）
  final int level;

  /// 获取标题的缩进值（像素）。
  ///
  /// H1: 0px, H2: 16px, H3: 32px
  double get indent {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 16;
      case 3:
        return 32;
      default:
        return 0;
    }
  }

  /// 创建一个新的 Heading 副本，可选择性地更新某些字段。
  Heading copyWith({
    String? id,
    String? text,
    int? level,
  }) {
    return Heading(
      id: id ?? this.id,
      text: text ?? this.text,
      level: level ?? this.level,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Heading &&
        other.id == id &&
        other.text == text &&
        other.level == level;
  }

  @override
  int get hashCode {
    return Object.hash(id, text, level);
  }

  @override
  String toString() {
    return 'Heading(id: $id, text: $text, level: $level)';
  }
}
