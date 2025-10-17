import 'package:flutter/material.dart';

import 'BookModel.dart';

class BookManagerModel with ChangeNotifier
{

    // 依赖bookModel
      BookModel _bookModel;

    // 提供一个 setter 来更新依赖
    set bookModel(BookModel newBookModel) {
        _bookModel = newBookModel;
        // 如果需要，可以在这里调用 notifyListeners()
    }
    // 获取数据所有的ID
    List<int>? _bookIds;

    // 构造函数
    BookManagerModel(this._bookModel, {BookManagerModel? bookManagerModel}) {
        _bookIds = bookManagerModel?._bookIds ?? [];
        print("17-------------------BookManagerModel 构造函数");
    }
        //: _bookIds = bookManagerModel?._bookIds ?? [];

    // 获取所有的书
    List<Book> get books => _bookIds!.map((id) => _bookModel.getById(id)).toList();

    // 根据索引获取数据
    Book getByPosition(int position) => books[position];

    // 获取书籍的长度
    int get length => _bookIds?.length ?? 0;

    // 添加书籍
    void addFaves(Book book) 
    {
        _bookIds!.add(book.bookId);
        notifyListeners();
    }

    // 删除书籍
    void removeFaves(Book book) 
    {
        _bookIds!.remove(book.bookId);
        notifyListeners();
    }
    @override
  void dispose() {
    print("50------------BookManagerModel 被释放");
    super.dispose();
  }
}
