import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:wality_application/InsideApp/HomePage.dart';
import 'package:wality_application/widget/CustomBottomAppBar.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_v2/tflite_v2.dart';

class WaterFilterMachinePage extends StatefulWidget {
  File image;

  WaterFilterMachinePage({super.key, required this.image});

  @override
  State<WaterFilterMachinePage> createState() => _WaterFilterMachinePageState();
}

class _WaterFilterMachinePageState extends State<WaterFilterMachinePage> {
  late File image;
  String currentPage = 'WaterFilterMachinePage.dart';

  List<dynamic> _recognitions = [];
  String v = "";
  String filteredResults = "";

  loadmodel() async {
    await Tflite.loadModel(
        model: "assets/model/best_float32.tflite",
        labels: "assets/model/label.txt");
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {});
        detectimage(image);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future detectimage(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 6,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _recognitions = recognitions ?? [];
      List filteredList = _recognitions
          .where((recognition) => recognition['confidence'] > 0.7)
          .toList();
      if (filteredList.isNotEmpty) {
        filteredResults = filteredList
            .map((recognition) =>
                "${recognition['label']}: ${(recognition['confidence'] * 100).toStringAsFixed(2)}%")
            .join("\n");
      } else {
        filteredResults = "No results above 70% confidence";
      }
    });
    print("//////////////////////////////////");
    print(_recognitions);
    print("//////////////////////////////////");
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  @override
  void initState() {
    super.initState();
    image = widget.image; // Initialize image variable
    loadmodel();
    detectimage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0083AB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AppBar(
              backgroundColor: const Color(0xFF0083AB),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Padding(
                padding: EdgeInsets.only(right: 50),
                child: Center(
                  child: Text(
                    'Water Filter Machine',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'SairaCondensed',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD6F1F3),
                  Color(0xFF0083AB),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 320),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 20), // Space between container and button
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("water quality results"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(filteredResults),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Confirmmmm'),
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()),
                                      (Route<dynamic> route) => false);
                                  // _pickImage();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF342056),
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'SairaCondensed',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      //All Navbar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: FloatingActionButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.camera);
            if (image != null) {
              setState(() {});
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WaterFilterMachinePage(image: File(image.path)),
                ),
              );
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF26CBFF),
                  Color(0xFF6980FD),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Icon(Icons.water_drop, color: Colors.black, size: 40),
          ),
        ),
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(currentPage: 'WaterFilterMachinePage.dart'),
      //All Navbar
    );
  }
}
