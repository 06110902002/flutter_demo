import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BookButton.dart';
import 'BookModel.dart';

class BookItem extends StatelessWidget
{

    final int id;

    BookItem({
        Key? key,
        required this.id
    }) : super(key: key);

    @override
    Widget build(BuildContext context)
    {

        var bookModel = Provider.of<BookModel>(context);
        var book = bookModel.getById(id);

        return ListTile(
            leading: CircleAvatar(
                child: Text("${book.bookId}")
            ),
            title: Text("${book.bookName}",
                style: TextStyle(
                    color: Colors.black87
                )
            ),
          trailing: Container( // 1. Wrap the trailing widget (BookButton) with a Container
            width: 80,         // 2. Set the width of the Container
            // height: double.infinity, // Optional: if you want it to fill the ListTile's height
            color: Colors.yellow, // 3. Set the background color of the Container
            // padding: const EdgeInsets.all(4.0), // Optional: Add padding around BookButton if needed
            alignment: Alignment.center, // Optional: Center BookButton within the yellow container
            child: BookButton(book: book),
          ),
        );
    }
}
