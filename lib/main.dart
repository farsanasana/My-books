import 'package:flutter/material.dart';
import 'package:my_books/app/models/book_collection.dart';
import 'package:my_books/app/screens/book_list_screen.dart';
import 'package:my_books/app/utils/constants.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MyBooksApp());
}

class MyBooksApp extends StatelessWidget {
  const MyBooksApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookCollection(),
      child: MaterialApp(
        title: 'MyBooks',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            secondary: AppConstants.accentColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          cardTheme: CardTheme(
            elevation: AppConstants.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          useMaterial3: true,
        ),
        home: const BookListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}