import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

const String baseUrl =
    "http://127.0.0.1/flutter_mid_268/php_api/";

class EditProductPage extends StatefulWidget {
  final dynamic product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController descController;

 final List<String> provinces = [
    "กรุงเทพมหานคร",
    "เชียงใหม่",
    "ภูเก็ต",
    "ขอนแก่น",
    "ชลบุรี",
    "นครราชสีมา",
    "สงขลา",
    "สุราษฎร์ธานี",
    "อุบลราชธานี",
    "อยุธยา"
  ];

  String? selectedProvince;







  XFile? selectedImage;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.product['name']);

    addressController =
        TextEditingController(text: widget.product['address']);
    descController =
        TextEditingController(text: widget.product['description']);

     // ✅ ตั้งค่า dropdown เริ่มต้นจากข้อมูลเดิม
    String? provinceFromDB = widget.product['province'];

      if (provinceFromDB != null &&
          provinces.contains(provinceFromDB)) {
        selectedProvince = provinceFromDB;
      } else {
        selectedProvince = null;
      }

 }

  ////////////////////////////////////////////////////////////
  // ✅ PICK IMAGE
  ////////////////////////////////////////////////////////////

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UPDATE PRODUCT + IMAGE
  ////////////////////////////////////////////////////////////

  Future<void> updateProduct() async {
    //เพิ่มการตรวจสอบว่าผู้ใช้เลือกจังหวัดหรือไม่
     if (selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกจังหวัด")),
      );
      return;
    }
    
    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl}update_data.php"),
      );

      ////////////////////////////////////////////////////////
      // ✅ Fields
      ////////////////////////////////////////////////////////

      request.fields['id'] = widget.product['id'].toString();
      request.fields['name'] = nameController.text;
     // เพิ่มการส่งข้อมูลจังหวัดที่เลือก
     request.fields['province'] =  selectedProvince!;
      request.fields['description'] = descController.text;
      request.fields['address'] = addressController.text;
      request.fields['old_image'] = widget.product['image'];

      ////////////////////////////////////////////////////////
      // ✅ Image (ถ้ามี)
      ////////////////////////////////////////////////////////

      if (selectedImage != null) {

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
      }

      ////////////////////////////////////////////////////////
      // ✅ Send
      ////////////////////////////////////////////////////////

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      final data = json.decode(responseData);

      if (data["success"] == true) {

        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขเรียบร้อย")),
        );
      }

    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    String imageUrl =
        "${baseUrl}images/${widget.product['image']}";

    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขสถานที่ท่องเที่ยว")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [

              //////////////////////////////////////////////////
              // 🖼 IMAGE PREVIEW
              //////////////////////////////////////////////////

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: selectedImage == null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
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

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "ชื่อสถานที่ท่องเที่ยว"),
              ),

              const SizedBox(height: 10),
             TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "ที่อยู่"),
              ),

              const SizedBox(height: 10),

             //////////////////////////////////////////////////
              // 🏷 Province Dropdown
              //////////////////////////////////////////////////

         DropdownButtonFormField<String>(
  value: selectedProvince,
  hint: const Text("เลือกจังหวัด"),
  decoration: const InputDecoration(
    labelText: "จังหวัด",
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
              const SizedBox(height: 10),

              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "รายละเอียด"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateProduct,
                  child: const Text("บันทึก"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}