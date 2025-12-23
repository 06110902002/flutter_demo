import 'package:flutter/material.dart';

import '../../easy_pull_fresh/src/painter/paths_painter.dart';

/// List item.
class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.icon,
    this.iconPaths,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.divider = false,
  });

  final String title;

  final String? subtitle;

  final Widget? leading;

  final IconData? icon;

  final List<String>? iconPaths;

  final Widget? trailing;

  final bool selected;

  final VoidCallback? onTap;

  final bool divider;

  Widget? get _leading {
    if (leading != null) {
      return leading!;
    }
    if (icon != null) {
      return Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        alignment: Alignment.center,
        child: Icon(icon!, color: Colors.grey),
      );
    }
    if (iconPaths != null) {
      return Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        alignment: Alignment.center,
        child: PathsPaint(
          paths: iconPaths!,
          colors: List.filled(iconPaths!.length, Colors.grey),
          width: 24,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          leading: _leading,
          trailing: trailing,
          selected: selected,
          onTap: onTap,
        ),
        if (divider)
          Padding(
            padding: EdgeInsets.only(
              left: leading == null && icon == null ? 16 : 72,
              right: 16,
            ),
            child: const Divider(thickness: 1, height: 1),
          ),
      ],
    );
  }
}
