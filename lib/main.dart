import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greddit_lite/screens/home_screen.dart';
import 'package:greddit_lite/screens/subgreddiit_list_screen.dart';
import 'package:greddit_lite/screens/create_post_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GredditLiteApp(),
    ),
  );
}

class GredditLiteApp extends ConsumerWidget {
  const GredditLiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const doomScaffoldBg = Color(0xFF181818);
    const doomAppBarBg = Color(0xFF222222);
    const doomCardBg = Color(0xFF282828);
    const doomPrimaryAccent = Color(0xFF78909C);
    const doomSelectedAccent = Color(0xFFB0BEC5);
    const doomUnselectedColor = Color(0xFF757575);
    const doomLightTextColor = Color(0xFFE0E0E0);
    const doomButtonText = Colors.white;

    return MaterialApp(
      title: 'Greddit Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: doomPrimaryAccent,
        scaffoldBackgroundColor: doomScaffoldBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: doomAppBarBg,
          foregroundColor: doomLightTextColor,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          color: doomCardBg,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey[700]!, width: 0.5),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: doomPrimaryAccent,
            foregroundColor: doomButtonText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: doomAppBarBg,
          selectedItemColor: doomSelectedAccent,
          unselectedItemColor: doomUnselectedColor,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: doomLightTextColor),
          bodyMedium: TextStyle(color: doomLightTextColor),
          titleMedium: TextStyle(color: doomLightTextColor),
          titleLarge: TextStyle(color: doomLightTextColor, fontWeight: FontWeight.bold),
          labelLarge: TextStyle(color: doomButtonText, fontWeight: FontWeight.bold),
        ).apply(
          bodyColor: doomLightTextColor,
          displayColor: doomLightTextColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: doomCardBg,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(width: 0.0, style: BorderStyle.none),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: doomSelectedAccent, width: 1.5),
          ),
          prefixIconColor: doomUnselectedColor,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: doomAppBarBg,
          textStyle: TextStyle(color: doomLightTextColor),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return doomSelectedAccent;
            }
            return Colors.grey[600];
          }),
          trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return doomSelectedAccent.withOpacity(0.5);
            }
            return Colors.grey[800];
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
        iconTheme: const IconThemeData(color: doomUnselectedColor),
        primaryIconTheme: const IconThemeData(color: doomSelectedAccent),
        colorScheme: const ColorScheme.dark(
          primary: doomPrimaryAccent,
          onPrimary: doomButtonText,
          secondary: doomSelectedAccent,
          onSecondary: doomAppBarBg,
          surface: doomCardBg,
          onSurface: doomLightTextColor,
          error: Color(0xFFCF6679),
          onError: Colors.black,
        ).copyWith(surface: doomScaffoldBg),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainNavigation(),
    );
  }
}

final currentNavIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    SubGreddiitListScreen(),
    CreatePostScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(currentNavIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'SubGreddiits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create Post',
          ),
        ],
      ),
    );
  }
}