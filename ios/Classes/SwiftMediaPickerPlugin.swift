import Flutter
import UIKit
    
public class SwiftMediaPickerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "media_picker", binaryMessenger: registrar.messenger())
    let instance = SwiftMediaPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "pickVideo":
        result("Selecting Video")
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
