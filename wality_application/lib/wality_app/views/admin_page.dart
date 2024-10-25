import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wality_application/wality_app/utils/navigator_utils.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/water_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();
  final WaterService _waterService = WaterService();
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = []; // New list for filtered and sorted users
  bool _isLoading = true;
  String? currentUserId;
  TextEditingController searchController = TextEditingController();
  bool _isScanning = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    currentUserId = _realmService.getCurrentUserId();
    _loadUsers();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  Future<void> _loadUsers() async {
    if (currentUserId == null) {
      LogOutToOutsite(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.fetchUsers();
      setState(() {
        _users = users;
        _filteredUsers = List.from(users); // Initialize filtered list
        _sortUsers(_filteredUsers); // Sort initially
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // New method to sort users alphabetically
  void _sortUsers(List<dynamic> users) {
    users.sort((a, b) {
      String usernameA = (a['username'] ?? '').toString().toLowerCase();
      String usernameB = (b['username'] ?? '').toString().toLowerCase();
      return usernameA.compareTo(usernameB);
    });
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users.where((user) {
          final username = (user['username'] ?? '').toString().toLowerCase();
          return username.contains(query.toLowerCase());
        }).toList();
      }
      // Sort the filtered results alphabetically
      _sortUsers(_filteredUsers);
    });
  }

  ImageProvider _getProfileImage(String? profileImgLink) {
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      return NetworkImage(profileImgLink);
    } else {
      return const AssetImage('assets/images/cat.jpg');
    }
  }

  void _startQRScanner() {
    setState(() {
      _isScanning = true;
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                controller?.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();

      if (scanData.code != null) {
        try {
          final waterAmount = await _waterService.fetchWaterId(scanData.code!);
          if (waterAmount != null) {
            _showDialog('Success', 'Water ID found: $waterAmount ml');
          } else {
            _showDialog('Error', 'Invalid QR code or water not found');
          }
        } catch (e) {
          _showDialog('Error', 'Failed to process QR code: $e');
        }
      } else {
        _showDialog('Error', 'Failed to read QR code');
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _isScanning = false),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0083AB), Color(0xFF003545)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => GoBack(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                      onPressed: _startQRScanner,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _filterUsers,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _filteredUsers.isEmpty // Changed from _users to _filteredUsers
                        ? const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: _filteredUsers.length, // Changed from _users to _filteredUsers
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index]; // Changed from _users to _filteredUsers
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: _getProfileImage(
                                          user['profileImg_link']),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        user['username'] ?? 'Unknown User',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}