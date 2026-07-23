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
  late TextEditingController roomRentController;
  //late TextEditingController vehicleNoController;
  late TextEditingController extraChargeController;

  String? _selectedRoomNo;
  bool _isLoading = false;

  late String maleIdFrontUrl;
  late String maleIdBackUrl;
  late String femaleIdFrontUrl;
  late String femaleIdBackUrl;

  @override
  void initState() {
    super.initState();
    cardNoController = TextEditingController(text: widget.guest['card_no']);
    roomRentController = TextEditingController(text: widget.guest['room_rent']);
    //vehicleNoController = TextEditingController(text: widget.guest['vehicle_no']);
    extraChargeController =
        TextEditingController(text: widget.guest['extra_charge']);
    _selectedRoomNo = widget.guest['room_no'];

    final data = widget.guest.data() as Map<String, dynamic>;

    maleIdFrontUrl = data['id_front_url_male'] ?? data['id_front_url'] ?? '';
    maleIdBackUrl = data['id_back_url_male'] ?? data['id_back_url'] ?? '';
    femaleIdFrontUrl = data['id_front_url_female'] ?? '';
    femaleIdBackUrl = data['id_back_url_female'] ?? '';
  }

  @override
  void dispose() {
    cardNoController.dispose();
    roomRentController.dispose();
    //vehicleNoController.dispose();
    extraChargeController.dispose();
    super.dispose();
  }

  void updateGuestDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String newRoomNo = _selectedRoomNo!;

      try {
        await FirebaseFirestore.instance
            .collection('guests')
            .doc(widget.guest.id)
            .update({
          'card_no': cardNoController.text,
          'room_no': newRoomNo,
          'room_rent': roomRentController.text,
          //'vehicle_no': vehicleNoController.text,
          'extra_charge': extraChargeController.text,
        });

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(newRoomNo)
            .set({'status': 'Occupied'}, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest details updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating details: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget buildIdPhoto(String label, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: () => _showLargeImage(imageUrl),
                child: Image.network(
                  imageUrl,
                  height: 150.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              )
            : const Text('No image available'),
        SizedBox(height: 16.h),
      ],
    );
  }

  void _showLargeImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
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
                ? const Center(child: CircularProgressIndicator())
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

                          /// Card No
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
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter Card No'
                                      : null,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),

                          /// Room No
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
                              onChanged: (value) => setState(() {
                                _selectedRoomNo = value;
                              }),
                              decoration: InputDecoration(
                                labelText: 'Room No',
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select a room number'
                                      : null,
                            ),
                          ),

                          /// Room Rent
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
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter Room Rent'
                                      : null,
                            ),
                          ),

                          /// Vehicle No
                          // Padding(
                          //   padding: EdgeInsets.only(bottom: 16.h),
                          //   child: TextFormField(
                          //     controller: vehicleNoController,
                          //     decoration: InputDecoration(
                          //       labelText: 'Vehicle No',
                          //       border: const OutlineInputBorder(),
                          //       contentPadding: EdgeInsets.symmetric(
                          //           horizontal: 16.w, vertical: 12.h),
                          //     ),
                          //     keyboardType: TextInputType.text,
                          //     style: TextStyle(fontSize: 14.sp),
                          //   ),
                          // ),

                          /// Extra Charge
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

                          /// ID Photos male
                          buildIdPhoto('Male ID Front Photo', maleIdFrontUrl),
                          buildIdPhoto('Male ID Back Photo', maleIdBackUrl),

                          //Id Photos Female
                          if (femaleIdFrontUrl.isNotEmpty || femaleIdBackUrl.isNotEmpty) ...[
                            buildIdPhoto('Female ID Front Photo', femaleIdFrontUrl),
                            buildIdPhoto('Female ID Back Photo', femaleIdBackUrl),
                          ],

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: updateGuestDetails,
            label: const Text('Update'),
            icon: const Icon(Icons.update),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}
