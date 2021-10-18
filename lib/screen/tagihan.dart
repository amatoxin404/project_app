import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'home.dart';

// ignore: must_be_immutable
class TagihanPage extends StatefulWidget {
  String? uid;
  TagihanPage({Key? key, this.uid}) : super(key: key);

  @override
  _TagihanPageState createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  String? _cekId;
  String? _meteran;
  final _formKey = GlobalKey<FormState>();
  TextEditingController meterController = TextEditingController();
  TextEditingController idController = TextEditingController();
  DatabaseReference dbUser =
      FirebaseDatabase.instance.reference().child("data_user");
  List<Map<dynamic, dynamic>> lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(uid: widget.uid)),
                  );
                }),
            title: const Text("Tagihan Page")),
        body: Form(
            key: _formKey,
            child: _cekId == null
                ? SingleChildScrollView(
                    child: Column(children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Center(
                        child: Text("Silahkan Masukan ID Pelanggan Anda"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: idController,
                        decoration: InputDecoration(
                          labelText: "Id Pelanggan",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'id Pelanggan';
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
                        onPressed: () async {
                          dbUser
                              .orderByChild("idPelanggan")
                              .equalTo(idController.text)
                              .once()
                              .then((DataSnapshot shoot) {
                            setState(() {
                              for (var value in shoot.value.values) {
                                lists.add(value);
                              }
                              for (var v in lists) {
                                _cekId = v['idPelanggan'].toString();
                                _meteran = v['meteran'].toString();
                              }
                            });
                          }).catchError((onError) {
                            idController.clear();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Error"),
                                    content: const Text(
                                        "Id pelanggan salah atau tidak terdaftar!"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Kembali"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          });
                        },
                        child: const Text('Cek'),
                      ),
                    )
                  ]))
                : SingleChildScrollView(
                    child: Column(children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text("Meteran Bulan Lalu"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(_meteran!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: meterController,
                        decoration: InputDecoration(
                          labelText: "Nomor Meteran",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Nomor Meteran';
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
                        onPressed: () async {
                          String? _harga;
                          var myInt = int.parse(meterController.text);
                          assert(myInt is int);
                          if (myInt <= int.parse(_meteran!) + 60) {
                            setState(() {
                              _harga = "60000";
                            });
                          } else if (myInt > int.parse(_meteran!) + 60 &&
                              myInt <= int.parse(_meteran!) + 100) {
                            setState(() {
                              _harga = "100000";
                            });
                          } else {
                            setState(() {
                              _harga = "Error";
                            });
                          }
                          _harga != "Error"
                              ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Status Tagihan"),
                                      content: Stack(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                                "Total Pembayaran Bulan ini adalah"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 60, left: 8.0),
                                            child: Text('RP. $_harga'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("Kembali"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  })
                              : showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Kesalahan"),
                                      content: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                            "Melebihi Batas Pemakaian Wajar Paket Anda silahkan Hubungi Admin"),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("Kembali"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                        },
                        child: const Text('Cek'),
                      ),
                    )
                  ]))));
  }

  @override
  void dispose() {
    super.dispose();
    meterController.dispose();
  }
}
