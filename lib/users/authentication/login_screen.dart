import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nam_football/admin/home_page.dart';
import 'package:nam_football/users/authentication/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isObsecure = true.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login Method using Firebase Auth
  Future<void> _login() async {
    if (formKey.currentState!.validate()) {
      try {
        // Sign in with email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // On successful login, navigate to home page
        Get.off(() => const HomeNews());

      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided for that user.';
            break;
          default:
            errorMessage = 'Login failed. Please try again later.';
        }
        Get.snackbar('Error', errorMessage,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  // Login Screen Header
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 285,
                    child: Image.asset("images/trip.jpg"),
                  ),
                  // Login Screen Sign-In Form
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildLoginContainer(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black26,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 8),
        child: Column(
          children: [
            _buildLoginForm(),
            const SizedBox(height: 16),
            _buildRegisterRow(),
            const Text(
              "Or",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            _buildAdminLoginRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: 18),
          _buildPasswordField(),
          const SizedBox(height: 18),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      validator: (val) => val == "" ? "Please write email" : null,
      decoration: _buildInputDecoration(
        icon: Icons.email,
        hintText: "Email...",
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextFormField(
        controller: passwordController,
        obscureText: isObsecure.value,
        validator: (val) => val == "" ? "Please write password" : null,
        decoration: _buildInputDecoration(
          icon: Icons.vpn_key_sharp,
          hintText: "Password...",
          suffixIcon: GestureDetector(
            onTap: () {
              isObsecure.value = !isObsecure.value;
            },
            child: Icon(
              isObsecure.value ? Icons.visibility_off : Icons.visibility,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required IconData icon, String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: suffixIcon,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white60),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      fillColor: Colors.white,
      filled: true,
    );
  }

  Widget _buildLoginButton() {
    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: _login,
        borderRadius: BorderRadius.circular(30),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 28),
          child: Text(
            "Login",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an Account?"),
        TextButton(
          onPressed: () {
            Get.to(() => SignUpScreen());
          },
          child: const Text(
            "Register here",
            style: TextStyle(color: Colors.limeAccent, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Are you an admin?"),
        TextButton(
          onPressed: () {
            Get.to(() => const HomeNews());
          },
          child: const Text(
            "Click here",
            style: TextStyle(color: Colors.limeAccent, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
