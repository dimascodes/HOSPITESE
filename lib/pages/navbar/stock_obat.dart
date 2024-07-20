import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_obat.dart';
import 'edit_obat.dart';

class StockObat extends StatefulWidget {
  @override
  _StockObatState createState() => _StockObatState();
}

class _StockObatState extends State<StockObat> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Obat'),
        leading: IconButton(
          icon: Icon(Icons.edit_note),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditObat()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari jenis obat...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchQuery = _searchController.text;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchQuery.isEmpty)
                  ? FirebaseFirestore.instance.collection('obat').snapshots()
                  : FirebaseFirestore.instance
                      .collection('obat')
                      .where('nama', isEqualTo: searchQuery)
                      .snapshots(),
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
                    ],
                    rows: data.map((obat) {
                      return DataRow(cells: [
                        DataCell(Text(obat['jenis'])),
                        DataCell(Text(obat['nama'])),
                        DataCell(Text(obat['satuan'])),
                        DataCell(Text(obat['gudang'].toString())),
                        DataCell(Text(obat['apotek'].toString())),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddObat()), // Navigasi ke halaman tambah obat
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
