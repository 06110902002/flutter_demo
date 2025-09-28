// 数据模型：代表一个信息块
import 'package:flutter/material.dart';


class InfoCard {
  final String title;
  final String content;
  final Color backgroundColor;
  final int type;

  InfoCard(this.title, this.content, this.type,[this.backgroundColor = Colors.blue]);

  int getType() {
    return type;
  }
}