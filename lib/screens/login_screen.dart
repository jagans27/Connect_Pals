import 'dart:ui';
import 'package:connectuser/model/user.dart';
import 'package:connectuser/provider/login_provider.dart';
import 'package:connectuser/screens/details_input_screen.dart';
import 'package:connectuser/screens/home_screen.dart';
import 'package:connectuser/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, provider, child) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/image/background.png"),
            ),
          ),
          child: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(16.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "ConnectPals",
                            style: TextStyle(
                              color: Color.fromARGB(255, 91, 88, 87),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          provider.isLogin
                              ? 'Welcome Back! Let\'s Get You Logged In'
                              : 'Join the Community—Sign Up Today!',
                          style: const TextStyle(
                            color: Color(0xff9c6644),
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          obscureText: true,
                          validator: !provider.isLogin
                              ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your password';
                                  }
                                  if (value.length < 8) {
                                    return 'Min 8 characters';
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    return 'Include an uppercase letter';
                                  }
                                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                                    return 'Include a lowercase letter';
                                  }
                                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                                    return 'Include a number';
                                  }
                                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                      .hasMatch(value)) {
                                    return 'Include a special character';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                        if (!provider.isLogin) const SizedBox(height: 16.0),
                        if (!provider.isLogin)
                          CustomTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm Password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 32.0),
                        FilledButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              User user = User(
                                  email: _emailController.text,
                                  password: _passwordController.text);

                              if (provider.isLogin) {
                                User? userData =
                                    await provider.login(user: user);

                                if (userData != null) {
                                  if (userData.name == null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsInputScreen(
                                                  user: userData,
                                                )));
                                  } else {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen()));
                                  }
                                }
                              } else {
                                bool isSuccess =
                                    await provider.signUp(user: user);

                                if (isSuccess) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetailsInputScreen(user: user)));
                                }
                              }
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE6CCB2),
                            fixedSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          child: Text(
                            provider.isLogin ? 'Login' : 'Sign Up',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff9c6644)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: provider.toggleForm,
                          child: Text(
                            provider.isLogin
                                ? 'Don\'t have an account? Sign Up'
                                : 'Already have an account? Login',
                            style: const TextStyle(color: Color(0xFF7F5539)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
