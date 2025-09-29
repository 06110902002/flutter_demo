import 'package:flutter/material.dart';

// Widget for the content of each page in the PageView
class ContentPage extends StatefulWidget { // 1. Convert to StatefulWidget
    final String pageText;
    const ContentPage({Key? key, required this.pageText}) : super(key: key);

    @override
    _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage>
    with AutomaticKeepAliveClientMixin<ContentPage> { // 2. Mixin AutomaticKeepAliveClientMixin

    // Optional: If you need to manage the TextField's controller explicitly
    // late TextEditingController _textController;// @override
    // void initState() {
    //   super.initState();
    //   // If you were creating the controller here, make sure to dispose it.
    //   // _textController = TextEditingController();
    //   print("ContentPage ${widget.pageText}: initState");
    // }

    // @override
    // void dispose() {
    //   // _textController.dispose();
    //   print("ContentPage ${widget.pageText}: dispose");
    //   super.dispose();
    // }

    @override
    bool get wantKeepAlive => true; // 3. Override wantKeepAlive and return true

    @override
    Widget build(BuildContext context) {
        super.build(context); // 4. MUST call super.build(context)

        print("41--------Building ContentPage: ${widget.pageText}");

        return Container(
            // For demonstration, use a different color for each page based on its text
            color: Colors.primaries[int.tryParse(widget.pageText) ?? 0 % Colors.primaries.length],
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            'Page: ${widget.pageText}',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                            child: TextField(
                                // controller: _textController, // Optional: if you manage the controller
                                // key: PageStorageKey('textField_${widget.pageText}'), // See Alternative below
                                obscureText: false, // Changed from true for easier testing
                                decoration: InputDecoration(
                                    hintText: "Enter text...",
                                    prefixIcon: Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(Icons.edit, size: 18, color: Colors.white),
                                    ),
                                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                    hintStyle: TextStyle(color: Colors.white70),
                                ),
                                style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}


// Your main Page widget that will now host the PageView
class Page extends StatefulWidget
{
    final String text; // This 'text' might be for the title of the whole screen
    const Page({Key? key, required this.text}) : super(key: key);

    @override
    _PageState createState() => _PageState();
}

class _PageState extends State<Page> with AutomaticKeepAliveClientMixin
{
    final PageController _pageController = PageController(); // Optional: for controlling the PageView

    @override
    Widget build(BuildContext context)
    {
        super.build(context); // 必须调用 wantKeepAlive才能生效

        print("44-----build for PageView container: ${widget.text}");

        var pageViewChildren = <Widget>[];
        // Generate 6 ContentPage widgets for the PageView
        for (int i = 0; i < 6; ++i)
        {
            pageViewChildren.add(ContentPage(pageText: '$i'));
        }

        return Scaffold( // Page should return a Scaffold if it's a screen
            appBar: AppBar(
                title: Text(
                    widget.text, // Use the passed text for the AppBar title
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        // color: Colors.green, // Consider using theme colors
                        fontFamily: 'Roboto'),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                )
            ),
            body: PageView(

                controller: _pageController, // Optional
                // scrollDirection: Axis.vertical, // Uncomment if you want vertical scrolling
                children: pageViewChildren
            ),
            // Optional: Add page indicators or navigation
            bottomNavigationBar: BottomAppBar(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: ()
                            {
                                if (_pageController.hasClients && _pageController.page != 0)
                                {
                                    _pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut
                                    );
                                }
                            }
                        ),
                        IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: ()
                            {
                                if (_pageController.hasClients)
                                {
                                    _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut
                                    );
                                }
                            }
                        )
                    ]
                )
            )
        );
    }

    @override
    void dispose()
    {
        print("117----------------dispose");
        _pageController.dispose(); // Dispose the controller
        super.dispose();
    }

    /// 当 keepAlive 标记为 false 时，如果列表项滑出加载区域时，列表组件将会被销毁。
    /// 当 keepAlive 标记为 true 时，当列表项滑出加载区域后，Viewport
    /// 会将列表组件缓存起来；当列表项进入加载区域时，Viewport 从先从缓存中查找是否已经缓存，如果有则直接复用，如果没有则重新创建列表项。
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
