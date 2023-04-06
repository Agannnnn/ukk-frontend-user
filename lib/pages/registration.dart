import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend_user/main.dart';
import 'package:frontend_user/pages/login.dart';
import 'package:gap/gap.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final GlobalKey<FormState> _loginForm = GlobalKey();
  final GlobalKey<FormFieldState> _firstNameInput = GlobalKey();
  final GlobalKey<FormFieldState> _lastNameInput = GlobalKey();
  final GlobalKey<FormFieldState> _emailInput = GlobalKey();
  final GlobalKey<FormFieldState> _phoneInput = GlobalKey();
  final GlobalKey<FormFieldState> _usernameInput = GlobalKey();
  final GlobalKey<FormFieldState> _passwordInput = GlobalKey();
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _phone = "";
  String _username = "";
  String _password = "";
  int _currentForm = 0;

  register() async {
    if (!_loginForm.currentState!.validate()) return;
    try {
      Response res = await dio.post(
        registerUrl,
        data: {
          'nama_depan': _firstName,
          'nama_belakang': _lastName,
          'email': _email,
          'no_telp': _phone,
          'username': _username,
          'password': _password,
        },
      );
      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Text("Akun berhasil dibuat")));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Login(),
        ));
      }
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response == null) {
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
                    key: _loginForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "BUAT AKUN",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                        const Gap(20),
                        if (_currentForm == 0) ...[
                          TextFormField(
                            key: _firstNameInput,
                            initialValue: _firstName,
                            onChanged: (value) {
                              setState(() {
                                _firstName = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return "Field ini harus diisi";
                              if (value.isEmpty) return "Field ini harus diisi";
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                label: Text("Nama Depan")),
                          ),
                          const Gap(10),
                          TextFormField(
                            key: _lastNameInput,
                            initialValue: _lastName,
                            onChanged: (value) {
                              setState(() {
                                _lastName = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return "Field ini harus diisi";
                              if (value.isEmpty) return "Field ini harus diisi";
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                label: Text("Nema Belakang")),
                          )
                        ],
                        if (_currentForm == 1) ...[
                          TextFormField(
                            key: _emailInput,
                            initialValue: _email,
                            onChanged: (value) {
                              setState(() {
                                _email = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return "Field ini harus diisi";
                              if (value.isEmpty) return "Field ini harus diisi";
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(label: Text("Email")),
                          ),
                          const Gap(10),
                          TextFormField(
                            key: _phoneInput,
                            initialValue: _phone,
                            onChanged: (value) {
                              setState(() {
                                _phone = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return "Field ini harus diisi";
                              if (value.isEmpty) return "Field ini harus diisi";
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                label: Text("Nomor Telepon")),
                          )
                        ],
                        if (_currentForm == 2) ...[
                          TextFormField(
                            key: _usernameInput,
                            initialValue: _username,
                            onChanged: (value) {
                              setState(() {
                                _username = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return "Field ini harus diisi";
                              if (value.isEmpty) return "Field ini harus diisi";
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            decoration:
                                const InputDecoration(label: Text("Username")),
                          ),
                          const Gap(10),
                          TextFormField(
                            key: _passwordInput,
                            initialValue: _password,
                            onChanged: (value) {
                              setState(() {
                                _password = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return "Field ini harus diisi";
                              if (value.isEmpty) return "Field ini harus diisi";
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            decoration:
                                const InputDecoration(label: Text("Password")),
                            obscureText: true,
                          )
                        ],
                        const Gap(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: (_currentForm > 0)
                                    ? () {
                                        if (_currentForm - 1 >= 0) {
                                          setState(() {
                                            _currentForm -= 1;
                                          });
                                        }
                                      }
                                    : null,
                                child: Text("Kembali")),
                            TextButton(
                                onPressed: (_currentForm < 2)
                                    ? () {
                                        if (_currentForm + 1 <= 2) {
                                          setState(() {
                                            _currentForm += 1;
                                          });
                                        }
                                      }
                                    : null,
                                child: Text("Lanjut")),
                          ],
                        ),
                        const Gap(5),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: register,
                                child: const Text("DAFTAR"),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                              },
                              child: const Text("Login"),
                            )
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
