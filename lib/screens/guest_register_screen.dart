import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class GuestRegisterScreen extends StatefulWidget {
  const GuestRegisterScreen({super.key});

  @override
  _GuestRegisterScreenState createState() => _GuestRegisterScreenState();
}

class _GuestRegisterScreenState extends State<GuestRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNoController = TextEditingController();
  final TextEditingController roomRentController = TextEditingController();
  //final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController extraChargeController = TextEditingController();

  String? _selectedRoomNo;
  bool _isLoading = false;

  Uint8List? idFrontImageMale;
  Uint8List? idBackImageMale;
  String? idFrontUrlMale;
  String? idBackUrlMale;

  Uint8List? idFrontImageFeMale;
  Uint8List? idBackImageFeMale;
  String? idFrontUrlFeMale;
  String? idBackUrlFeMale;

  @override
  void dispose() {
    cardNoController.dispose();
    roomRentController.dispose();
    //vehicleNoController.dispose();
    extraChargeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    generateNextCardNo();
  }

  Future<void> generateNextCardNo() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('guests')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    String nextCard = 'a';

    if (snapshot.docs.isNotEmpty) {
      DateTime now = DateTime.now();

      DateTime lastDate =
      (snapshot.docs.first['date'] as Timestamp).toDate();

      bool isToday = lastDate.year == now.year &&
          lastDate.month == now.month &&
          lastDate.day == now.day;

      if (isToday) {
        String lastCard =
        snapshot.docs.first['card_no'].toString().toLowerCase();

        int ascii = lastCard.codeUnitAt(0);

        nextCard = ascii < 'z'.codeUnitAt(0)
            ? String.fromCharCode(ascii + 1)
            : 'a';
      } else {
        // New day starts from 'a'
        nextCard = 'a';
      }
    }

    setState(() {
      cardNoController.text = nextCard;
    });
  }

  Future<void> pickAndUploadImage({
    required bool isFront,
    required bool isMale,
  }) async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final fileBytes = await pickedFile.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${isMale ? "male" : "female"}_${isFront ? "front" : "back"}.jpg';

      final ref =
          FirebaseStorage.instance.ref().child('guest_ids').child(fileName);
      await ref.putData(fileBytes);
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        if (isMale) {
          if (isFront) {
            idFrontImageMale = fileBytes;
            idFrontUrlMale = downloadUrl;
          } else {
            idBackImageMale = fileBytes;
            idBackUrlMale = downloadUrl;
          }
        } else {
          if (isFront) {
            idFrontImageFeMale = fileBytes;
            idFrontUrlFeMale = downloadUrl;
          } else {
            idBackImageFeMale = fileBytes;
            idBackUrlFeMale = downloadUrl;
          }
        }
      });
    }
  }

  void saveGuestDetails() async {
    if (_formKey.currentState!.validate()) {
      if (idFrontUrlMale == null || idBackUrlMale == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Please take both front and back ID photos of Male.')),
        );
        return;
      }

      if (idFrontUrlFeMale == null || idBackUrlFeMale == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Please take both front and back ID photos of Female.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      String roomNo = _selectedRoomNo!;
      String cardNo = cardNoController.text.trim();

      DateTime now = DateTime.now();
      // DateTime date = DateTime(now.year, now.month, now.day);
      TimeOfDay time = TimeOfDay(hour: now.hour, minute: now.minute);
      String timeString = time.format(context);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('guests')
          .where('card_no', isEqualTo: cardNo)
          .where('date', isEqualTo: now)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('guests').add({
          'card_no': cardNo,
          'createdAt': FieldValue.serverTimestamp(),
          'room_no': roomNo,
          'room_rent': roomRentController.text.trim(),
          //'vehicle_no': vehicleNoController.text.trim(),
          'extra_charge': extraChargeController.text.trim(),
          'date': DateTime.now(),
          'time': timeString,
          'id_front_url_male': idFrontUrlMale,
          'id_back_url_male': idBackUrlMale,
          'id_front_url_female': idFrontUrlFeMale,
          'id_back_url_female': idBackUrlFeMale,
        });

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomNo)
            .set({'status': 'Occupied'}, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Guest details saved successfully!'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        _formKey.currentState!.reset();
        roomRentController.clear();
        //vehicleNoController.clear();
        extraChargeController.clear();
        await generateNextCardNo();

        setState(() {
          _selectedRoomNo = null;
          idFrontImageMale = null;
          idBackImageMale = null;
          idFrontUrlMale = null;
          idBackUrlMale = null;
          idFrontImageFeMale = null;
          idBackImageFeMale = null;
          idFrontUrlFeMale = null;
          idBackUrlFeMale = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Guest with the same card number already registered today!'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Center(
                child: Text('Guest Register',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            backgroundColor: Colors.blueAccent,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: TextFormField(
                        controller: cardNoController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Card No',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    _buildRoomDropdown(),
                    _buildTextField(
                        controller: roomRentController,
                        label: 'Room Rent',
                        validatorMsg: 'Please enter Room Rent',
                        keyboardType: TextInputType.number),
                    // _buildTextField(
                    //     controller: vehicleNoController, label: 'Vehicle No'),
                    _buildTextField(
                        controller: extraChargeController,
                        label: 'Extra Charge',
                        keyboardType: TextInputType.number),
                    SizedBox(height: 8.h),
                    Text("Take ID Photos",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    SizedBox(height: 8.h),
                    Text("Male",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            color: Colors.green)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              pickAndUploadImage(isFront: true, isMale: true),
                          child: const Text('Front Photo'),
                        ),
                        idFrontImageMale != null
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.photo_camera_back_outlined,
                                color: Colors.grey),
                        ElevatedButton(
                          onPressed: () =>
                              pickAndUploadImage(isFront: false, isMale: true),
                          child: const Text('Back Photo'),
                        ),
                        idBackImageMale != null
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.photo_camera_back_outlined,
                                color: Colors.grey),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text("FeMale",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            color: Colors.red)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              pickAndUploadImage(isFront: true, isMale: false),
                          child: const Text('Front Photo'),
                        ),
                        idFrontImageFeMale != null
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.photo_camera_back_outlined,
                                color: Colors.grey),
                        ElevatedButton(
                          onPressed: () =>
                              pickAndUploadImage(isFront: false, isMale: false),
                          child: const Text('Back Photo'),
                        ),
                        idBackImageFeMale != null
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.photo_camera_back_outlined,
                                color: Colors.grey),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: saveGuestDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              textStyle: TextStyle(fontSize: 16.sp),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14.sp),
        validator: validatorMsg != null
            ? (value) {
                if (value == null || value.isEmpty) {
                  return validatorMsg;
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildRoomDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: DropdownButtonFormField<String>(
        value: _selectedRoomNo,
        items: List.generate(
          12,
          (index) => DropdownMenuItem(
            value: (index + 1).toString(),
            child: Text('Room ${index + 1}', style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _selectedRoomNo = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Room No',
          border: const OutlineInputBorder(),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a room number';
          }
          return null;
        },
      ),
    );
  }
}
