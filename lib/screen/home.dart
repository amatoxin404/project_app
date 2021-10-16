import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pdam/screen/pdam.dart';
import 'package:pdam/screen/profil.dart';
import 'package:pdam/screen/report.dart';
import 'package:pdam/screen/tagihan.dart';

import '../main.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.uid}) : super(key: key);
  final String? uid;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _nama;
  String? _lokasi;
  String? _idPelanggan;
  String? _verif;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("data_report");
  DatabaseReference dbPen =
      FirebaseDatabase.instance.reference().child("data_pelanggan");
  DatabaseReference dbSer =
      FirebaseDatabase.instance.reference().child("data_user");
  List<Map<dynamic, dynamic>> lists = [];

  @override
  void initState() {
    dbSer.child(widget.uid!).get().then((DataSnapshot? snapshot) {
      setState(() {
        _nama = snapshot!.value['nama'];
        _lokasi = snapshot.value['alamat'];
        _verif = snapshot.value['idPelanggan'];
      });
    });
    dbPen.child(widget.uid!).get().then((DataSnapshot? snapshot) {
      if (snapshot!.value == null) {
        if (_verif == "") {
          setState(() {
            _idPelanggan = "kosong";
          });
        } else {
          setState(() {
            _idPelanggan = "ada";
          });
        }
      } else {
        setState(() {
          _idPelanggan = "ada";
        });
      }
    });
    super.initState();
  }

  void refreshBtn() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("PDAM"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.refresh_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                refreshBtn();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.note_add_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                _idPelanggan == "kosong"
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PdamPage(uid: widget.uid!)),
                      )
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Terima Kasih"),
                            content: _verif == ""
                                ? const Text(
                                    'Pendaftaran sedang di proses, jika data tidak valid silahkan input ulang data asli anda!')
                                : const Text("Terimakasih Sudah Mendaftar"),
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
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReportPage(
                      uid: widget.uid, nama: _nama, lokasi: _lokasi)),
            );
          },
          child: const Icon(Icons.navigation),
          backgroundColor: Colors.green,
        ),
        body: FutureBuilder(
            future: dbRef.once(),
            builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.value != null) {
                  lists.clear();
                  Map<dynamic, dynamic> values = snapshot.data!.value;
                  values.forEach((key, values) {
                    lists.add(values);
                  });
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: lists.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: const FlutterLogo(size: 72.0),
                            title:
                                Text("Jenis Keluhan: " + lists[index]['jenis']),
                            subtitle:
                                Text("Keterangan: " + lists[index]['keluhan']),
                            trailing: lists[index]['status'] == "Pending" ||
                                    lists[index]['status'] == "Proses"
                                ? const Icon(Icons.pending_actions)
                                : const Icon(Icons.done),
                            isThreeLine: true,
                          ),
                        );
                      });
                } else {
                  return const Center(child: Text('Data Kosong'));
                }
              }
              return const CircularProgressIndicator();
            }),
        drawer: NavigateDrawer(nama: _nama, lokasi: _lokasi, uid: widget.uid));
  }
}

class NavigateDrawer extends StatefulWidget {
  final String? nama;
  final String? lokasi;
  final String? uid;
  const NavigateDrawer({Key? key, this.lokasi, this.nama, this.uid})
      : super(key: key);
  @override
  _NavigateDrawerState createState() => _NavigateDrawerState();
}

class _NavigateDrawerState extends State<NavigateDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: null,
            accountName: Text(widget.nama ?? ""),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: IconButton(
              icon: const Icon(Icons.people_alt_outlined, color: Colors.black),
              onPressed: () {},
            ),
            title: const Text('Akun'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilPage(uid: widget.uid!)),
              );
            },
          ),
          ListTile(
            leading: IconButton(
              icon: const Icon(Icons.payment, color: Colors.black),
              onPressed: () {},
            ),
            title: const Text('Tagihan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TagihanPage(uid: widget.uid!)),
              );
            },
          ),
          ListTile(
            leading: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.black),
              onPressed: () {},
            ),
            title: const Text('Keluar'),
            onTap: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut().then((res) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                    (Route<dynamic> route) => false);
              });
            },
          ),
        ],
      ),
    );
  }
}
