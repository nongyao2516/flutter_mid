import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


import 'add_place_page.dart';
import 'edit_place_page.dart';

void main() => runApp(const MyApp());

//////////////////////////////////////////////////////////////
// ✅ CONFIG
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://127.0.0.1/flutter_mid_268/php_api/";

//////////////////////////////////////////////////////////////
// ✅ APP ROOT
//////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProductList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ PRODUCT LIST PAGE
//////////////////////////////////////////////////////////////

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List products = [];
  List filteredProducts = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse("${baseUrl}show_data.php"));

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          filteredProducts = products;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final name = product['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  ////////////////////////////////////////////////////////////
  // ✅ DELETE
  ////////////////////////////////////////////////////////////

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}delete_data.php?id=$id"),
      );

      final data = json.decode(response.body);

      if (data["success"] == true) {
        fetchProducts();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบสินค้าเรียบร้อย")),
        );
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ CONFIRM DELETE
  ////////////////////////////////////////////////////////////

  void confirmDelete(dynamic product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text("ต้องการลบ ${product['name']} ?"),
        actions: [
          TextButton(
            child: const Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("ลบ"),
            onPressed: () {
              Navigator.pop(context);
              deleteProduct(int.parse(product['id'].toString()));
            },
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // ✅ OPEN EDIT PAGE
  ////////////////////////////////////////////////////////////

  void openEdit(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductPage(product: product),
      ),
    ).then((value) => fetchProducts());
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สถานที่ท่องเที่ยว')),

      body: Column(
        children: [
          //////////////////////////////////////////////////////
          // 🔍 SEARCH
          //////////////////////////////////////////////////////

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search place',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterProducts,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 LIST
          //////////////////////////////////////////////////////

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                   padding: const EdgeInsets.only(bottom: 80), // ✅ สำคัญมาก
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      String imageUrl =
                          "${baseUrl}images/${product['image']}";

                      return Card(
                        child: ListTile(

                          //////////////////////////////////////////////////
                          // 🖼 IMAGE
                          //////////////////////////////////////////////////

                          leading: SizedBox(
                            width: 70,
                            height: 70,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////

                          title: Text(product['name'] ?? 'No Name'),

                          //////////////////////////////////////////////////
                          // 📝 DESC
                          //////////////////////////////////////////////////

                          subtitle:
                              Text(product['province'] ?? ''),

                          //////////////////////////////////////////////////
                          // 💰 PRICE
                          //////////////////////////////////////////////////

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                openEdit(product);
                              } else if (value == 'delete') {
                                confirmDelete(product);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('แก้ไข'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('ลบ'),
                              ),
                            ],
                          ),

                          //////////////////////////////////////////////////
                          // 👉 DETAIL
                          //////////////////////////////////////////////////

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetail(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ➕ ADD BUTTON
      ////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductPage(),
            ),
          ).then((value) => fetchProducts());
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ PRODUCT DETAIL PAGE
//////////////////////////////////////////////////////////////

class ProductDetail extends StatelessWidget {
  final dynamic product;

  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        "${baseUrl}images/${product['image']}";

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////
            // 🖼 IMAGE
            //////////////////////////////////////////////////////

            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            // 🏷 NAME
            //////////////////////////////////////////////////////

            Text(
              product['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 DESC
            //////////////////////////////////////////////////////

            Text(product['description'] ?? ''),

            const SizedBox(height: 10),
 //////////////////////////////////////////////////////
            // 💰 Address
            //////////////////////////////////////////////////////

            Text(
              'ที่อยู่: ${product['address'] ?? ''}',
              style: const TextStyle(fontSize: 18),
            ),

 const SizedBox(height: 10),
            //////////////////////////////////////////////////////
            // 💰 PROVINCE
            //////////////////////////////////////////////////////

            Text(
              'จังหวัด: ${product['province'] ?? ''}',
              style: const TextStyle(fontSize: 18),
            ),

         const SizedBox(height: 10),
     

          ],
        ),
      ),
    );
  }
}