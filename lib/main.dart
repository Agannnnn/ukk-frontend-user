import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_user/pages/login.dart';

Dio dio = Dio();

late String apiUrl;
late String registerUrl;
late String apiAssetsUrl;

void main() async {
  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));

  await dotenv.load(fileName: ".env");

  apiUrl = "${dotenv.env["API_URL"]}";
  registerUrl = "${dotenv.env["API_ASSET_URL"]}";
  apiAssetsUrl = "${dotenv.env["REGISTER_URL"]}";

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 103, 148, 142),
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 103, 148, 142),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          fillColor: Color.fromARGB(15, 0, 0, 0),
          filled: true,
        ),
      ),
      title: "LELANG.ID",
      home: const Login(),
    );
  }
}
