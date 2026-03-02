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
  final TextEditingController descController = TextEditingController();
final TextEditingController addressController = TextEditingController();

  ////////////////////////////////////////////////////////////
  // ✅ Province Dropdown
  ////////////////////////////////////////////////////////////

  final List<String> provinces = [
    "กรุงเทพฯ",
    "เชียงใหม่",
    "ภูเก็ต",
    "ขอนแก่น",
    "ชลบุรี",
    "นครราชสีมา",
    "สงขลา",
    "สุราษฎร์ธานี",
    "อุบลราชธานี",
    "พระนครศรีอยุธยา"
  ];

  String? selectedProvince;

  ////////////////////////////////////////////////////////////
  // ✅ Image Picker
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
  // ✅ Save Product
  ////////////////////////////////////////////////////////////

  Future<void> saveProduct() async {

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกรูปภาพ")),
      );
      return;
    }

    if (selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกจังหวัด")),
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
    request.fields['province'] = selectedProvince!;
    request.fields['description'] = descController.text;
    request.fields['address'] = addressController.text;
   

    ////////////////////////////////////////////////////////////
    // ✅ Upload Image (Web / Mobile)
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
    // ✅ Execute Request
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
      appBar: AppBar(
        title: const Text("เพิ่มสถานที่ท่องเที่ยว"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            children: [

              ////////////////////////////////////////////////////////////
              // 🖼 Image Preview
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
                              selectedImage!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImage!.path),
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
              // 🏷 Address
              ////////////////////////////////////////////////////////////

              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "ที่อยู่",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 🏷 Province Dropdown
              ////////////////////////////////////////////////////////////

              DropdownButtonFormField<String>(
                value: selectedProvince,
                decoration: const InputDecoration(
                  labelText: "จังหวัด",
                  border: OutlineInputBorder(),
                ),
                items: provinces.map((province) {
                  return DropdownMenuItem(
                    value: province,
                    child: Text(province),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvince = value;
                  });
                },
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

              const SizedBox(height: 15),



              ////////////////////////////////////////////////////////////
              // ✅ Save Button
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