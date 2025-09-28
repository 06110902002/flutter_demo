import 'package:flutter/material.dart' hide Page;
import 'package:test_flutter/LayoutTest.dart';

import 'AnimatedListRoute.dart';
import 'ClipTestRoute.dart';
import 'FlexLayoutTestRoute.dart';
import 'InfiniteListView.dart';
import 'Layout1.dart';
import 'Login.dart';
import 'LoginPage.dart';
import 'ResponsiveColumn.dart';
import 'ScaffoldRoute.dart';
import 'SingleChildScrollViewTestRoute.dart';
import 'WrapAndFlowLayout.dart';
import 'Page.dart';



void main()
{

    // runApp(const Login());
  // runApp(MaterialApp(
  //   home: LoginPage(),
  //   debugShowCheckedModeBanner: false,
  // ));

  // runApp(MaterialApp(
  //   home:FlexLayoutTestRoute(),
  // ));

  // runApp(Wrapandflowlayout());


  // final List<Widget> cards = [
  //   Text(" I am Jack "),
  //   Text(" I am Jack helo"),
  //   Text(" I am Jack "),
  //   Text(" I am Jack this is test text")
  // ];
  // runApp(ResponsiveColumn(children:cards));

  //runApp(ClipTestRoute());

  // runApp(MaterialApp(
  //   home:ScaffoldRoute()
  // ));

  //runApp(SingleChildScrollViewTestRoute());

  //runApp(InfiniteListView());

  // runApp(AnimatedListRoute());

  // runApp(Page(text:"test23"));

  runApp(
    MaterialApp(
      title: 'Flutter Demo App',
      // Page now acts as a screen containing the PageView
      home: Page(text: "My PageView Screen"),
    ),
  );
}

// 一个简单的Widget示例
class MyApp2 extends StatelessWidget
{
    const MyApp2({super.key});

    @override
    Widget build(BuildContext context) 
    {

        return MaterialApp(
            title: 'Flutter Demo',
            home: Scaffold(
                appBar: AppBar(
                    title: Text(
                        'Hello Flutter this is first demo',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                    )
                ),

                body: Padding(
                    padding: EdgeInsets.only(left: 10), // 只添加左边距 10
                    child: Align(
                        alignment: Alignment(-1.0, -1.0),
                        child: Text('Hello World!'),
                    ),

                ),
            )
        );
    }
}












class MyApp extends StatelessWidget
{
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) 
    {
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                // This is the theme of your application.
                //
                // TRY THIS: Try running your application with "flutter run". You'll see
                // the application has a purple toolbar. Then, without quitting the app,
                // try changing the seedColor in the colorScheme below to Colors.green
                // and then invoke "hot reload" (save your changes or press the "hot
                // reload" button in a Flutter-supported IDE, or press "r" if you used
                // the command line to start the app).
                //
                // Notice that the counter didn't reset back to zero; the application
                // state is not lost during the reload. To reset the state, use hot
                // restart instead.
                //
                // This works for code too, not just values: Most code changes can be
                // tested with just a hot reload.
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
            ),
            home: const MyHomePage(title: 'Flutter Demo Home Page')
        );
    }
}

class MyHomePage extends StatefulWidget
{
    const MyHomePage({super.key, required this.title});

    // This widget is the home page of your application. It is stateful, meaning
    // that it has a State object (defined below) that contains fields that affect
    // how it looks.

    // This class is the configuration for the state. It holds the values (in this
    // case the title) provided by the parent (in this case the App widget) and
    // used by the build method of the State. Fields in a Widget subclass are
    // always marked "final".

    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
    int _counter = 0;

    void _incrementCounter() 
    {
        setState(()
            {
                // This call to setState tells the Flutter framework that something has
                // changed in this State, which causes it to rerun the build method below
                // so that the display can reflect the updated values. If we changed
                // _counter without calling setState(), then the build method would not be
                // called again, and so nothing would appear to happen.
                _counter++;
            }
        );
    }

    @override
    Widget build(BuildContext context) 
    {
        // This method is rerun every time setState is called, for instance as done
        // by the _incrementCounter method above.
        //
        // The Flutter framework has been optimized to make rerunning build methods
        // fast, so that you can just rebuild anything that needs updating rather
        // than having to individually change instances of widgets.
        return Scaffold(
            appBar: AppBar(
                // TRY THIS: Try changing the color here to a specific color (to
                // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
                // change color while the other colors stay the same.
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(widget.title)
            ),
            body: Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Column(
                    // Column is also a layout widget. It takes a list of children and
                    // arranges them vertically. By default, it sizes itself to fit its
                    // children horizontally, and tries to be as tall as its parent.
                    //
                    // Column has various properties to control how it sizes itself and
                    // how it positions its children. Here we use mainAxisAlignment to
                    // center the children vertically; the main axis here is the vertical
                    // axis because Columns are vertical (the cross axis would be
                    // horizontal).
                    //
                    // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
                    // action in the IDE, or press "p" in the console), to see the
                    // wireframe for each widget.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        const Text('You have pushed the button this many times223:'),
                        Text(
                            '$_counter',
                            style: Theme.of(context).textTheme.headlineMedium
                        )
                    ]
                )
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.add)
            ) // This trailing comma makes auto-formatting nicer for build methods.
        );
    }
}
