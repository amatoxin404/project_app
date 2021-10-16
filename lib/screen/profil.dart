import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  final String? uid;
  const ProfilPage({Key? key, this.uid}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? _nama;
  String? _email;
  String? _idPen;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("data_user");
  @override
  void initState() {
    dbRef.child(widget.uid!).get().then((DataSnapshot? snapshot) {
      setState(() {
        _nama = snapshot!.value['nama'];
        _email = snapshot.value['email'];
        _idPen = snapshot.value['idPelanggan'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profil"),
        ),
        body: SingleChildScrollView(
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: CircleAvatar(
                      radius: 120.0,
                      backgroundImage: NetworkImage(
                          "https://images6.alphacoders.com/934/thumbbig-934733.webp"),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.people, size: 50),
                        title: const Text('Nama Lengkap'),
                        subtitle: Text(_nama ?? ""),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.mail, size: 50),
                        title: const Text('Email'),
                        subtitle: Text(_email ?? ""),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.water, size: 50),
                        title: const Text('ID Pelanggan'),
                        subtitle: _idPen != ""
                            ? Text(_idPen!)
                            : const Text('Anda belum memiliki id pelanggan'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
