import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/api_service.dart';
import '../services/location_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  File? _imageFile;
  Position? _position;
  double? _distanceToSchool;
  bool _isSubmitting = false;
  String _statusMessage = '';
  late GoogleMapController _mapController;

  final ImagePicker _picker = ImagePicker();
  final LatLng schoolLatLng = const LatLng(-7.3480239, 108.2177564); // ganti lokasi sekolah

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      Position pos = await LocationService.getCurrentLocation();
      double distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        schoolLatLng.latitude,
        schoolLatLng.longitude,
      );
      setState(() {
        _position = pos;
        _distanceToSchool = distance;
        _statusMessage =
            "Jarak ke sekolah: ${distance.toStringAsFixed(2)} meter";
      });
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(pos.latitude, pos.longitude),
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Gagal mendapatkan lokasi: $e";
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_imageFile == null || _position == null) {
      setState(() {
        _statusMessage = "Harap ambil foto dan lokasi terlebih dahulu.";
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = "Mengirim data absensi...";
    });

    try {
      String result = await ApiService.submitAttendance(
        studentId: "123",
        imageFile: _imageFile!,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
      );

      setState(() {
        _statusMessage = result;
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Gagal kirim absensi: $e";
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWithinRange =
        _distanceToSchool != null && _distanceToSchool! <= 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambil Absensi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _imageFile == null
                  ? Container(
                      key: const ValueKey(1),
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Center(child: Text("Belum ada foto")),
                    )
                  : ClipRRect(
                      key: const ValueKey(2),
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!,
                          height: 200, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: schoolLatLng,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("sekolah"),
                      position: schoolLatLng,
                      infoWindow: const InfoWindow(title: "Sekolah"),
                    ),
                    if (_position != null)
                      Marker(
                        markerId: const MarkerId("siswa"),
                        position:
                            LatLng(_position!.latitude, _position!.longitude),
                        infoWindow: const InfoWindow(title: "Lokasi Anda"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure),
                      )
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Ambil Foto"),
                ),
                ElevatedButton.icon(
                  onPressed: _getLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text("Ambil Lokasi"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              onPressed:
                  (_isSubmitting || !isWithinRange) ? null : _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: isWithinRange ? Colors.green : Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              label: _isSubmitting
                  ? const SpinKitThreeBounce(
                      color: Colors.white,
                      size: 20.0,
                    )
                  : const Text("Kirim Absensi"),
            ),
          ],
        ),
      ),
    );
  }
}
