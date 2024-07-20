import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditObat extends StatefulWidget {
  @override
  _EditObatState createState() => _EditObatState();
}

class _EditObatState extends State<EditObat> {
  void _showEditBottomSheet(BuildContext context, DocumentSnapshot obat) {
    final TextEditingController _jenisController =
        TextEditingController(text: obat['jenis']);
    final TextEditingController _namaController =
        TextEditingController(text: obat['nama']);
    final TextEditingController _satuanController =
        TextEditingController(text: obat['satuan']);
    final TextEditingController _gudangController =
        TextEditingController(text: obat['gudang'].toString());
    final TextEditingController _apotekController =
        TextEditingController(text: obat['apotek'].toString());

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
                    Text('Edit Obat', style: TextStyle(fontSize: 18)),
                    TextFormField(
                      controller: _jenisController,
                      decoration: InputDecoration(labelText: 'Jenis'),
                    ),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(labelText: 'Nama'),
                    ),
                    TextFormField(
                      controller: _satuanController,
                      decoration: InputDecoration(labelText: 'Satuan'),
                    ),
                    TextFormField(
                      controller: _gudangController,
                      decoration: InputDecoration(labelText: 'Gudang'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _apotekController,
                      decoration: InputDecoration(labelText: 'Apotek'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('obat')
                            .doc(obat.id)
                            .update({
                          'jenis': _jenisController.text,
                          'nama': _namaController.text,
                          'satuan': _satuanController.text,
                          'gudang': int.parse(_gudangController.text),
                          'apotek': int.parse(_apotekController.text),
                        }).then((_) {
                          Navigator.pop(context);
                          _showSuccessDialog(_namaController.text);
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Gagal memperbarui obat: $error'),
                          ));
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

  void _showSuccessDialog(String obatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.update, color: Colors.blue, size: 50),
              SizedBox(height: 10),
              Text(
                'Obat $obatName berhasil di update',
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
        title: Text('Edit Obat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('obat').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Jenis')),
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Satuan')),
                DataColumn(label: Text('Gudang')),
                DataColumn(label: Text('Apotek')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: data.map((obat) {
                return DataRow(cells: [
                  DataCell(Text(obat['jenis'])),
                  DataCell(Text(obat['nama'])),
                  DataCell(Text(obat['satuan'])),
                  DataCell(Text(obat['gudang'].toString())),
                  DataCell(Text(obat['apotek'].toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditBottomSheet(context, obat);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            obat.reference.delete();
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
