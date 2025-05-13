import 'package:flutter/material.dart';
import 'attendance_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _animation,
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Colors.blueAccent),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.shade100,
      appBar: AppBar(
        title: const Text("Dashboard Siswa"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            buildMenuButton(
              icon: Icons.how_to_reg,
              title: "Ambil Absensi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendancePage()),
                );
              },
            ),
            buildMenuButton(
              icon: Icons.calendar_today,
              title: "Jadwal Pelajaran",
              onTap: () {
                // Navigasi ke halaman jadwal
              },
            ),
            buildMenuButton(
              icon: Icons.assignment,
              title: "Tugas & PR",
              onTap: () {
                // Navigasi ke halaman tugas
              },
            ),
            buildMenuButton(
              icon: Icons.grade,
              title: "Nilai & Rapor",
              onTap: () {
                // Navigasi ke halaman nilai
              },
            ),
            buildMenuButton(
              icon: Icons.logout,
              title: "Keluar",
              onTap: () {
                Navigator.pop(context); // Logout ke LoginPage
              },
            ),
          ],
        ),
      ),
    );
  }
}
