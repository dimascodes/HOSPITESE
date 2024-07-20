import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospitese/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hospitese/pages/jadwal_dokter.dart';
import 'package:hospitese/pages/jenis_perawatan.dart';
import 'package:hospitese/pages/ketersediaan_kamar.dart';
import 'package:hospitese/pages/pendaftaran.dart';
import 'package:hospitese/tes/navbar.dart';
import 'obat/add_obat.dart';
import 'obat/stock_obat.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Future<String> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc['name'] ?? 'User'; // Assuming 'name' is the field where user's name is stored
      }
    }
    return 'User';
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _pages(BuildContext context, String userName) {
    return [
      Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildGridItem(
                    context,
                    'Pendaftaran',
                    'assets/home/pendaftaran.png',
                    PendaftaranPage(),
                  ),
                  _buildGridItem(
                    context,
                    'Jenis perawatan',
                    'assets/home/rawat_inap.png',
                    JenisPerawatanPage(),
                  ),
                  _buildGridItem(
                    context,
                    'Jadwal Dokter',
                    'assets/home/dokter.png',
                    JadwalDokterPage(),
                  ),
                  _buildGridItem(
                    context,
                    'Ketersediaan kamar',
                    'assets/home/kamar.png',
                    KetersediaanKamarPage(),
                  ),
                ],
              ),
            ),
            Image.asset('assets/home/homeRuang.png'),
          ],
        ),
      ),
      StockObat(),
      AddObat(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final String userName = snapshot.data ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: Text('Hi, $userName'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: _pages(context, userName)[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services),
                label: 'Stock Obat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Tambah Obat',
              ),
            ],
            currentIndex: _currentIndex,
            selectedItemColor: Colors.blue,
            onTap: _onBottomNavTapped,
          ),
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context, String title, String assetPath, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, height: 80),
            const SizedBox(height: 16),
            Text(title),
          ],
        ),
      ),
    );
  }
}
