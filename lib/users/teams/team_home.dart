import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:nam_football/admin/teams/payer_list.dart';
import 'package:nam_football/admin/teams/player_form.dart';

class TeamHomeUsr extends StatefulWidget {
  const TeamHomeUsr({super.key});

  @override
  State<TeamHomeUsr> createState() => _TeamHomeState();
}

class _TeamHomeState extends State<TeamHomeUsr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Namibia Premier League Football Teams',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                // Example of one team logo button
                teamLogoButton(
                  'images/af_stars.png', // Path to your logo image
                  () {
                    Get.to(() => const PlayerList());
                    // Navigate to team details or any other action
                    const BulkPlayerForm();
                  },
                ),
                teamLogoButton(
                  'images/blue-wat.png', // Path to your logo image
                  () {
                    print('Clicked team 2');
                  },
                ),
                teamLogoButton(
                  'images/blueboys.png', // Path to your logo image
                  () {
                    print('Clicked team 3');
                  },
                ),
                teamLogoButton(
                  'images/cucat.png', // Path to your logo image
                  () {
                    print('Clicked team 4');
                  },
                ),
                teamLogoButton(
                  'images/eshoke-c.png', // Path to your logo image
                  () {
                    print('Clicked team 5');
                  },
                ),
                teamLogoButton(
                  'images/jsfc.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/k-nampol.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/kkpalace.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/mgunners.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/okaunit.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/ongos.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/orlanp.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/tigers.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/unam .png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/youngaf.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
                teamLogoButton(
                  'images/youngb.png', // Path to your logo image
                  () {
                    print('Clicked team 6');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget teamLogoButton(String imagePath, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(imagePath),
        ),
      ),
    ),
  );
}

}
