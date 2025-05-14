import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class FaceRegisterPage extends StatefulWidget {
  const FaceRegisterPage({super.key});

  @override
  State<FaceRegisterPage> createState() => _FaceRegisterPageState();
}

class _FaceRegisterPageState extends State<FaceRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<File> _photos = [];
  bool _isSubmitting = false;
  String _status = '';

  Future<void> _pickImage() async {
    if (_photos.length >= 5) {
      setState(() {
        _status = "Maksimal 5 foto untuk pendaftaran.";
      });
      return;
    }

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
        _status = "Foto ditambahkan.";
      });
    }
  }

  Future<void> _submitFaceRegister() async {
    if (_nameController.text.isEmpty || _photos.isEmpty) {
      setState(() {
        _status = "Isi nama dan ambil minimal 1 foto.";
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _status = "Mengirim data...";
    });

    try {
      List<String> base64Images = [];
      for (var photo in _photos) {
        final bytes = await photo.readAsBytes();
        base64Images.add(base64Encode(bytes));
      }

      await ApiService.registerFace(
        name: _nameController.text.trim(),
        images: _photos,
      );

    } catch (e) {
      setState(() {
        _status = "Terjadi kesalahan: $e";
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrasi Wajah"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama Lengkap"),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _photos.map((file) {
                return Image.file(file, height: 100, width: 100, fit: BoxFit.cover);
              }).toList(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil Foto Wajah"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitFaceRegister,
              icon: const Icon(Icons.face_retouching_natural),
              label: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text("Kirim Registrasi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white ,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
