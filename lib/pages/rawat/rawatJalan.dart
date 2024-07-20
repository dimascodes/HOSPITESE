import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RawatJalan extends StatefulWidget {
  @override
  _RawatJalanState createState() => _RawatJalanState();
}

class _RawatJalanState extends State<RawatJalan> {
  final TextEditingController _namaPasienController = TextEditingController();
  final TextEditingController _nrmController = TextEditingController();
  String _selectedPoli = 'Poli Umum';
  DateTime _selectedDate = DateTime.now();

  Future<void> _daftarKePoli() async {
    final namaPasien = _namaPasienController.text.trim();
    final nrm = int.tryParse(_nrmController.text.trim());

    print('Nama Pasien: $namaPasien');
    print('NRM: $nrm');

    try {
      // Fetch patient data from Firestore
      final pasienSnapshot = await FirebaseFirestore.instance
          .collection('pasien')
          .where('nama', isEqualTo: namaPasien)
          .where('nrm', isEqualTo: nrm)
          .get();

      print('Pasien snapshot: ${pasienSnapshot.docs.length} documents found');

      if (pasienSnapshot.docs.isEmpty) {
        // Show error if patient data is invalid
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('NRM yang Anda input salah'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Add to rawat jalan collection
      await FirebaseFirestore.instance.collection('rawatJalan').add({
        'nama_pasien': namaPasien,
        'nrm': nrm,
        'poli': _selectedPoli,
        'tanggal_waktu': _selectedDate,
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Icon(Icons.check_circle, color: Colors.green, size: 50),
          content: Text('$namaPasien sudah ditambahkan ke poli'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error fetching patient data: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Terjadi kesalahan saat mengakses data pasien.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rawat Jalan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _namaPasienController,
              decoration: InputDecoration(labelText: 'Masukan nama pasien'),
            ),
            TextField(
              controller: _nrmController,
              decoration: InputDecoration(labelText: 'Masukan nomor rekam medis'),
            ),
            DropdownButton<String>(
              value: _selectedPoli,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPoli = newValue!;
                });
              },
              items: <String>[
                'Poli Umum',
                'Poli Anak',
                'Poli Gigi dan Mulut',
                'Poli Kardiologi',
                'Poli Kebidanan dan Kandungan'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate)
                  setState(() {
                    _selectedDate = picked;
                  });
              },
              child: Text("${_selectedDate.toLocal()}".split(' ')[0]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _daftarKePoli,
              child: Text('Daftar ke Poli'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Stock Obat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
