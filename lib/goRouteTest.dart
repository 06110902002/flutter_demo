import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// 认证状态管理
class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isLoggedIn = false;
    notifyListeners();
  }
}

// 应用状态管理
class AppState extends ChangeNotifier {
  bool _showSplash = true;
  bool get showSplash => _showSplash;

  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  DateTime? _lastBackPressTime;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // 检查是否是首次启动
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // 初始化认证状态
    await authService.checkLoginStatus();

    _isInitialized = true;
    notifyListeners();

    print('App initialized - First launch: $_isFirstLaunch, Logged in: ${authService.isLoggedIn}');

    // 等待2秒后隐藏启动页
    await Future.delayed(const Duration(seconds: 2));
    _showSplash = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    _isFirstLaunch = false;
    notifyListeners();
    print('Onboarding completed - isFirstLaunch set to false');
  }

  bool shouldExitApp() {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      return false;
    }
    return true;
  }
}

final authService = AuthService();
final appState = AppState();

final GoRouter _router = GoRouter(
  refreshListenable: appState,
  redirect: (context, state) {
    final currentPath = state.uri.path;

    print('Redirect: $currentPath, showSplash: ${appState.showSplash}, isFirstLaunch: ${appState.isFirstLaunch}, isInitialized: ${appState.isInitialized}');

    // 如果应用未初始化或还在显示启动页，停留在启动页
    if (!appState.isInitialized || appState.showSplash) {
      if (currentPath != '/splash') {
        return '/splash';
      }
      return null;
    }

    // 应用已初始化且不在启动页，开始正常路由逻辑
    final isLoggedIn = authService.isLoggedIn;
    final isOnboarding = currentPath == '/onboarding';
    final isLogin = currentPath == '/login';
    final isSplash = currentPath == '/splash';

    // 如果还在启动页但应该跳转，进行重定向
    if (isSplash && !appState.showSplash) {
      if (appState.isFirstLaunch) {
        return '/onboarding';
      } else if (!isLoggedIn) {
        return '/login';
      } else {
        return '/';
      }
    }

    // 首次启动必须显示引导页
    if (appState.isFirstLaunch && !isOnboarding) {
      return '/onboarding';
    }

    // 非首次启动的登录检查
    if (!appState.isFirstLaunch) {
      // 未登录且不在登录页，重定向到登录页
      if (!isLoggedIn && !isLogin) {
        return '/login';
      }

      // 已登录但在登录页，重定向到首页
      if (isLoggedIn && isLogin) {
        return '/';
      }
    }

    return null;
  },
  routes: [
    // 启动页
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // 引导页
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // 登录页
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // 首页
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // 详情页
        GoRoute(
          path: 'details',
          name: 'details',
          builder: (context, state) => const DetailsScreen(),
        ),

        // 个人资料页
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await appState.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRoute Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}

// 启动页
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 20),
            Text(
              'My App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// 引导页
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': '欢迎使用',
      'description': '发现应用的强大功能',
      'image': '🎉',
    },
    {
      'title': '简单易用',
      'description': '直观的界面设计，轻松上手',
      'image': '👆',
    },
    {
      'title': '开始体验',
      'description': '立即开始您的旅程',
      'image': '🚀',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('跳过'),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data['image']!,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          data['title']!,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data['description']!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 指示器和按钮
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 页面指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.blue
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 下一步/开始按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _currentPage == _onboardingData.length - 1
                          ? _completeOnboarding
                          : _nextPage,
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? '开始使用'
                            : '下一步',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _completeOnboarding() async {
    print('Onboarding completed - Current login status: ${authService.isLoggedIn}');

    // 标记引导页已完成
    await appState.completeOnboarding();

    // 根据登录状态跳转
    if (authService.isLoggedIn) {
      print('User is logged in, navigating to home');
      context.go('/');
    } else {
      print('User is not logged in, navigating to login');
      context.go('/login');
    }
  }
}

// 登录页
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '欢迎回来',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '请登录您的账户',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            TextField(
              decoration: InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await authService.login();
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('登录'),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                authService.login();
                context.go('/');
              },
              child: const Text('跳过登录（演示）'),
            ),
          ],
        ),
      ),
    );
  }
}

// 首页
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onWillPop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('首页'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
            ),
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            return _onWillPop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '欢迎回来！',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '您已成功登录应用',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        context,
                        '详情页面',
                        Icons.info,
                        Colors.blue,
                            () => context.go('/details'),
                      ),
                      _buildFeatureCard(
                        context,
                        '个人资料',
                        Icons.person,
                        Colors.green,
                            () => context.go('/profile'),
                      ),
                      _buildFeatureCard(
                        context,
                        '设置',
                        Icons.settings,
                        Colors.orange,
                            () {},
                      ),
                      _buildFeatureCard(
                        context,
                        '帮助',
                        Icons.help,
                        Colors.purple,
                            () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('再按一次退出应用'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }
}

// 详情页
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('详情页面')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              '这是详情页面',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '点击返回按钮可以回到首页',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// 个人资料页
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 20),
            Text(
              '用户名',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'user@example.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑资料'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('帮助与支持'),
              onTap: () {},
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await authService.logout();
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('退出登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}