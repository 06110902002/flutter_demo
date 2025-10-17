import 'package:flutter/material.dart';

/// 使用组合组件的方式实现自定义控件
class GradientButton extends StatelessWidget
{
    const GradientButton({Key? key,
        this.colors,
        this.width,
        this.height,
        this.onPressed,
        this.borderRadius,
        required this.child
    }) : super(key: key);

    // 渐变色数组
    final List<Color>? colors;

    // 按钮宽高
    final double? width;
    final double? height;
    final BorderRadius? borderRadius;

    //点击回调
    final GestureTapCallback? onPressed;

    final Widget child;

    @override
    Widget build(BuildContext context)
    {
        ThemeData theme = Theme.of(context);

        //确保colors数组不空
        List<Color> _colors =
            colors ?? [theme.primaryColor, theme.primaryColorDark];

        return DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: _colors),
                borderRadius: borderRadius
            //border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            ),
            child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                    splashColor: _colors.last,
                    highlightColor: Colors.transparent,
                    borderRadius: borderRadius,
                    onTap: onPressed,
                    child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(height: height, width: width),
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DefaultTextStyle(
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    child: child
                                )
                            )
                        )
                    )
                )
            )
        );
    }
}

class GradientButtonRoute extends StatefulWidget
{
    const GradientButtonRoute({Key? key}) : super(key: key);

    @override
    _GradientButtonRouteState createState() => _GradientButtonRouteState();
}

class _GradientButtonRouteState extends State<GradientButtonRoute>
{
    @override
    Widget build(BuildContext context) 
    {
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                GradientButton(
                    colors: const[Colors.orange, Colors.red],
                    height: 50.0,
                    width: 100,
                    child: const Text("Submit"),
                    onPressed: onTap
                ),
                GradientButton(
                    height: 50.0,
                    colors: [Colors.lightGreen, Colors.green.shade700],
                    child: const Text("Submit"),
                    onPressed: onTap
                ),
                GradientButton(
                    height: 50.0,
                    //borderRadius: const BorderRadius.all(Radius.circular(5)),
                    colors: [Colors.lightBlue.shade300, Colors.blueAccent],
                    child: const Text("Submit"),
                    onPressed: onTap
                )
            ]
        );
    }
    onTap() 
    {
        print("button click");
    }
}
