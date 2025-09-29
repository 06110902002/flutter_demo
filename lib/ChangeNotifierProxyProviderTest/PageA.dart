import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BookItem.dart';
import 'BookModel.dart';

class PageA extends StatelessWidget
{
    @override
    Widget build(BuildContext context) 
    {

        var bookModel = Provider.of<BookModel>(context);

        return Scaffold(
            appBar: AppBar(
                title: Text("书籍列表")
            ),
          body: ListView.separated(
            itemCount: bookModel.length,
            itemBuilder: (BuildContext context, int index) {
              // Wrap BookItem with a SizedBox to control its height
              return SizedBox(
                height: 70.0,
                child: BookItem(id: index + 1),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              // Return the widget you want as a separator
              return const Divider(
                height: 1, // Height of the divider line itself
                thickness: 1, // Thickness of the line
                color: Colors.grey, // Color of the divider
                indent: 16, // Optional: indent from the left
                endIndent: 16, // Optional: indent from the right
              );
            },
          )
        );
    }
}
