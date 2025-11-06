import 'package:flutter/material.dart';
import '../base/base_view.dart';
import '../viewModel/user_list_view_model.dart';
import '../model/user.dart';

class UserListPage extends BaseView<UserListViewModel>
{
    UserListPage({super.key})
        : super(viewModelBuilder: (context) => UserListViewModel());

    @override
    String get title => '用户列表';

    @override
    Widget buildContent(BuildContext context, UserListViewModel viewModel) 
    {
        return RefreshIndicator(
            onRefresh: () async => viewModel.refreshUsers(),
            child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.users.length,
                itemBuilder: (context, index)
                {
                    User user = viewModel.users[index];
                    return _buildUserItem(context, user, viewModel);
                }
            )
        );
    }

    Widget _buildUserItem(
        BuildContext context,
        User user,
        UserListViewModel viewModel
    ) 
    {
        return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                    radius: 30,
                    child: Text(
                        user.name.substring(0, 1),
                        style: const TextStyle(fontSize: 20)
                    )
                ),
                title: Text(
                    user.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const SizedBox(height: 8),
                        Text('邮箱：${user.email}'),
                        Text('电话：${user.phone}')
                    ]
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => viewModel.goToDetail(context, user)
            )
        );
    }
}
