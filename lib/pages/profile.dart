import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_user/main.dart';
import 'package:frontend_user/widget/default_layout.dart';
import 'package:gap/gap.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GlobalKey<FormState> _formKey = GlobalKey();

  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _phone = "";
  String _username = "";
  String _password = "";

  String _firstNameInput = "";
  String _lastNameInput = "";
  String _emailInput = "";
  String _phoneInput = "";
  String _usernameInput = "";
  String _passwordInput = "";

  fetchProfile() async {
    try {
      Response res = await dio.get(
        "$apiUrl/profile",
        options: Options(headers: {
          'Authorization': 'Basic ${await SessionManager().get("Auth-Header")}'
        }),
      );

      setState(() {
        _firstName = res.data['nama_depan'];
        _lastName = res.data['nama_belakang'];
        _email = res.data['email'];
        _phone = res.data['no_telp'];
        _username = res.data['username'];
        _password = res.data['password'];

        _firstNameInput = _firstName;
        _lastNameInput = _lastName;
        _emailInput = _email;
        _phoneInput = _phone;
        _usernameInput = _username;
        _passwordInput = _password;
      });
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

  saveUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      Response res = await dio.patch("$apiUrl/profile",
          options: Options(headers: {
            'Authorization':
                'Basic ${await SessionManager().get("Auth-Header")}'
          }),
          data: {
            'nama_depan': _firstNameInput,
            'nama_belakang': _lastNameInput,
            'email': _emailInput,
            'no_telp': _phoneInput,
            'username': _usernameInput,
            'password': _passwordInput,
          });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perubahan telah disimpan")));
      Navigator.of(context).pop();
      return;
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

    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.person, size: 40),
                            ),
                          ),
                          const Gap(10),
                          const Text(
                            "PROFIL",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const Gap(20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (_firstNameInput.isNotEmpty) return null;
                                if (value == null) return "Field harus diisi";
                                if (value.isEmpty) return "Field harus diisi";
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _firstNameInput = value;
                                });
                              },
                              decoration: InputDecoration(
                                  label: Text("NAMA DEPAN - $_firstName"),
                                  helperText:
                                      "Isikan data baru atau kosongkan jika tidak ingin mengubah"),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (_lastNameInput.isNotEmpty) return null;
                                if (value == null) return "Field harus diisi";
                                if (value.isEmpty) return "Field harus diisi";
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _lastNameInput = value;
                                });
                              },
                              decoration: InputDecoration(
                                  label: Text("NAMA BELAKANG - $_lastName"),
                                  helperText:
                                      "Isikan data baru atau kosongkan jika tidak ingin mengubah"),
                            ),
                          )
                        ],
                      ),
                      const Gap(20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (_emailInput.isNotEmpty) return null;
                                if (value == null) return "Field harus diisi";
                                if (value.isEmpty) return "Field harus diisi";
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _emailInput = value;
                                });
                              },
                              decoration: InputDecoration(
                                  label: Text("EMAIL - $_email"),
                                  helperText:
                                      "Isikan data baru atau kosongkan jika tidak ingin mengubah"),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (_phoneInput.isNotEmpty) return null;
                                if (value == null) return "Field harus diisi";
                                if (value.isEmpty) return "Field harus diisi";
                                try {
                                  int.parse(value);
                                } catch (e) {
                                  return "Field harus berisikan angka";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _phoneInput = value;
                                });
                              },
                              decoration: InputDecoration(
                                  label: Text("NOMOR TELEPON - $_phone"),
                                  helperText:
                                      "Isikan data baru atau kosongkan jika tidak ingin mengubah"),
                            ),
                          )
                        ],
                      ),
                      const Gap(10),
                      const Divider(
                        color: Color.fromRGBO(103, 148, 142, 1),
                        thickness: 3,
                      ),
                      const Gap(10),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (_usernameInput.isNotEmpty) return null;
                          if (value == null) return "Field harus diisi";
                          if (value.isEmpty) return "Field harus diisi";
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _usernameInput = value;
                          });
                        },
                        decoration: InputDecoration(
                            label: Text("USERNAME - $_username"),
                            helperText:
                                "Isikan data baru atau kosongkan jika tidak ingin mengubah"),
                      ),
                      const Gap(20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              obscureText: true,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (_password.isNotEmpty) return null;
                                if (value == null) return "Field harus diisi";
                                if (value.isEmpty) return "Field harus diisi";
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _passwordInput = value;
                                });
                              },
                              decoration: InputDecoration(
                                  label: Text("PASSWORD - $_password"),
                                  helperText:
                                      "Isikan data baru atau kosongkan jika tidak ingin mengubah"),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: TextFormField(
                              obscureText: true,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty &&
                                    (_password == _passwordInput)) {
                                  return null;
                                }
                                if (value != _password) {
                                  return "Password tidak sama";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  label: Text("KONFIRMASI PASSWORD"),
                                  helperText: ""),
                            ),
                          )
                        ],
                      ),
                      const Gap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Batal"),
                          ),
                          const Gap(10),
                          FilledButton(
                              onPressed: saveUpdate,
                              child: const Text("Simpan")),
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
    );
  }
}
