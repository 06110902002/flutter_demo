import 'package:flutter/material.dart';

// Widget for the content of each page in the PageView
class ContentPage extends StatelessWidget
{
    final String pageText;
    const ContentPage({Key? key, required this.pageText}) : super(key: key);

    @override Widget build(BuildContext context)
    {
        // This widget should return only the content for a single page
        // For example, a colored container with some text
        return Container(
            // For demonstration, use a different color for each page based on its text
            // You can parse pageText to int if it's always a number
            color: Colors.primaries[int.tryParse(pageText) ?? 0 % Colors.primaries.length],
            child: Center(
                child: Text(
                    'Page: $pageText',
                    style: TextStyle(fontSize: 30, color: Colors.white)
                )
            )
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

class _PageState extends State<Page>
{
    final PageController _pageController = PageController(); // Optional: for controlling the PageView

    @override
    Widget build(BuildContext context)
    {
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
        _pageController.dispose(); // Dispose the controller
        super.dispose();
    }
}
