import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PasienBaruPage extends StatefulWidget {
  @override
  _PasienBaruPageState createState() => _PasienBaruPageState();
}

class _PasienBaruPageState extends State<PasienBaruPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _ktpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  String _jenisKelamin = '';
  DateTime? _selectedDate;

  void _showSuccessDialog(String patientName) {
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
                'Data pasien $patientName berhasil ditambahkan',
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<int> _getNextNRM() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('pasien').get();
    return snapshot.docs.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masukan data pasien baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Pasien',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama pasien';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ktpController,
                decoration: InputDecoration(
                  labelText: 'Nomor KTP',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nomor KTP';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Laki-laki'),
                      leading: Radio<String>(
                        value: 'Laki-laki',
                        groupValue: _jenisKelamin,
                        onChanged: (String? value) {
                          setState(() {
                            _jenisKelamin = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Perempuan'),
                      leading: Radio<String>(
                        value: 'Perempuan',
                        groupValue: _jenisKelamin,
                        onChanged: (String? value) {
                          setState(() {
                            _jenisKelamin = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan alamat pasien';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal lahir',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                ),
                onTap: () {
                  _selectDate(context);
                },
                controller: TextEditingController(
                  text: _selectedDate == null
                      ? ''
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _teleponController,
                decoration: InputDecoration(
                  labelText: 'Nama telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nomor telepon pasien';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    int nrm = await _getNextNRM();
                    FirebaseFirestore.instance.collection('pasien').add({
                      'nrm': nrm,
                      'nama': _namaController.text,
                      'ktp': _ktpController.text,
                      'jenis_kelamin': _jenisKelamin,
                      'alamat': _alamatController.text,
                      'tanggal_lahir': _selectedDate,
                      'telepon': _teleponController.text,
                    });
                    _showSuccessDialog(_namaController.text);
                    _formKey.currentState!.reset();
                    setState(() {
                      _jenisKelamin = '';
                      _selectedDate = null;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Tambah Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
