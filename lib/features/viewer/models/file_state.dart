/// 文件状态枚举。
enum FileStatus {
  /// 空状态，没有打开任何文件
  empty,

  /// 加载中状态
  loading,

  /// 加载完成状态
  loaded,

  /// 错误状态
  error,
}

/// 文件状态实体类。
///
/// 用于管理当前打开的 Markdown 文件的状态信息。
///
/// 使用示例：
/// ```dart
/// final state = FileState(
///   status: FileStatus.loaded,
///   filePath: '/path/to/file.md',
///   content: '# Hello World',
/// );
/// ```
class FileState {
  /// 创建一个文件状态实例。
  const FileState({
    this.status = FileStatus.empty,
    this.filePath,
    this.content,
    this.errorMessage,
  });

  /// 文件状态
  final FileStatus status;

  /// 文件路径
  final String? filePath;

  /// 文件内容
  final String? content;

  /// 错误信息
  final String? errorMessage;

  /// 创建一个空状态。
  factory FileState.empty() {
    return const FileState(status: FileStatus.empty);
  }

  /// 创建一个加载中状态。
  factory FileState.loading(String filePath) {
    return FileState(
      status: FileStatus.loading,
      filePath: filePath,
    );
  }

  /// 创建一个加载完成状态。
  factory FileState.loaded({
    required String filePath,
    required String content,
  }) {
    return FileState(
      status: FileStatus.loaded,
      filePath: filePath,
      content: content,
    );
  }

  /// 创建一个错误状态。
  factory FileState.error({
    String? filePath,
    required String errorMessage,
  }) {
    return FileState(
      status: FileStatus.error,
      filePath: filePath,
      errorMessage: errorMessage,
    );
  }

  /// 创建一个新的 FileState 副本，可选择性地更新某些字段。
  FileState copyWith({
    FileStatus? status,
    String? filePath,
    String? content,
    String? errorMessage,
  }) {
    return FileState(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileState &&
        other.status == status &&
        other.filePath == filePath &&
        other.content == content &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(status, filePath, content, errorMessage);
  }

  @override
  String toString() {
    return 'FileState(status: $status, filePath: $filePath, '
        'content: ${content?.substring(0, content!.length > 50 ? 50 : content!.length) ?? "null"}, '
        'errorMessage: $errorMessage)';
  }
}
