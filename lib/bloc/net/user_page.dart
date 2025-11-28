///第六步：创建 View（UI 展示）
// lib/user/view/user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserPage extends StatelessWidget
{
    const UserPage({super.key});

    @override
    Widget build(BuildContext context) 
    {
        return Scaffold(
            appBar: AppBar(title: const Text('Bloc Async Example')),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // 根据状态显示不同内容
                        BlocBuilder<UserBloc, UserState>(
                            builder: (context, state)
                            {
                                if (state is UserInitial) 
                                {
                                    return const Text('Press button to load user');
                                }
                                else if (state is UserLoading) 
                                {
                                    return const CircularProgressIndicator();
                                }
                                else if (state is UserLoaded) 
                                {
                                    return Column(
                                        children: [
                                            Text('Name: ${state.user.name}',
                                                style: const TextStyle(fontSize: 18)),
                                            const SizedBox(height: 8),
                                            Text('Email: ${state.user.email}')
                                        ]
                                    );
                                }
                                else if (state is UserError) 
                                {
                                    return Text(
                                        'Error: ${state.message}',
                                        style: const TextStyle(color: Colors.red)
                                    );
                                }
                                else 
                                {
                                    return const SizedBox(); // fallback
                                }
                            }
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                            onPressed: ()
                            {
                                context.read<UserBloc>().add(FetchUser(2));
                            },
                            child: const Text('Load User')
                        )
                    ]
                )
            )
        );
    }
}
