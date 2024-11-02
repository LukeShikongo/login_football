import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nam_football/admin/stats/logstand.dart';
import 'package:nam_football/services/database.dart';
import 'package:random_string/random_string.dart';

class Logstand extends StatefulWidget {
  const Logstand({super.key});

  @override
  State<Logstand> createState() => _LogstandState();
}

class _LogstandState extends State<Logstand> {
  TextEditingController teamnamecontroller = TextEditingController();
  TextEditingController matchplayedcontroller = TextEditingController();
  TextEditingController matchwoncontroller = TextEditingController();
  TextEditingController matchdrawcontroller = TextEditingController();
  TextEditingController matchlostcontroller = TextEditingController();
  TextEditingController goaldiferencecontroller = TextEditingController();
  TextEditingController pointscontroller = TextEditingController();
  
  // Add GlobalKey to handle form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Log stand form",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, top: 30.0, right: 28.0),
        child: Form(
          key: _formKey, // Attach the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Team Name",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: teamnamecontroller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Team name is required';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10.0),
              const Text(
                "Match Played",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: matchplayedcontroller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Matches played are required';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10.0),
              const Text(
                "Match Won",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: matchwoncontroller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Matches won are required';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10.0),
              const Text(
                "Match Draw",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: matchdrawcontroller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Matches drawn are required';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10.0),
              const Text(
                "Match Lost",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: matchlostcontroller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Matches lost are required';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10.0),
              const Text(
                "Goal Difference",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: goaldiferencecontroller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Goal difference is required';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10.0),
              const Text(
                "Points",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: pointscontroller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Points are required';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 30.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String id = randomAlphaNumeric(10);

                      Map<String, dynamic> teamInfoMap = {
                        "Id": id,
                        "Team Name": teamnamecontroller.text,
                        "Match played": matchplayedcontroller.text,
                        "Match won": matchwoncontroller.text,
                        "Match drawn": matchdrawcontroller.text,
                        "Match lost": matchlostcontroller.text,
                        "Goal difference": goaldiferencecontroller.text,
                        "Points": pointscontroller.text,
                      };

                      try {
                        await DatabaseMethods().addTeamDetails(teamInfoMap, id);
                        Fluttertoast.showToast(
                          msg: "Team data entered successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        // Navigate to the LogStandTable screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LogstandData()),
                        );
                      } catch (e) {
                        print("Error: $e");
                        Fluttertoast.showToast(
                          msg: "Failed to enter team data",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
