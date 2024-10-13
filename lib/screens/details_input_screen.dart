import 'package:connectuser/model/user.dart';
import 'package:connectuser/provider/login_provider.dart';
import 'package:connectuser/screens/home_screen.dart';
import 'package:connectuser/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailsInputScreen extends StatefulWidget {
  final User user;

  const DetailsInputScreen({super.key, required this.user});

  @override
  State<DetailsInputScreen> createState() => _DetailsInputScreenState();
}

class _DetailsInputScreenState extends State<DetailsInputScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController introController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedGender;
  final List<String> genders = ['Male', 'Female', 'Others'];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: const Color(0xffede0d4),
      ),
      body: Consumer<LoginProvider>(
        builder: (context, provider, child) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Fill Details \nto Find your match.",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff9c66440)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: ageController,
                    labelText: 'Age',
                    isDigit: true,
                    validator: (value) {
                      final age = int.tryParse(value ?? '');
                      if (age == null || age < 13 || age > 100) {
                        return 'Age must be between 13 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      errorStyle: const TextStyle(color: Color(0xFF7F5539)),
                      labelStyle: const TextStyle(color: Color(0xFF7F5539)),
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFDDB892), width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF7F5539), width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF7F5539), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF7F5539), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: selectedGender,
                    items: genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Gender is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: introController,
                    labelText: 'Introduction',
                    maxLength: 200,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduction is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: jobController,
                    labelText: 'Job',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Job is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: countryController,
                    labelText: 'Country',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Country is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: areaController,
                    labelText: 'Area',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Area is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descriptionController,
                    labelText: 'Description',
                    maxLength: 300,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        widget.user.name = nameController.text;
                        widget.user.age = int.tryParse(ageController.text);
                        widget.user.gender = selectedGender;
                        widget.user.intro = introController.text;
                        widget.user.job = jobController.text;
                        widget.user.country = countryController.text;
                        widget.user.area = areaController.text;
                        widget.user.description = descriptionController.text;

                        bool isSuccess =
                            await provider.updateDetails(user: widget.user);

                        if (isSuccess) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen(
                                      isSignin: true,
                                    )),
                            (route) => false,
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE6CCB2),
                      fixedSize: const Size(200, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text(
                      "Find your matches",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff9c6644)),
                    ),
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
