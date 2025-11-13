import 'package:flutter/material.dart';
import 'route_config.dart';

class AppRouteParser extends RouteInformationParser<RouteConfig> {

  // 自定义深链接主机名（需与 Android/iOS 配置一致）
  static const String deepLinkHost = 'flutter-route-demo';


  @override
  Future<RouteConfig> parseRouteInformation(RouteInformation routeInfo) async {
    final uri = Uri.parse(routeInfo.location ?? RouteNames.home);
    return RouteConfig(uri.path, params: uri.queryParameters);
  }

  @override
  RouteInformation restoreRouteInformation(RouteConfig config) {
    final location = config.params?.isEmpty ?? true
        ? config.path
        : '${config.path}?${Uri(queryParameters: config.params).query}';
    return RouteInformation(location: location);
  }
}