import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nam_football/admin/matches/matchdata.dart';
import 'package:nam_football/services/database.dart';
import 'package:random_string/random_string.dart';

class Fixtures extends StatefulWidget {
  const Fixtures({super.key});

  @override
  State<Fixtures> createState() => _FixturesState();
}

class _FixturesState extends State<Fixtures> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController homeTeamController = TextEditingController();
  final TextEditingController awayTeamController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add new Fixtures",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                controller: dateController,
                label: 'Date',
                hint: 'Enter date (e.g., 2024-09-02)',
                icon: Icons.calendar_today,
                isDate: true,
              ),
              buildTextField(
                controller: timeController,
                label: 'Time',
                hint: 'Enter time (e.g., 14:00)',
                icon: Icons.access_time,
                isTime: true,
              ),
              buildTextField(
                controller: homeTeamController,
                label: 'Home Team',
                hint: 'Enter home team name',
                icon: Icons.home,
              ),
              buildTextField(
                controller: awayTeamController,
                label: 'Away Team',
                hint: 'Enter away team name',
                icon: Icons.group,
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Input validation
                    if (dateController.text.isEmpty ||
                        timeController.text.isEmpty ||
                        homeTeamController.text.isEmpty ||
                        awayTeamController.text.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "All fields must be filled",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      return;
                    }

                    // Validate both teams against logstand data
                    bool homeTeamExists =
                        await ensureTeamExists(homeTeamController.text);
                    bool awayTeamExists =
                        await ensureTeamExists(awayTeamController.text);

                    if (!homeTeamExists || !awayTeamExists) {
                      // Stop form submission if any team does not exist
                      return;
                    }

                    // Proceed with form submission if validation passes
                    String id = randomAlphaNumeric(10);

                    Map<String, dynamic> fixtureMap = {
                      "id": id,
                      "date": dateController.text,
                      "time": timeController.text,
                      "homeTeam": homeTeamController.text,
                      "awayTeam": awayTeamController.text,
                    };

                    try {
                      await DatabaseMethods().addFixtures(fixtureMap, id);
                      Fluttertoast.showToast(
                        msg: "Fixture data entered successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      // Navigate to the MatchDatas screen
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MatchDatas()),
                      );
                    } catch (e) {
                      print("Error: $e");
                      Fluttertoast.showToast(
                        msg: "Failed to enter fixture data",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: const Text('Save Fixture'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isDate = false,
    bool isTime = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        readOnly: isDate || isTime, // Prevent typing for date/time fields
        onTap: () async {
          if (isDate) {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text =
                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
              });
            }
          } else if (isTime) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              setState(() {
                controller.text = "${pickedTime.hour}:${pickedTime.minute}";
              });
            }
          }
        },
      ),
    );
  }

  // Validate if team exists in the logstand table
  Future<bool> ensureTeamExists(String teamName) async {
    var teamDoc = await DatabaseMethods()
        .teamCollection
        .where('Team Name', isEqualTo: teamName)
        .get();

    if (teamDoc.docs.isEmpty) {
      Fluttertoast.showToast(
        msg: "$teamName does not exist in the log standings",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    homeTeamController.dispose();
    awayTeamController.dispose();
    super.dispose();
  }
}
