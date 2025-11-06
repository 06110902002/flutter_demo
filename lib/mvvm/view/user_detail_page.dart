import 'package:flutter/material.dart';
import '../model/user.dart';

class UserDetailPage extends StatelessWidget
{
    final User user;

    const UserDetailPage({super.key, required this.user});

    @override
    Widget build(BuildContext context) 
    {
        return Scaffold(
            appBar: AppBar(title: const Text('用户详情')),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _buildDetailItem('ID', user.id.toString()),
                        _buildDetailItem('姓名', user.name),
                        _buildDetailItem('用户名', user.username),
                        _buildDetailItem('邮箱', user.email),
                        _buildDetailItem('电话', user.phone),
                        _buildDetailItem('网站', user.website),
                        const SizedBox(height: 30),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('返回列表')
                        )
                    ]
                )
            )
        );
    }

    Widget _buildDetailItem(String label, String value) 
    {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        label,
                        style: const TextStyle(color: Colors.grey, fontSize: 14)
                    ),
                    const SizedBox(height: 8),
                    Text(
                        value,
                        style: const TextStyle(fontSize: 16)
                    ),
                    const Divider(height: 1)
                ]
            )
        );
    }
}
