import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PasienLamaPage extends StatefulWidget {
  @override
  _PasienLamaPageState createState() => _PasienLamaPageState();
}

class _PasienLamaPageState extends State<PasienLamaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  void _showEditBottomSheet(BuildContext context, DocumentSnapshot pasien) {
    final TextEditingController _namaController =
        TextEditingController(text: pasien['nama']);
    final TextEditingController _ktpController =
        TextEditingController(text: pasien['ktp']);
    final TextEditingController _alamatController =
        TextEditingController(text: pasien['alamat']);
    final TextEditingController _teleponController =
        TextEditingController(text: pasien['telepon']);
    String _jenisKelamin = pasien['jenis_kelamin'];
    DateTime? _selectedDate = pasien['tanggal_lahir'].toDate();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Edit Pasien', style: TextStyle(fontSize: 18)),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(labelText: 'Nama'),
                    ),
                    TextFormField(
                      controller: _ktpController,
                      decoration: InputDecoration(labelText: 'Nomor KTP'),
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(labelText: 'Alamat'),
                    ),
                    TextFormField(
                      controller: _teleponController,
                      decoration: InputDecoration(labelText: 'Telepon'),
                    ),
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
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal lahir',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('pasien')
                            .doc(pasien.id)
                            .update({
                          'nama': _namaController.text,
                          'ktp': _ktpController.text,
                          'jenis_kelamin': _jenisKelamin,
                          'alamat': _alamatController.text,
                          'tanggal_lahir': _selectedDate,
                          'telepon': _teleponController.text,
                        }).then((value) {
                          Navigator.pop(context);
                        });
                      },
                      child: Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _showPatientDetails(BuildContext context, DocumentSnapshot pasien) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('Detail Pasien'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nama: ${pasien['nama']}'),
              Text('Nomor KTP: ${pasien['ktp']}'),
              Text('Jenis Kelamin: ${pasien['jenis_kelamin']}'),
              Text('Alamat: ${pasien['alamat']}'),
              Text('Tanggal Lahir: ${DateFormat('dd/MM/yyyy').format(pasien['tanggal_lahir'].toDate())}'),
              Text('Telepon: ${pasien['telepon']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditBottomSheet(context, pasien);
              },
              child: Text('Edit'),
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
        title: Text('Pasien Lama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by NRM',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('pasien')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final patients = snapshot.data!.docs.where((doc) {
                    return doc['nrm']
                        .toString()
                        .contains(_searchText);
                  }).toList();

                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                          patient['nama'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NRM: ${patient['nrm']}'),
                            Text('NIK: ${patient['ktp']}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _showPatientDetails(context, patient);
                          },
                          child: Text('Cek Data'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
