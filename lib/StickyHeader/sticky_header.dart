/// FileName sticky_header
///
/// @Author 505691285qq.com
/// @Date 2025/12/16 16:28
///
/// @Description TODO
///
///

/// 使用三方库版本  需要引入  #flutter_sticky_header: ^0.8.0 # 检查最新版本  使用第三方库的版本
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sticky Header Demo',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Sticky Group Headers')),
//         body: StickyGroupedListView(),
//       ),
//     );
//   }
// }
//
// class StickyGroupedListView extends StatelessWidget {
//   final Map<String, List<String>> groups = {
//     '水果': ['苹果', '香蕉', '橙子', '葡萄', '西瓜'],
//     '蔬菜': ['胡萝卜', '白菜', '菠菜', '黄瓜', '番茄'],
//     '肉类': ['牛肉', '猪肉', '鸡肉', '羊肉', '鱼肉'],
//     '零食': ['薯片', '巧克力', '饼干', '糖果', '坚果'],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: groups.entries.map((entry) {
//         return SliverStickyHeader(
//           header: Container(
//             height: 56.0,
//             color: Colors.blue.shade700,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             alignment: Alignment.centerLeft,
//             child: Text(
//               entry.key,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//           ),
//           sliver: SliverList(
//             delegate: SliverChildBuilderDelegate((context, index) {
//               return ListTile(
//                 title: Text(entry.value[index]),
//                 tileColor: Colors.grey.shade100,
//               );
//             }, childCount: entry.value.length),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
