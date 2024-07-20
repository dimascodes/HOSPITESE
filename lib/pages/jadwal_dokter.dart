import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({Key? key}) : super(key: key);

  @override
  _DoctorSchedulePageState createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _doctorsStream;

  @override
  void initState() {
    super.initState();
    _doctorsStream = FirebaseFirestore.instance.collection('jadwal').snapshots();
  }

  Stream<QuerySnapshot> _searchDoctor(String searchQuery) {
    return FirebaseFirestore.instance.collection('jadwal')
        .where('dokter', isEqualTo: searchQuery)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Dokter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari dokter...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String searchQuery = _searchController.text.trim();
                    setState(() {
                      _doctorsStream = _searchDoctor(searchQuery);
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _doctorsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Tidak ada data dokter'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doctor = snapshot.data!.docs[index];
                    final doctorData = doctor.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          doctorData['dokter'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  doctorData['tanggal'] ?? '',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              doctorData['keterangan'] ?? '',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Poli: ${doctorData['poli'] ?? ''}',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(doctorData['dokter'] ?? ''),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Tanggal: ${doctorData['tanggal'] ?? ''}'),
                                  SizedBox(height: 8),
                                  Text('Keterangan: ${doctorData['keterangan'] ?? ''}'),
                                  SizedBox(height: 8),
                                  Text('Poli: ${doctorData['poli'] ?? ''}'),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DoctorSchedulePage(),
  ));
}
