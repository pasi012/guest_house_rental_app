import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateBookingScreen extends StatefulWidget {
  final DocumentSnapshot guest;

  const UpdateBookingScreen({super.key, required this.guest});

  @override
  _UpdateBookingScreenState createState() => _UpdateBookingScreenState();
}

class _UpdateBookingScreenState extends State<UpdateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController cardNoController;
  late TextEditingController idNoController;
  late TextEditingController roomRentController;
  late TextEditingController vehicleNoController;
  late TextEditingController extraChargeController;

  String? _selectedRoomNo;
  bool _isLoading = false; // Add this line

  @override
  void initState() {
    super.initState();
    cardNoController = TextEditingController(text: widget.guest['card_no']);
    idNoController = TextEditingController(text: widget.guest['id_no']);
    roomRentController = TextEditingController(text: widget.guest['room_rent']);
    vehicleNoController = TextEditingController(text: widget.guest['vehicle_no']);
    extraChargeController = TextEditingController(text: widget.guest['extra_charge']);
    _selectedRoomNo = widget.guest['room_no'];
  }

  @override
  void dispose() {
    cardNoController.dispose();
    idNoController.dispose();
    roomRentController.dispose();
    vehicleNoController.dispose();
    extraChargeController.dispose();
    super.dispose();
  }

  void updateGuestDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading state to true
      });

      String? oldRoomNo = widget.guest['room_no'];
      String newRoomNo = _selectedRoomNo!;

      try {
        // Update guest details in Firestore
        await FirebaseFirestore.instance
            .collection('guests')
            .doc(widget.guest.id)
            .update({
          'card_no': cardNoController.text,
          'id_no': idNoController.text,
          'room_no': newRoomNo,
          'room_rent': roomRentController.text,
          'vehicle_no': vehicleNoController.text,
          'extra_charge': extraChargeController.text,
        });

        // Update previous room status to 'Available' if it is different from the new room
        // if (oldRoomNo != newRoomNo) {
        //   await FirebaseFirestore.instance
        //       .collection('rooms')
        //       .doc(oldRoomNo)
        //       .set({'status': 'Available'}, SetOptions(merge: true));
        // }

        // Update new room status to 'Occupied'
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(newRoomNo)
            .set({'status': 'Occupied'}, SetOptions(merge: true));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guest details updated successfully!')),
        );

        // Navigate back after updating
        Navigator.of(context).pop();
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating details: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Set loading state to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Update Booking'),
            backgroundColor: Colors.blueAccent,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Update Booking Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 22.sp,
                                ),
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: TextFormField(
                              controller: cardNoController,
                              decoration: InputDecoration(
                                labelText: 'Card No',
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 14.sp),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Card No';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: TextFormField(
                              controller: idNoController,
                              decoration: InputDecoration(
                                labelText: 'NIC No',
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 14.sp),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter NIC No';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: DropdownButtonFormField<String>(
                              value: _selectedRoomNo,
                              items: List.generate(
                                12,
                                (index) => DropdownMenuItem(
                                  value: (index + 1).toString(),
                                  child: Text('Room ${index + 1}',
                                      style: TextStyle(fontSize: 14.sp)),
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
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a room number';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: TextFormField(
                              controller: roomRentController,
                              decoration: InputDecoration(
                                labelText: 'Room Rent',
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 14.sp),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Room Rent';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: TextFormField(
                              controller: vehicleNoController,
                              decoration: InputDecoration(
                                labelText: 'Vehicle No',
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: TextFormField(
                              controller: extraChargeController,
                              decoration: InputDecoration(
                                labelText: 'Extra Charge',
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          SizedBox(height: 30.h),
                          ElevatedButton(
                            onPressed: updateGuestDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              textStyle: TextStyle(fontSize: 16.sp),
                            ),
                            child: const Text(
                              'Update',
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
}
