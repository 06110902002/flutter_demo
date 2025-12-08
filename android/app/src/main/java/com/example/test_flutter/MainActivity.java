package com.example.test_flutter;

import io.flutter.embedding.android.FlutterActivity;




import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.net.Uri;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "deep_link_channel";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        handleDeepLink(getIntent(), flutterEngine);
        registerJavaMethod();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        if (getFlutterEngine() != null) {
            handleDeepLink(intent, getFlutterEngine());
        }
    }
    String path = "/";
    private void handleDeepLink(Intent intent, FlutterEngine flutterEngine) {
        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            String dataString = intent.getDataString();
            System.out.println("原生层获取的完整深链接：" + dataString);

            Map<String, String> allParams = new HashMap<>();


            if (dataString != null && dataString.startsWith("app://flutter-route-demo")) {
                // 第一步：先对整个深链接进行 URL 解码（关键！将 %26 转为 &）
                String decodedDataString;
                try {
                    decodedDataString = Uri.decode(dataString);
                } catch (Exception e) {
                    e.printStackTrace();
                    decodedDataString = dataString; // 解码失败则使用原始字符串
                }
                System.out.println("解码后的完整深链接：" + decodedDataString);

                // 第二步：分割路径和参数部分（按 ? 分割）
                String[] urlParts = decodedDataString.split("\\?", 2);
                path = urlParts[0].replace("app://flutter-route-demo", "");

                // 第三步：解析参数部分
                if (urlParts.length == 2) {
                    String queryString = urlParts[1];
                    System.out.println("解码后的参数串：" + queryString); // 正常应为 id=2002&name=Test&age=31

                    // 第四步：按 & 分割参数（此时 %26 已转为 &，分割生效）
                    String[] paramPairs = queryString.split("&");
                    System.out.println("分割后的参数对数量：" + paramPairs.length); // 正常应为 3

                    // 第五步：遍历拆分 key=value
                    for (String pair : paramPairs) {
                        System.out.println("当前参数对：" + pair); // 正常应为 id=2002、name=Test、age=31
                        String[] keyValue = pair.split("=", 2);
                        if (keyValue.length == 2) {
                            String key = keyValue[0].trim();
                            String value = keyValue[1].trim();
                            // 可选：对 key 和 value 再次解码（兼容参数值中的编码字符）
                            try {
                                key = Uri.decode(key);
                                value = Uri.decode(value);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            allParams.put(key, value);
                        }
                    }
                }
            }

            System.out.println("原生层最终解析的所有参数：" + allParams); // 正常应为 {id=2002, name=Test, age=31}

            // 传递参数到 Flutter
            new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                    .invokeMethod("receiveDeepLink", new HashMap<String, Object>() {{
                        put("path", path);
                        put("allParams", allParams);
                    }});
        }
    }

    private void registerJavaMethod() {
         String Android_CHANNEL = "com.example.flutter_ios_communication/native";

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), Android_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getNativeString")) {
                                result.success("你好，Flutter！这是来自Android的响应。");
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }
}