import 'dart:io';
import 'dart:io' as io;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'package:image_picker/image_picker.dart';
import 'package:pdam/screen/home.dart';

class PdamPage extends StatefulWidget {
  const PdamPage({Key? key, this.uid}) : super(key: key);
  final String? uid;

  @override
  _PdamPageState createState() => _PdamPageState();
}

class _PdamPageState extends State<PdamPage> {
  bool isLoading = false;
  bool status = false;
  String? keyId;
  String? getUrl = "";
  String? _cekdata;
  // ignore: avoid_init_to_null
  File? _imageFile = null;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("data_pelanggan");
  TextEditingController namaController = TextEditingController();
  TextEditingController nomorController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  String? _paket = "R1";
  String? _kelamin = "Laki-Laki";
  final List<String> paket = ['R1', 'R2'];
  final List<String> kelamin = ['Laki-Laki', 'Perempuan'];

  Future pickImage() async {
    if (status) {
      firebase_storage.FirebaseStorage.instance.refFromURL(getUrl!).delete();
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: ImageSource.camera);

      setState(() {
        _imageFile = File(pickedFile!.path);
      });

      uploadImageToFirebase(uid: widget.uid);
    } else {
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: ImageSource.camera);

      setState(() {
        _imageFile = File(pickedFile!.path);
      });

      uploadImageToFirebase(uid: widget.uid);
    }
  }

  Future uploadImageToFirebase({String? uid}) async {
    String fileName = basename(_imageFile!.path);
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("ktp")
        .child('/$fileName');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    firebase_storage.UploadTask uploadTask;
    uploadTask = ref.putFile(io.File(_imageFile!.path), metadata);
    // ignore: unused_local_variable
    firebase_storage.UploadTask task = await Future.value(uploadTask);
    Future.value(uploadTask)
        .then((value) => {
              _downloadLink(ref),
              setState(() {
                status = true;
              })
            })
        .onError((error, stackTrace) => {
              setState(() {
                status = false;
              })
            });
  }

  Future<void> _downloadLink(firebase_storage.Reference ref) async {
    final link = await ref.getDownloadURL();

    setState(() {
      getUrl = link.toString();
    });
  }

  @override
  void initState() {
    dbRef.child(widget.uid!).get().then((DataSnapshot? snapshot) {
      if (snapshot!.value == null) {
        setState(() {
          _cekdata = null;
        });
      } else {
        setState(() {
          _cekdata = "ada";
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Pendaftaran PDAM")),
        body: Form(
            key: _formKey,
            child: _cekdata == null
                ? SingleChildScrollView(
                    child: Column(children: <Widget>[
                    SizedBox(
                        height: 200,
                        child: _imageFile != null
                            ? Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Image.file(_imageFile!),
                              )
                            : const Center(
                                child:
                                    Text("Silahkan Upload KTP dengan Jelas"))),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.blue,
                          size: 50,
                        ),
                        onPressed: pickImage,
                      ),
                    ),
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
                      child: DropdownButtonFormField(
                        value: _kelamin,
                        items: kelamin.map((kelamin) {
                          return DropdownMenuItem(
                            value: kelamin,
                            child: Text(kelamin),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _kelamin = val.toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: nomorController,
                        decoration: InputDecoration(
                          labelText: "Nomor Telepon",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Nomor Telepon';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: alamatController,
                        decoration: InputDecoration(
                          labelText: "Alamat Lengkap",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Alamat Lengkap';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DropdownButtonFormField(
                        value: _paket,
                        items: paket.map((paket) {
                          return DropdownMenuItem(
                            value: paket,
                            child: Text('Paket - $paket'),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _paket = val.toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightBlue)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            dbRef.child(widget.uid!).set({
                              "namaKtp": basename(_imageFile!.path),
                              "ktp": getUrl,
                              "nama": namaController.text,
                              "jKelamin": _kelamin,
                              "nomor": nomorController.text,
                              "alamat": alamatController.text,
                              "paket": _paket,
                            }).then((_) {
                              setState(() {
                                status = false;
                                _imageFile = null;
                                _paket = "R1";
                                _kelamin = "Laki-Laki";
                                _cekdata = null;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Sukses"),
                                      content:
                                          const Text('Berhasil Tambah Data'),
                                      actions: [
                                        TextButton(
                                          child: const Text("Ok"),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        Home(
                                                          uid: widget.uid,
                                                        )));
                                          },
                                        )
                                      ],
                                    );
                                  });
                              namaController.clear();
                              nomorController.clear();
                              alamatController.clear();
                            }).catchError((onError) {
                              setState(() {
                                status = false;
                                _imageFile = null;
                                _paket = "R1";
                                _cekdata = null;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: Text(onError),
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
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    )
                  ]))
                : const Center(
                    child: Text("Akun ini sudah melakukan pendaftaran"))));
  }

  @override
  void dispose() {
    super.dispose();
    namaController.dispose();
    nomorController.dispose();
    alamatController.dispose();
  }
}
