import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Keep this for File (though not directly used in putFile anymore, FileImage might need it for mobile)
import 'dart:typed_data'; // Essential for Uint8List
import 'package:firebase_storage/firebase_storage.dart'; // UNCOMMENTED THIS LINE
import 'package:flutter/foundation.dart' show kIsWeb; // Keep this for kIsWeb conditional logic

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _currentContent = 'Dashboard';
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _productStatusActive = true;
  XFile? _selectedImage;
  bool _isUploading = false;

  final TextEditingController _searchProductController = TextEditingController();
  final TextEditingController _searchMailController = TextEditingController();
  final TextEditingController _searchBookingIdController = TextEditingController();

  final TextEditingController _settingNameController = TextEditingController();
  final TextEditingController _settingEmailController = TextEditingController();
  final TextEditingController _settingNewPasswordController = TextEditingController();
  final TextEditingController _settingConfirmPasswordController = TextEditingController();
  final TextEditingController _settingGenderController = TextEditingController();


  @override
  void dispose() {
    _productNameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _searchProductController.dispose();
    _searchMailController.dispose();
    _searchBookingIdController.dispose();
    _settingNameController.dispose();
    _settingEmailController.dispose();
    _settingNewPasswordController.dispose();
    _settingConfirmPasswordController.dispose();
    _settingGenderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _addProduct() async {
    if (_productNameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select an image.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$fileName');

        // Read image as bytes for upload (works for both web and mobile)
        Uint8List imageData = await _selectedImage!.readAsBytes();
        UploadTask uploadTask = storageRef.putData(imageData);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('products').add({
        'name': _productNameController.text.trim(),
        'category': _categoryController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'quantity': int.parse(_quantityController.text.trim()),
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl, // Save the download URL from Firebase Storage
        'statusActive': _productStatusActive,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );

      _productNameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _quantityController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
        _productStatusActive = true;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add product: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - $_currentContent'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _buildBodyContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getBottomNavIndex(_currentContent),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFD4F0EC),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              setState(() { _currentContent = 'Dashboard'; });
              break;
            case 1:
              setState(() { _currentContent = 'Add New Product'; });
              break;
            case 2:
              setState(() { _currentContent = 'Manage Product'; });
              break;
            case 3:
              setState(() { _currentContent = 'View Booking'; });
              break;
            case 4:
              setState(() { _currentContent = 'Messages'; });
              break;
            case 5:
              setState(() { _currentContent = 'Setting'; });
              break;
            case 6: // Logout
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully!")),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add New Product'),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'Manage Product'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'View Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }

  int _getBottomNavIndex(String currentContent) {
    switch (currentContent) {
      case 'Dashboard':
        return 0;
      case 'Add New Product':
        return 1;
      case 'Manage Product':
        return 2;
      case 'View Booking':
        return 3;
      case 'Messages':
        return 4;
      case 'Setting':
        return 5;
      default:
        return 0;
    }
  }

  Widget _buildBodyContent() {
    switch (_currentContent) {
      case 'Dashboard':
        return _buildAdminDashboardContent();
      case 'Add New Product':
        return _buildAddNewProductContent();
      case 'Manage Product':
        return _buildManageProductContent();
      case 'View Booking':
        return _buildViewBookingContent();
      case 'Messages':
        return _buildMessagesContent();
      case 'Setting':
        return _buildSettingContent();
      default:
        return const Center(child: Text('Unknown Admin Section'));
    }
  }

  Widget _buildAdminDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hi admin name', // TODO: Fetch actual admin name from Firestore
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal[800]),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.person_outline, size: 24, color: Colors.teal),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  title: 'Sales Statistics',
                  content: Column(
                    children: [
                      Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(child: Text('Graph Placeholder')),
                      ),
                      const SizedBox(height: 8),
                      const Text('Total visitor: [Number]', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDashboardCard(
                  title: 'Booking Status',
                  content: Column(
                    children: [
                      Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(child: Text('Graph Placeholder')),
                      ),
                      const SizedBox(height: 8),
                      const Text('Upcoming Events: [Number]', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewProductContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Product',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: _selectedImage == null
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  Text('Tap to select image', style: TextStyle(color: Colors.grey)),
                ],
              )
                  : FutureBuilder<Uint8List>(
                future: _selectedImage!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading image.'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _productNameController,
            decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (RM)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity Available', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _productStatusActive,
                onChanged: (bool? newValue) {
                  setState(() {
                    _productStatusActive = newValue!;
                  });
                },
              ),
              const Text('Status (Active)'),
            ],
          ),
          const SizedBox(height: 24),
          _isUploading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _addProduct,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildManageProductContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Products',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchProductController,
              decoration: const InputDecoration(
                hintText: 'Search Product',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
              onSubmitted: (value) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Searching for product: $value")),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Product List Table
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No products found. Add some new products!'));
              }

              List<DataRow> productRows = snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                String imageUrl = data['imageUrl'] ?? 'https://placehold.co/40x40/cccccc/ffffff?text=No+Image'; // Expecting imageUrl from Storage
                String name = data['name'] ?? 'N/A';
                String description = data['description'] ?? 'No description';
                double price = (data['price'] as num?)?.toDouble() ?? 0.0;
                // int quantity = (data['quantity'] as num?)?.toInt() ?? 0; // Removed unused variable

                return DataRow(cells: [
                  DataCell(
                    Image.network( // Use Image.network for Storage URLs
                      imageUrl,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          'https://placehold.co/30x30/cccccc/ffffff?text=Error', // Fallback for image loading errors
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  DataCell(Text(name)),
                  DataCell(Text(description.length > 20 ? '${description.substring(0, 20)}...' : description)),
                  DataCell(Text('RM ${price.toStringAsFixed(2)}')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Edit $name tapped! (ID: ${doc.id})")),
                          );
                          // TODO: Implement edit functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Delete $name tapped! (ID: ${doc.id})")),
                          );
                          // TODO: Implement delete functionality
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 8.0,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 60,
                  columns: const [
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Summary')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: productRows,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewBookingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'View Bookings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Search Booking ID
          TextFormField(
            controller: _searchBookingIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Search Booking ID', border: OutlineInputBorder()),
            onFieldSubmitted: (value) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Searching for Booking ID: $value")),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'All Upcoming Bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Booking List Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12.0,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('12/01/2025')),
                  const DataCell(Text('John Doe')),
                  const DataCell(Text('Approved')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Approve tapped!")),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reject tapped!")),
                          );
                        },
                      ),
                    ],
                  )),
                ]),
                DataRow(cells: [
                  const DataCell(Text('20/05/2025')),
                  const DataCell(Text('Jane Smith')),
                  const DataCell(Text('Pending')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Approve tapped!")),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reject tapped!")),
                          );
                        },
                      ),
                    ],
                  )),
                ]),
                DataRow(cells: [
                  const DataCell(Text('25/05/2025')),
                  const DataCell(Text('Bob Johnson')),
                  const DataCell(Text('Rejected')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Approve tapped!")),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
                        onPressed: () {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reject tapped!")),
                          );
                        },
                      ),
                    ],
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Search Mail
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchMailController,
              decoration: const InputDecoration(
                hintText: 'Search Mail',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
              onSubmitted: (value) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Searching for mail: $value")),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Messages Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12.0,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(label: Text('Sender name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Subject')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Anne')),
                  DataCell(Text('anne@email.com')),
                  DataCell(Text('Room Booking')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Diana')),
                  DataCell(Text('diana@gmail.com')),
                  DataCell(Text('BBQ Buffet Package')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Stitch')),
                  DataCell(Text('stitch@email.com')),
                  DataCell(Text('Dinner Price')),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Setting Page',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: const Center(child: Text('Image')),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _settingNameController,
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _settingEmailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _settingNewPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _settingConfirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _settingGenderController,
            decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Save Settings tapped!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Save Settings'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logged out successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
