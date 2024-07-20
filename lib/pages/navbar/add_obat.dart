import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddObat extends StatefulWidget {
  @override
  _AddObatState createState() => _AddObatState();
}

class _AddObatState extends State<AddObat> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();
  final TextEditingController _gudangController = TextEditingController();
  final TextEditingController _apotekController = TextEditingController();

  void _showSuccessDialog(String obatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text(
                'Obat $obatName berhasil ditambahkan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Obat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _jenisController,
                decoration: InputDecoration(labelText: 'Jenis'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jenis obat';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama obat';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _satuanController,
                decoration: InputDecoration(labelText: 'Satuan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan satuan obat';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _gudangController,
                decoration: InputDecoration(labelText: 'Gudang'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan stok gudang';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _apotekController,
                decoration: InputDecoration(labelText: 'Apotek'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan stok apotek';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    FirebaseFirestore.instance.collection('obat').add({
                      'jenis': _jenisController.text,
                      'nama': _namaController.text,
                      'satuan': _satuanController.text,
                      'gudang': int.parse(_gudangController.text),
                      'apotek': int.parse(_apotekController.text),
                    }).then((_) {
                      _showSuccessDialog(_namaController.text);
                      _formKey.currentState!.reset();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Gagal menambahkan obat: $error'),
                      ));
                    });
                  }
                },
                child: Text('Tambah Obat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
