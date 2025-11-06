import 'package:flutter/widgets.dart';
import '../base/base_view_model.dart';
import '../model/user.dart';
import '../model/user_repository.dart';
import '../view/user_detail_page.dart';

class UserListViewModel extends BaseViewModel
{
    final UserRepository _repository = UserRepository();
    List<User> _users = [];

    List<User> get users => _users;

    @override
    Future<void> fetchData() async
    {
        _users = [];
        try
        {
            List<User> data = await _repository.getUsers();
            if (data.isEmpty) 
            {
                updateStatus(LoadStatus.empty);
            }
            else 
            {
                _users = data;
                updateStatus(LoadStatus.success);
            }
        }
        catch (e)
        {
            updateStatus(LoadStatus.error, errorMsg: e.toString());
        }
    }

    Future<void> refreshUsers() async
    {
        updateStatus(LoadStatus.loading);
        await fetchData();
    }

    void goToDetail(BuildContext context, User user) 
    {
        if (context.mounted) 
        {
            navigateTo(context, UserDetailPage(user: user));
        }
    }
}
