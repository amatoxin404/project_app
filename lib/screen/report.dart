import 'dart:io';
import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'home.dart';

class ReportPage extends StatefulWidget {
  final String? uid;
  final String? nama;
  final String? lokasi;
  const ReportPage({Key? key, this.nama, this.lokasi, this.uid})
      : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // ignore: avoid_init_to_null
  File? _imageFile = null;
  bool isLoading = false;
  bool status = false;
  String? getUrl = "";
  String? _idPelanggan;
  final picker = ImagePicker();
  String nowDate = DateFormat('yMd').format(DateTime.now());
  final _formKey = GlobalKey<FormState>();
  String? _jenis = "Air Keruh";
  final List<String> jenis = ['Air Keruh', 'Kran Bocor', 'Lainnya'];
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("data_report");
  DatabaseReference dbUser =
      FirebaseDatabase.instance.reference().child("data_user");
  TextEditingController gambarController = TextEditingController();
  TextEditingController keluhanController = TextEditingController();
  TextEditingController nomorController = TextEditingController();

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
        .child("keluhan")
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
    dbUser.child(widget.uid!).get().then((DataSnapshot? snapshot) {
      if (snapshot!.value['idPelanggan'] == "") {
        setState(() {
          _idPelanggan = "kosong";
        });
      } else {
        setState(() {
          _idPelanggan = "ada";
        });
      }
    });
    super.initState();
  }

  // call passed data widget.nama!
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
            title: const Text("Report Page")),
        body: Form(
            key: _formKey,
            child: _idPelanggan != "kosong"
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
                                child: Text("Silahkan Upload Gambar Bukti"))),
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
                      child: DropdownButtonFormField(
                        value: _jenis,
                        items: jenis.map((jenis) {
                          return DropdownMenuItem(
                            value: jenis,
                            child: Text(jenis),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _jenis = val.toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: keluhanController,
                        decoration: InputDecoration(
                          labelText: "Keterangan",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Keterangan';
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
                          if (status) {
                            if (widget.uid == "" &&
                                basename(_imageFile!.path) == "" &&
                                getUrl == "" &&
                                _jenis == "" &&
                                widget.nama == "" &&
                                widget.lokasi == "") {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "Gagal, silahkan periksa kembali semua data yang anda input"),
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
                            } else {
                              if (_formKey.currentState!.validate()) {
                                dbRef.push().set({
                                  "idUser": widget.uid,
                                  "namaGambar": basename(_imageFile!.path),
                                  "gambar": getUrl,
                                  "keluhan": keluhanController.text,
                                  "nomor": nomorController.text,
                                  "jenis": _jenis,
                                  "nama": widget.nama,
                                  "alamat": widget.lokasi,
                                  "status": "Pending",
                                  "tanggal": nowDate
                                }).then((_) {
                                  setState(() {
                                    status = false;
                                    _imageFile = null;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Sukses"),
                                          content: const Text(
                                              'Berhasil Tambah Data'),
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
                                  gambarController.clear();
                                  keluhanController.clear();
                                  nomorController.clear();
                                }).catchError((onError) {
                                  setState(() {
                                    _imageFile = null;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Error"),
                                          content: Text(onError.toString()),
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
                            }
                          } else {
                            setState(() {
                              _imageFile = null;
                            });
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Error"),
                                    content: const Text("Gagal Upload Image"),
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
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    )
                  ]))
                : const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                        child: Text(
                            "Maaf anda tidak memiliki ID pelanggan, silahkan melakukan pendaftaran sambung baru di pojok kanan atas di halaman home atau hubungi admin")),
                  )));
  }

  @override
  void dispose() {
    super.dispose();
    gambarController.dispose();
    keluhanController.dispose();
    nomorController.dispose();
  }
}
