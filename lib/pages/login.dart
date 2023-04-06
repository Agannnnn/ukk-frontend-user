import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_user/main.dart';
import 'package:frontend_user/pages/auctions.dart';
import 'package:frontend_user/pages/registration.dart';
import 'package:gap/gap.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _username = "";
  String _password = "";
  final SessionManager session = SessionManager();

  checkLoggedIn() async {
    String? authHeader = await session.get("Auth-Header");
    try {
      Response res = await dio.get("$apiUrl/",
          options: Options(headers: {'Authorization': "Basic $authHeader"}));
      if (res.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Auctions(),
        ));
      }
    } catch (e) {
      return;
    }
  }

  login() async {
    if (!_formKey.currentState!.validate()) return;

    String authHeader = base64.encode(utf8.encode("$_username:$_password"));

    try {
      Response res = await dio.get("$apiUrl/",
          options: Options(headers: {'Authorization': "Basic $authHeader"}));

      if (res.statusCode == 200) {
        session.set("Auth-Header", authHeader);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Auctions(),
        ));
      }
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response == null ||
            e.response!.data?['error'] == null) {
          return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Terjadi kesalahan")));
        } else {
          return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(e.response!.data['error'])));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "LOGIN",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                        const Gap(20),
                        TextFormField(
                          validator: (value) {
                            if (value == null) {
                              return "Field harus diisi";
                            } else if (value.isEmpty) {
                              return "Field harus diisi";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _username = value;
                            });
                          },
                          keyboardType: TextInputType.text,
                          decoration:
                              const InputDecoration(label: Text("Username")),
                        ),
                        const Gap(10),
                        TextFormField(
                          validator: (value) {
                            if (value == null) {
                              return "Field harus diisi";
                            } else if (value.isEmpty) {
                              return "Field harus diisi";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                            });
                          },
                          keyboardType: TextInputType.text,
                          decoration:
                              const InputDecoration(label: Text("Password")),
                          obscureText: true,
                        ),
                        const Gap(15),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: login,
                                child: const Text("LOGIN"),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Belum punya akun?"),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Registration(),
                                    ),
                                  );
                                },
                                child: const Text("Register"))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
