import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nam_football/api_connection/api_connection.dart';
import 'package:nam_football/users/authentication/login_screen.dart';
import 'package:nam_football/users/model/user.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isObsecure = true.obs;

  // validateUserEmail() async {
  //   try {
  //     var res = await http.post(
  //       Uri.parse(API.validateEmail),
  //       body: {
  //         "user_email": emailController.text.trim(),
  //       },
  //     );
  //     if (res.statusCode == 200) {
  //       var resBodyOfValidateEmail = jsonDecode(res.body);
  //       if (resBodyOfValidateEmail['emailFound'] == true) {
  //         Fluttertoast.showToast(msg: "Email is already in use");
  //       } else {
  //         // Register a new user to the database
  //         registersaveUserRecord();
  //       }
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Error: $e");
  //   }
  // }

validateUserEmail() async{
    try{
      var res = await http.post(
       Uri.parse( 'http://192.168.249.163/api_football/user/validate_email'),
       body: {
        "user_email": emailController.text.trim(),
       }
      );
      if(res.statusCode == 200){
        var resBodyOfValidateEmail = jsonDecode(res.body);

        if(resBodyOfValidateEmail['emailFound'] == true){

          Fluttertoast.showToast(msg: "Email is already in use");
        }
        else{
          // register a new user to a database
          registersaveUserRecord();
        }
      }

    }catch(e){
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }


  registersaveUserRecord() async {
  User userModel = User(
    1,
    nameController.text.trim(),
    emailController.text.trim(),
    passwordController.text.trim(),
  );

  try {
    // Print the URL to debug
    print("API URL: ${API.signUp}");
    
    var res = await http.post(
      Uri.parse(API.signUp), // Ensure this URL is correctly formatted
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userModel.toJson()), // Ensure this is jsonEncode
    );

    if (res.statusCode == 200) {
      var resBodyOfSignUp = jsonDecode(res.body);
      if (resBodyOfSignUp['success'] == true) {
        Fluttertoast.showToast(msg: "You have signed up successfully");
      } else {
        Fluttertoast.showToast(msg: "Error occurred, try again");
      }
    } else {
      Fluttertoast.showToast(msg: "Server Error: ${res.statusCode}");
    }
  } catch (e) {
    print(e.toString());
    Fluttertoast.showToast(msg: e.toString());
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // SignUp Screen header
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 285,
                    child: Image.asset("images/signup.jpeg"),
                  ),

                  // SignUp Screen Form
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.all(
                          Radius.circular(60),
                        ),
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
                            // email, password and button
                            Form(
                              key: formKey,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(30, 30, 30, 8),
                                child: Column(
                                  children: [
                                    // Name text field
                                    TextFormField(
                                      controller: nameController,
                                      validator: (val) => val == "" ? "Please write name" : null,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Colors.black,
                                        ),
                                        hintText: "Name...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(),
                                        disabledBorder: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    // Email text field
                                    TextFormField(
                                      controller: emailController,
                                      validator: (val) => val == "" ? "Please write email" : null,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.email,
                                          color: Colors.black,
                                        ),
                                        hintText: "Email...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(),
                                        disabledBorder: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    // Password text field
                                    Obx(
                                      () => TextFormField(
                                        controller: passwordController,
                                        obscureText: isObsecure.value,
                                        validator: (val) => val == "" ? "Please write password" : null,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                            Icons.vpn_key_sharp,
                                            color: Colors.black,
                                          ),
                                          suffixIcon: Obx(
                                            () => GestureDetector(
                                              onTap: () {
                                                isObsecure.value = !isObsecure.value;
                                              },
                                              child: Icon(
                                                isObsecure.value ? Icons.visibility_off : Icons.visibility,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          hintText: "Password...",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30),
                                            borderSide: const BorderSide(
                                              color: Colors.white60,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(),
                                          disabledBorder: OutlineInputBorder(),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    // SignUp button
                                    Material(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(30),
                                      child: InkWell(
                                        onTap: () {
                                          if (formKey.currentState!.validate()) {
                                            // Validate the user email
                                            validateUserEmail();
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(30),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 28,
                                          ),
                                          child: Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Already have an account text button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an Account?"),
                                TextButton(
                                  onPressed: () {
                                    Get.to(() => LoginScreen());
                                  },
                                  child: const Text(
                                    "Sign In here",
                                    style: TextStyle(
                                      color: Colors.limeAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
