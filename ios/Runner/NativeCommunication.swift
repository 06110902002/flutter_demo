//
//  NativeCommunication.swift
//  Runner
//
//  Created by rambo.liu on 2025/12/8.
//

import Foundation
import Flutter

public class NativeCommunication: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.flutter_ios_communication/native", binaryMessenger: registrar.messenger())
        let instance = NativeCommunication()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getNativeString" {
            result("你好，Flutter！这是来自iOS的响应。测试")
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
