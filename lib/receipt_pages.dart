import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'receipts_provider.dart';
import 'receipt.dart';

class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  State<ReceiptScannerPage> createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends State<ReceiptScannerPage> {
  final picker = ImagePicker();
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _scanReceipt();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (picked != null) {
        setState(() {
          _isProcessing = true;
          _errorMessage = null;
        });
        // TODO: Implement receipt processing
        // For now, just create a dummy receipt
        final newReceipt = Receipt(
          totalAmount: 10.0,
          storeCategory: 'Groceries',
          timestamp: DateTime.now(),
        );
        Provider.of<ReceiptsProvider>(context, listen: false).addReceipt(newReceipt);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error accessing gallery: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _scanReceipt() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      
      if (picked != null) {
        setState(() {
          _isProcessing = true;
          _errorMessage = null;
        });
        // TODO: Implement receipt processing
        // For now, just create a dummy receipt
        final newReceipt = Receipt(
          totalAmount: 10.0,
          storeCategory: 'Groceries',
          timestamp: DateTime.now(),
        );
        Provider.of<ReceiptsProvider>(context, listen: false).addReceipt(newReceipt);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error accessing camera: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: Text(_isProcessing ? "Processing..." : "Scan Receipt"),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReceiptDetailPage extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailPage({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store: ${receipt.storeName ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: \$${receipt.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${receipt.date?.toString().split(' ')[0] ?? receipt.timestamp?.toString().split(' ')[0] ?? 'No date'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (receipt.storeCategory != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Category: ${receipt.storeCategory}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 