import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GuestRegisterScreen extends StatefulWidget {
  const GuestRegisterScreen({super.key});

  @override
  _GuestRegisterScreenState createState() => _GuestRegisterScreenState();
}

class _GuestRegisterScreenState extends State<GuestRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNoController = TextEditingController();
  final TextEditingController idNoController = TextEditingController();
  final TextEditingController roomRentController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController extraChargeController = TextEditingController();

  String? _selectedRoomNo;
  bool _isLoading = false; // Track loading state

  @override
  void dispose() {
    cardNoController.dispose();
    idNoController.dispose();
    roomRentController.dispose();
    vehicleNoController.dispose();
    extraChargeController.dispose();
    super.dispose();
  }

  void saveGuestDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      String roomNo = _selectedRoomNo!;
      String cardNo = cardNoController.text.trim();
      String idNo = idNoController.text.trim();

      DateTime now = DateTime.now();
      DateTime date = DateTime(now.year, now.month, now.day);
      TimeOfDay time = TimeOfDay(hour: now.hour, minute: now.minute);
      String timeString = time.format(context);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('guests')
          .where('card_no', isEqualTo: cardNo)
          .where('date', isEqualTo: date)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('guests').add({
          'card_no': cardNo,
          'id_no': idNo,
          'room_no': roomNo,
          'room_rent': roomRentController.text.trim(),
          'vehicle_no': vehicleNoController.text.trim(),
          'extra_charge': extraChargeController.text.trim(),
          'date': date,
          'time': timeString,
        });

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomNo)
            .set({'status': 'Occupied'}, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guest details saved successfully!')),
        );

        _formKey.currentState!.reset();
        cardNoController.clear();
        idNoController.clear();
        roomRentController.clear();
        vehicleNoController.clear();
        extraChargeController.clear();
        setState(() {
          _selectedRoomNo = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guest with the same card number already registered today.')),
        );
      }

      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Guest Register'),
            backgroundColor: Colors.blueAccent,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Register New Guest',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(controller: cardNoController, label: 'Card No', validatorMsg: 'Please enter Card No'),
                    _buildTextField(controller: idNoController, label: 'NIC No', validatorMsg: 'Please enter NIC No'),
                    _buildRoomDropdown(),
                    _buildTextField(controller: roomRentController, label: 'Room Rent', validatorMsg: 'Please enter Room Rent', keyboardType: TextInputType.number),
                    _buildTextField(controller: vehicleNoController, label: 'Vehicle No'),
                    _buildTextField(controller: extraChargeController, label: 'Extra Charge', keyboardType: TextInputType.number),
                    SizedBox(height: 30.h),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
