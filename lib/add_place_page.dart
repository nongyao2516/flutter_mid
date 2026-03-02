import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {

  ////////////////////////////////////////////////////////////
  // ✅ Controllers
  ////////////////////////////////////////////////////////////

  final TextEditingController nameController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController mapUrlController = TextEditingController();

  ////////////////////////////////////////////////////////////
  // ✅ Image (ใช้ XFile รองรับ Web)
  ////////////////////////////////////////////////////////////

  XFile? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ Save Product + Upload Image
  ////////////////////////////////////////////////////////////

  Future<void> saveProduct() async {

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกรูปภาพ")),
      );
      return;
    }

    final url = Uri.parse(
      "http://localhost/flutter_mid_268/php_api/insert_data.php",
    );

    var request = http.MultipartRequest('POST', url);

    ////////////////////////////////////////////////////////////
    // ✅ Fields
    ////////////////////////////////////////////////////////////

    request.fields['name'] = nameController.text;
    request.fields['province'] = provinceController.text;
    request.fields['description'] = descController.text;
    request.fields['map_url'] = mapUrlController.text;

    ////////////////////////////////////////////////////////////
    // ✅ Upload Image (แยก Web / Mobile)
    ////////////////////////////////////////////////////////////

    if (kIsWeb) {

      final bytes = await selectedImage!.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: selectedImage!.name,
        ),
      );

    } else {

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          selectedImage!.path,
        ),
      );
    }

    ////////////////////////////////////////////////////////////
    // ✅ Execute
    ////////////////////////////////////////////////////////////

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    final data = json.decode(responseData);

    if (data["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เพิ่มสถานที่ท่องเที่ยวเรียบร้อย")),
      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data["error"]}")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เพิ่มสถานที่ท่องเที่ยว")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [

              ////////////////////////////////////////////////////////////
              // 🖼 Image Preview (สำคัญมาก)
              ////////////////////////////////////////////////////////////

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: selectedImage == null
                      ? const Center(
                          child: Text("แตะเพื่อเลือกรูป"),
                        )
                      : kIsWeb
                          ? Image.network(
                              selectedImage!.path, // ✅ Web
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImage!.path), // ✅ Mobile
                              fit: BoxFit.cover,
                            ),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 🏷 Name
              ////////////////////////////////////////////////////////////

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อสถานที่ท่องเที่ยว",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 🏷 Province
              ////////////////////////////////////////////////////////////

              TextField(
                controller: provinceController,
                decoration: const InputDecoration(
                  labelText: "จังหวัด",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),


              ////////////////////////////////////////////////////////////
              // 📝 Description
              ////////////////////////////////////////////////////////////

              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "รายละเอียด",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),
                // 📝 Map URL
              ////////////////////////////////////////////////////////////

              TextField(
                controller: mapUrlController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "URL แผนที่",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ////////////////////////////////////////////////////////////
              // ✅ Button
              ////////////////////////////////////////////////////////////

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveProduct,
                  child: const Text("บันทึกสถานที่ท่องเที่ยว"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
