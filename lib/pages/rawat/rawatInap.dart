import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PencarianPasienPage extends StatefulWidget {
  @override
  _PencarianPasienPageState createState() => _PencarianPasienPageState();
}

class _PencarianPasienPageState extends State<PencarianPasienPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _kapasitasController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();

  QuerySnapshot? _searchResult;
  String _selectedRoomId = '';
  String _selectedSubCollection = '';

  int _totalPatients = 0;
  int _totalEmptyRooms = 0;

  final List<String> subCollectionNames = [
    'ICU',
    'VIP',
    'Ruang Isolasi',
    'Lantai2 Kelas1',
    'Lantai2 Kelas2',
    'Lantai2 Kelas3'
  ];

  void _searchPatient() async {
    if (_searchController.text.isNotEmpty) {
      final result = await FirebaseFirestore.instance
          .collection('pasien')
          .where('nrm', isEqualTo: _searchController.text)
          .get();
      setState(() {
        _searchResult = result;
      });

      if (result.docs.isNotEmpty) {
        _showPatientDetails(result.docs.first.data() as Map<String, dynamic>);
      } else {
        _showNoResultsFound();
      }
    }
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _searchResult = null;
    });
  }

  void _showPatientDetails(Map<String, dynamic> patientData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Pasien'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nama: ${patientData['nama']}'),
              Text('NRM: ${patientData['nrm']}'),
              Text('Alamat: ${patientData['alamat']}'),
              Text('Umur: ${patientData['umur']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoResultsFound() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tidak Ada Hasil'),
          content: Text('Tidak ada data pasien yang ditemukan dengan NRM tersebut.'),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateRoom(String roomId, String subCollectionName) async {
    final kapasitas = int.tryParse(_kapasitasController.text) ?? 0;
    final isi = int.tryParse(_isiController.text) ?? 0;

    await FirebaseFirestore.instance
        .collection('kamar')
        .doc(roomId)
        .collection(subCollectionName)
        .doc('info')
        .update({
      'kapasitas': kapasitas,
      'isi': isi,
    });

    setState(() {
      _selectedRoomId = '';
      _selectedSubCollection = '';
      _kapasitasController.clear();
      _isiController.clear();
    });
  }

  void _loadSummaryData() async {
    final pasienSnapshot = await FirebaseFirestore.instance.collection('pasien').get();
    final kamarSnapshot = await FirebaseFirestore.instance.collection('kamar').get();

    int totalPatients = pasienSnapshot.docs.length;
    int totalEmptyRooms = 0;

    for (var doc in kamarSnapshot.docs) {
      for (var subCollectionName in subCollectionNames) {
        final subCollectionSnapshot =
            await FirebaseFirestore.instance.collection('kamar').doc(doc.id).collection(subCollectionName).get();
        for (var subDoc in subCollectionSnapshot.docs) {
          final data = subDoc.data() as Map<String, dynamic>;
          final kapasitas = int.tryParse(data['kapasitas'].toString()) ?? 0;
          final isi = int.tryParse(data['isi'].toString()) ?? 0;
          totalEmptyRooms += (kapasitas - isi);
        }
      }
    }

    setState(() {
      _totalPatients = totalPatients;
      _totalEmptyRooms = totalEmptyRooms;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pencarian Pasien Lama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jumlah Pasien Dirawat Inap: $_totalPatients'),
              Text('Jumlah Kamar Kosong: $_totalEmptyRooms'),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'NRM Pasien',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _searchPatient,
                            child: Text('Cari'),
                          ),
                          ElevatedButton(
                            onPressed: _resetSearch,
                            child: Text('Batal'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Manajemen Kamar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('kamar').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return CircularProgressIndicator();
                          final rooms = snapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: subCollectionNames.map((subCollectionName) {
                                  return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('kamar')
                                        .doc(room.id)
                                        .collection(subCollectionName)
                                        .snapshots(),
                                    builder: (context, subSnapshot) {
                                      if (!subSnapshot.hasData) return SizedBox.shrink();
                                      final subData = subSnapshot.data!.docs;
                                      if (subData.isEmpty) return SizedBox.shrink();
                                      final roomInfo = subData.first.data() as Map<String, dynamic>;
                                      final kapasitas = roomInfo['kapasitas'] ?? 0;
                                      final isi = roomInfo['isi'] ?? 0;

                                      return Card(
                                        child: ListTile(
                                          title: Text(subCollectionName),
                                          subtitle: Text('Kapasitas: $kapasitas, Isi: $isi'),
                                          trailing: IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              setState(() {
                                                _selectedRoomId = room.id;
                                                _selectedSubCollection = subCollectionName;
                                                _kapasitasController.text = kapasitas.toString();
                                                _isiController.text = isi.toString();
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),
                      if (_selectedRoomId.isNotEmpty && _selectedSubCollection.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _kapasitasController,
                                decoration: InputDecoration(
                                  labelText: 'Kapasitas',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: _isiController,
                                decoration: InputDecoration(
                                  labelText: 'Isi',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => _updateRoom(_selectedRoomId, _selectedSubCollection),
                                child: Text('Update Kamar'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Jadwal dan Monitoring', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('jadwal').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return CircularProgressIndicator();
                          final jadwals = snapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: jadwals.length,
                            itemBuilder: (context, index) {
                              final jadwal = jadwals[index].data() as Map<String, dynamic>;
                              final tanggal = jadwal['tanggal'] ?? '';
                              final waktu = jadwal['waktu'] ?? '';
                              final keterangan = jadwal['keterangan'] ?? '';
                              final dokter = jadwal['dokter'] ?? '';
                              final jam = jadwal['jam'] ?? '';

                              return Card(
                                child: ListTile(
                                  title: Text('Tanggal: $tanggal'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Waktu: $waktu'),
                                      Text('Keterangan: $keterangan'),
                                      Text('Dokter: $dokter'),
                                      Text('Jam: $jam'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<QuerySnapshot<Object?>?>('_searchResult', _searchResult));
  }
}
