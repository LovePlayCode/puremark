import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    if let appDelegate = NSApp.delegate as? AppDelegate {
      appDelegate.onFlutterViewControllerReady(flutterViewController)
    }

    // 在 FlutterView 上方添加透明拖放层
    let dropView = FileDropView()
    dropView.autoresizingMask = [.width, .height]
    dropView.frame = flutterViewController.view.bounds
    flutterViewController.view.addSubview(dropView)

    super.awakeFromNib()
  }
}

/// 透明拖放视图，接受 Markdown 文件拖入后转发给 AppDelegate 处理。
/// 仅拦截拖放事件，其余鼠标/键盘事件透传到下层 FlutterView。
class FileDropView: NSView {
  private static let mdExtensions: Set<String> = ["md", "markdown", "mdown", "mkd"]

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    registerForDraggedTypes([.fileURL])
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    registerForDraggedTypes([.fileURL])
  }

  // 不绘制任何内容，完全透明
  override var isOpaque: Bool { false }
  override func draw(_ dirtyRect: NSRect) {}

  // 让非拖放事件透传到下层 FlutterView
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }

  // MARK: - NSDraggingDestination

  override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
    if hasMarkdownFiles(sender) {
      return .copy
    }
    return []
  }

  override func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
    if hasMarkdownFiles(sender) {
      return .copy
    }
    return []
  }

  override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
    guard let appDelegate = NSApp.delegate as? AppDelegate else { return false }
    guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [
      .urlReadingFileURLsOnly: true
    ]) as? [URL] else { return false }

    var handled = false
    for url in urls {
      if FileDropView.mdExtensions.contains(url.pathExtension.lowercased()) {
        appDelegate.handleOpenFile(url.path)
        handled = true
      }
    }
    return handled
  }

  private func hasMarkdownFiles(_ sender: any NSDraggingInfo) -> Bool {
    guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [
      .urlReadingFileURLsOnly: true
    ]) as? [URL] else { return false }
    return urls.contains { FileDropView.mdExtensions.contains($0.pathExtension.lowercased()) }
  }
}
