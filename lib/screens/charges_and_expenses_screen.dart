import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChargesAndExpensesScreen extends StatefulWidget {
  const ChargesAndExpensesScreen({super.key});

  @override
  State<ChargesAndExpensesScreen> createState() => _ChargesAndExpensesScreenState();
}

class _ChargesAndExpensesScreenState extends State<ChargesAndExpensesScreen> {
  final TextEditingController extraDescController = TextEditingController();
  final TextEditingController extraAmountController = TextEditingController();

  final TextEditingController expenseDescController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();

  @override
  void dispose() {
    extraDescController.dispose();
    extraAmountController.dispose();
    expenseDescController.dispose();
    expenseAmountController.dispose();
    super.dispose();
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();

    return "${now.year}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> saveExtraCharge() async {
    if (extraDescController.text.trim().isEmpty ||
        extraAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('extra_charges').add({
        'description': extraDescController.text.trim(),
        'amount': double.parse(extraAmountController.text.trim()),
        'date': getCurrentDate(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      extraDescController.clear();
      extraAmountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Extra Charge Saved Successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> saveExpense() async {
    if (expenseDescController.text.trim().isEmpty ||
        expenseAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'description': expenseDescController.text.trim(),
        'amount': double.parse(expenseAmountController.text.trim()),
        'date': getCurrentDate(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      expenseDescController.clear();
      expenseAmountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Expense Saved Successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController descController,
    required TextEditingController amountController,
    required VoidCallback onSave,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 30.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25.h),
            buildTextField(
              controller: descController,
              hint: "Description",
              icon: Icons.description,
            ),
            SizedBox(height: 15.h),
            buildTextField(
              controller: amountController,
              hint: "Amount",
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check),
                label: const Text("SAVE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: Text(
          "Charges",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth > 700;

            return isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildSection(
                          title: "Extra Charge",
                          icon: Icons.add_circle_outline,
                          color: Colors.blue,
                          descController: extraDescController,
                          amountController: extraAmountController,
                          onSave: saveExtraCharge,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: buildSection(
                          title: "Expenses",
                          icon: Icons.money_off_outlined,
                          color: Colors.red,
                          descController: expenseDescController,
                          amountController: expenseAmountController,
                          onSave: saveExpense,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      buildSection(
                        title: "Extra Charge",
                        icon: Icons.add_circle_outline,
                        color: Colors.blue,
                        descController: extraDescController,
                        amountController: extraAmountController,
                        onSave: saveExtraCharge,
                      ),
                      SizedBox(height: 20.h),
                      buildSection(
                        title: "Expenses",
                        icon: Icons.money_off_outlined,
                        color: Colors.red,
                        descController: expenseDescController,
                        amountController: expenseAmountController,
                        onSave: saveExpense,
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
