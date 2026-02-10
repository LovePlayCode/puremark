import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  private var pendingFiles: [String] = []
  private var isFlutterReady = false

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
  }

  // MARK: - 文件打开事件（多种触发方式）

  /// 方式 1: 单文件打开（旧 API）
  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    handleOpenFile(filename)
    return true
  }

  /// 方式 2: 多文件打开
  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    for filename in filenames {
      handleOpenFile(filename)
    }
    NSApp.reply(toOpenOrPrint: NSApplication.DelegateReply.success)
  }

  /// 方式 3: URL 方式打开（macOS 13+ 推荐）
  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls where url.isFileURL {
      handleOpenFile(url.path)
    }
  }

  /// 统一文件处理：仅接受 .md/.markdown，去重后缓存或立即通过 Channel 发送
  func handleOpenFile(_ filename: String) {
    let url = URL(fileURLWithPath: filename)
    let ext = url.pathExtension.lowercased()
    guard ext == "md" || ext == "markdown" || ext == "mdown" || ext == "mkd" else { return }
    let path = url.path
    if pendingFiles.contains(path) { return }
    pendingFiles.append(path)

    if isFlutterReady, let channel = methodChannel {
      channel.invokeMethod("openFile", arguments: path)
      if let idx = pendingFiles.firstIndex(of: path) {
        pendingFiles.remove(at: idx)
      }
    } else {
      scheduleProcessPendingFiles()
    }
  }

  /// 由 MainFlutterWindow 在 FlutterViewController 创建后调用，建立 MethodChannel 并处理待打开文件
  func onFlutterViewControllerReady(_ controller: FlutterViewController) {
    guard methodChannel == nil else { return }
    methodChannel = FlutterMethodChannel(
      name: "com.puremark/openFile",
      binaryMessenger: controller.engine.binaryMessenger
    )
    isFlutterReady = true
    processPendingFiles()
  }

  private var processPendingFilesScheduled = false

  private func scheduleProcessPendingFiles() {
    guard !processPendingFilesScheduled, !pendingFiles.isEmpty else { return }
    processPendingFilesScheduled = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      self?.processPendingFilesScheduled = false
      self?.processPendingFiles()
    }
  }

  /// 延迟 1.5 秒后通过 Channel 发送待打开文件，确保 Flutter UI（含 FileHandlerService 订阅）已就绪
  private func processPendingFiles() {
    guard let channel = methodChannel, !pendingFiles.isEmpty else { return }
    let toSend = pendingFiles
    pendingFiles.removeAll()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      for path in toSend {
        channel.invokeMethod("openFile", arguments: path)
      }
    }
  }
}
