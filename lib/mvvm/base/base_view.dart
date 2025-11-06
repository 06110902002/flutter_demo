import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_view_model.dart';

/// MVVM 模式中  视图基类
abstract class BaseView<VM extends BaseViewModel> extends StatelessWidget
{
    final VM Function(BuildContext) viewModelBuilder;

    String get title => '';

    /// 创建内容UI 子类需要重载
    Widget buildContent(BuildContext context, VM viewModel);

    /// 默认的无数据UI
    Widget buildEmpty(BuildContext context, VM viewModel) 
    {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.inbox, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('暂无数据'),
                    TextButton(
                        onPressed: () => viewModel.loadData(),
                        child: const Text('重新加载')
                    )
                ]
            )
        );
    }

    /// 默认的错误UI
    Widget buildError(BuildContext context, VM viewModel) 
    {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.error, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('错误：${viewModel.errorMessage ?? '未知错误'}'),
                    TextButton(
                        onPressed: () => viewModel.loadData(),
                        child: const Text('重试')
                    )
                ]
            )
        );
    }

    /// 加载中的UI
    Widget buildLoading(BuildContext context, VM viewModel) 
    {
        return const Center(child: CircularProgressIndicator());
    }

    void initState(BuildContext context, VM viewModel) 
    {
        viewModel.loadData();
    }

    /// 构造函数   传进一个页面需要的VM 进来
    const BaseView({super.key, required this.viewModelBuilder});

    @override
    Widget build(BuildContext context) 
    {
        return ChangeNotifierProvider(
            create: (context)
            {
                final vm = viewModelBuilder(context);
                WidgetsBinding.instance.addPostFrameCallback((_)
                    {
                        initState(context, vm);
                    }
                );
                return vm;
            },
            child: Consumer<VM>(
                builder: (context, viewModel, child)
                {
                    return Scaffold(
                        appBar: AppBar(title: Text(title)),
                        body: _buildBody(context, viewModel)
                    );
                }
            )
        );
    }

    Widget _buildBody(BuildContext context, VM viewModel) 
    {
        switch (viewModel.loadStatus)
        {
            case LoadStatus.loading:
                return buildLoading(context, viewModel);
            case LoadStatus.success:
                return buildContent(context, viewModel);
            case LoadStatus.empty:
                return buildEmpty(context, viewModel);
            case LoadStatus.error:
                return buildError(context, viewModel);
            default:
            return const SizedBox();
        }
    }
}
