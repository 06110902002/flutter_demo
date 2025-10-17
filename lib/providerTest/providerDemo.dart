import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../SPUtil.dart';

// 用户模型
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

// 商品模型
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});
}

// 用户仓库 - 管理用户登录状态
class UserRepository with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  //bool get isLoggedIn => _currentUser != null;
  Future<bool?> isLoggedIn() async {
    final spUtil = await SPUtil.getInstance();
    return spUtil.getBool(isLogin);
  }
  final String isLogin = 'isLogin';

  UserRepository() {}



  Future<void> login(User user) async {
    _currentUser = user;
    final spUtil = await SPUtil.getInstance();
    spUtil.setBool(isLogin, _currentUser != null);
    print('👤 用户登录: ${user.name}');
    notifyListeners();
  }

  void logout() async {
    print('🚪 用户登出: ${_currentUser?.name}');
    _currentUser = null;
    final spUtil = await SPUtil.getInstance();
    spUtil.setBool(isLogin, _currentUser != null);
    notifyListeners();
  }

  @override
  void dispose() {
    print('🗑️ UserRepository 已销毁');
    super.dispose();
  }
}

// 购物车 - 依赖于用户信息
class ShoppingCart with ChangeNotifier {
  String? _userId;
  final List<Product> _items = [];

  String? get userId => _userId;
  List<Product> get items => _items;
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price);

  // 设置用户ID（当用户登录/切换时调用）
  void setUser(String? userId) {
    _userId = userId;
    if (userId == null) {
      _items.clear(); // 用户登出时清空购物车
    }
    print('🛒 购物车用户更新: $userId, 商品数量: $_items');
    notifyListeners();
  }

  void addItem(Product product) {
    _items.add(product);
    print('➕ 添加商品: ${product.name}');
    notifyListeners();
  }

  void removeItem(Product product) {
    _items.remove(product);
    print('➖ 移除商品: ${product.name}');
    notifyListeners();
  }

  void clear() {
    _items.clear();
    print('🧹 清空购物车');
    notifyListeners();
  }

  @override
  void dispose() {
    print('🗑️ ShoppingCart 已销毁 - 用户: $_userId');
    super.dispose();
  }
}

// 登录页面
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 模拟用户登录
                final user = User(
                  id: 'user_123',
                  name: '张三',
                  email: 'zhangsan@example.com',
                );
                context.read<UserRepository>().login(user);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('登录为 张三'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 模拟另一个用户登录
                final user = User(
                  id: 'user_456',
                  name: '李四',
                  email: 'lisi@example.com',
                );
                context.read<UserRepository>().login(user);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('登录为 李四'),
            ),
          ],
        ),
      ),
    );
  }
}

// 首页
class HomePage extends StatelessWidget {
  final List<Product> availableProducts = [
    Product(id: '1', name: 'iPhone 15', price: 5999),
    Product(id: '2', name: 'MacBook Pro', price: 12999),
    Product(id: '3', name: 'AirPods', price: 1299),
    Product(id: '4', name: 'iPad', price: 3299),
  ];

  @override
  Widget build(BuildContext context) {
    final userRepo = context.watch<UserRepository>();
    final shoppingCart = context.watch<ShoppingCart>();

    return Scaffold(
      appBar: AppBar(
        title: Text('购物商城'),
        actions: [
          // 购物车图标
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage()),
                  );
                },
              ),
              if (shoppingCart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${shoppingCart.itemCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // 用户信息
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('用户信息'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('姓名: ${userRepo.currentUser?.name}'),
                      Text('邮箱: ${userRepo.currentUser?.email}'),
                      Text('用户ID: ${userRepo.currentUser?.id}'),
                      SizedBox(height: 10),
                      Text('购物车商品数: ${shoppingCart.itemCount}'),
                      Text('购物车用户: ${shoppingCart.userId}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        userRepo.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('退出登录'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: availableProducts.length,
        itemBuilder: (context, index) {
          final product = availableProducts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(product.name[0]),
            ),
            title: Text(product.name),
            subtitle: Text('¥${product.price}'),
            trailing: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                shoppingCart.addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已添加 ${product.name} 到购物车'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// 购物车页面
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shoppingCart = context.watch<ShoppingCart>();
    final userRepo = context.watch<UserRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text('购物车'),
        actions: [
          if (shoppingCart.itemCount > 0)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                shoppingCart.clear();
              },
              tooltip: '清空购物车',
            ),
        ],
      ),
      body: shoppingCart.itemCount == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('购物车为空'),
            SizedBox(height: 8),
            Text(
              '当前用户: ${userRepo.currentUser?.name ?? "未登录"}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '总计:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¥${shoppingCart.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shoppingCart.items.length,
              itemBuilder: (context, index) {
                final product = shoppingCart.items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(product.name[0]),
                  ),
                  title: Text(product.name),
                  subtitle: Text('¥${product.price}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      shoppingCart.removeItem(product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 主应用
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 首先提供 UserRepository
        ChangeNotifierProvider<UserRepository>(
          create: (context) => UserRepository(),
        ),
        // 然后提供依赖于 UserRepository 的 ShoppingCart
        ChangeNotifierProxyProvider<UserRepository, ShoppingCart>(
          create: (context) {
            // 初次创建时，userRepository.currentUser 可能为 null
            final userRepo = context.read<UserRepository>();
            print('🛒 创建 ShoppingCart，用户: ${userRepo.currentUser?.id}');
            return ShoppingCart();
          },
          update: (context, userRepo, previousCart) {
            // 当 UserRepository 变化时（用户登录/登出），更新 ShoppingCart
            print('🔄 更新 ShoppingCart，用户: ${userRepo.currentUser?.id}');

            // previousCart 是上一次 create 或 update 返回的实例
            final cart = previousCart!;

            // 根据用户状态更新购物车
            if (userRepo.currentUser != null) {
              cart.setUser(userRepo.currentUser!.id);
            } else {
              cart.setUser(null); // 用户登出时清空购物车
            }

            return cart;
          },
        ),
      ],
      // --- 🔴 以下是被修改的关键部分 ---
      // 使用 MultiProvider 的 builder 属性
      builder: (context, child) {
        // 这里的 `context` 是一个新的 BuildContext，
        // 它可以访问到上面 `providers` 列表中定义的所有 Provider。
        return MaterialApp(
          title: 'ChangeNotifierProxyProvider 示例',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: FutureBuilder<bool?>(
            // 现在，这个 context 可以成功找到 UserRepository 了！
            future: context.read<UserRepository>().isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final isLoggedIn = snapshot.data ?? false;
              return isLoggedIn ? HomePage() : LoginPage();
            },
          ),
          routes: {
            '/cart': (context) => CartPage(),
          },
        );
      },
    );
  }
}


///这个例子模拟一个购物车场景，其中购物车依赖于用户信息。
void main() {
  runApp(MyApp());
}