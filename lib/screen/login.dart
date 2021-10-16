import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController lEmailController = TextEditingController();
  TextEditingController lPasswordController = TextEditingController();
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("data_user");
  String? jenis = "Selamat Datang";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Daftar",
                icon: Icon(Icons.email_outlined),
              ),
              Tab(text: "Masuk", icon: Icon(Icons.people_outline)),
            ],
          ),
          title: const Text('Selamat Datang'),
        ),
        body: TabBarView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey1,
                  child: SingleChildScrollView(
                      child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: "Nama Lengkap",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Nama Lengkap';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Masukan Email",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Masukan Email';
                          } else if (!value.contains('@')) {
                            return 'Masukan Email yg Valid!';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Masukan Password",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Masukan Password';
                          } else if (value.length < 6) {
                            return 'Password minimal 6 karakter!';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightBlue)),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          registerToPdam();
                        },
                        child: const Text('Daftar'),
                      ),
                    )
                  ]))),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: lEmailController,
                        decoration: InputDecoration(
                          labelText: "Masukan Email",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Masukan Email';
                          } else if (!value.contains('@')) {
                            return 'Gunakan Email yang Valid!';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: lPasswordController,
                        decoration: InputDecoration(
                          labelText: "Masukan Password",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Masukan Password';
                          } else if (value.length < 6) {
                            return 'Password Minimal 6 karakter!';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: !isLoading
                          ? ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.lightBlue)),
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                logInToPdam();
                              },
                              child: const Text("Masuk"),
                            )
                          : const Text('sadasd'),
                    )
                  ]))),
            ),
          ],
        ),
      ),
    );
  }

  void logInToPdam() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: lEmailController.text, password: lPasswordController.text)
        .then((result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(uid: result.user!.uid)),
      );
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      lEmailController.clear();
      lPasswordController.clear();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text(
                  "Silahkan Periksa kembali email dan password anda atau anda belum terdaftar silahkan melakukan daftar akun terlebih dahulu"),
              actions: [
                ElevatedButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }

  void registerToPdam() {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
      result.user!.updateDisplayName(namaController.text);
      dbRef.child(result.user!.uid).set({
        "email": emailController.text,
        "nama": namaController.text,
        "idPelanggan": "",
        "jKelamin": "",
        "nomor": "",
        "paket": "",
        "alamat": "",
        "meteran": ""
      }).then((res) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(uid: result.user!.uid)),
        );
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      emailController.clear();
      namaController.clear();
      passwordController.clear();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text(
                  "registrasi gagal!, usahkan jaringan anda sedang dalam keadaan stabil dan pastikan daftar dengan email yg belum terdaftar"),
              actions: [
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
}

  // Contoh Show Dialog
  // void showLoaderDialog(BuildContext context) {
  //   AlertDialog alert = AlertDialog(
  //     content: Row(
  //       children: [
  //         const CircularProgressIndicator(),
  //         Container(
  //             margin: const EdgeInsets.only(left: 20),
  //             child: const Text("Loading...")),
  //       ],
  //     ),
  //   );
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }
