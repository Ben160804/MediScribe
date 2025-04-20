import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/component_controllers/language_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController dobController = TextEditingController();
  final LanguageController langController = Get.find();

  String? userName;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = userDoc.data()?['name'] ?? 'User';
        userEmail = user.email;
        userPhone = userDoc.data()?['phone'] ?? user.phoneNumber ?? '';
      });
    }
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  String t(String key) {
    final translations = {
      'profile': {'en': 'Profile', 'bn': 'প্রোফাইল'},
      'your_email': {'en': 'Your Email', 'bn': 'আপনার ইমেইল'},
      'phone_number': {'en': 'Phone Number', 'bn': 'ফোন নম্বর'},
      'dob': {'en': 'Date of Birth', 'bn': 'জন্মতারিখ'},
      'select_dob': {'en': 'Select your DOB', 'bn': 'জন্মতারিখ নির্বাচন করুন'},
    };

    return translations[key]?[langController.selectedLanguage.value] ??
        translations[key]?['en'] ??
        key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9575CD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9575CD),
        elevation: 0,
        title: Text(
          t(''),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (value) {
              langController.selectLanguage(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'bn', child: Text('বাংলা')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/avtar.jpg'),
                  backgroundColor: Color(0xFF9575CD),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userName ?? 'User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: ListView(
                    children: [
                      ReadOnlyProfileField(
                        label: t('your_email'),
                        icon: Icons.email_outlined,
                        value: userEmail ?? '',
                      ),
                      ReadOnlyProfileField(
                        label: t('phone_number'),
                        icon: Icons.phone,
                        value: userPhone ?? '',
                      ),
                      DOBField(
                        label: t('dob'),
                        hint: t('select_dob'),
                        controller: dobController,
                        onTap: () => _selectDOB(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReadOnlyProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

  const ReadOnlyProfileField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class DOBField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;

  const DOBField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
