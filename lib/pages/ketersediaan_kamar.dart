import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CekKamar extends StatefulWidget {
  @override
  _CekKamarState createState() => _CekKamarState();
}

class _CekKamarState extends State<CekKamar> {
  TextEditingController get _searchController => TextEditingController();
  int _selectedIndex = 0;

  final List<String> subCollectionNames = [
    'ICU',
    'VIP',
    'Ruang Isolasi',
    'Lantai2 Kelas1',
    'Lantai2 Kelas2',
    'Lantai2 Kelas3'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle your navigation logic here based on the index
    });
  }

  Stream<QuerySnapshot> _getRoomsStream() {
    return FirebaseFirestore.instance.collection('kamar').snapshots();
  }

  Stream<QuerySnapshot> _getSubCollectionStream(String parentId, String subCollectionName) {
    return FirebaseFirestore.instance.collection('kamar').doc(parentId).collection(subCollectionName).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ketersediaan kamar Rawat Inap'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getRoomsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No data available'));
                  }

                  final data = snapshot.requireData;

                  return ListView.builder(
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                      final parentRoom = data.docs[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: subCollectionNames.map((subCollectionName) {
                          return StreamBuilder<QuerySnapshot>(
                            stream: _getSubCollectionStream(parentRoom.id, subCollectionName),
                            builder: (context, subSnapshot) {
                              if (subSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (subSnapshot.hasError) {
                                return Center(child: Text('Error: ${subSnapshot.error}'));
                              }

                              if (!subSnapshot.hasData || subSnapshot.data == null || subSnapshot.data!.docs.isEmpty) {
                                return SizedBox.shrink(); // Return empty space if no data
                              }

                              final subData = subSnapshot.requireData;

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: subData.docs.length,
                                itemBuilder: (context, subIndex) {
                                  final room = subData.docs[subIndex];
                                  final roomData = room.data() as Map<String, dynamic>;

                                  if (!roomData.containsKey('kapasitas') || !roomData.containsKey('isi')) {
                                    return Center(child: Text('Invalid data format for room: ${room.id}'));
                                  }

                                  final kapasitas = int.tryParse(roomData['kapasitas']) ?? 0;
                                  final isi = int.tryParse(roomData['isi']) ?? 0;
                                  final kosong = kapasitas - isi;

                                  return Card(
                                    child: ListTile(
                                      title: Text('$subCollectionName'),
                                      subtitle: Text('Kapasitas: $kapasitas, Isi: $isi, Kosong: $kosong'),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
