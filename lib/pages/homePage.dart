import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:project_rpl5/navigation/profile.dart';
import 'package:project_rpl5/navigation/search.dart';
import 'package:project_rpl5/navigation/notification.dart';
class HomePage extends StatefulWidget {

  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final data = 
    //   ModalRoute.of(context) !.settings.arguments as Map<String, dynamic>;

    // final nama = data["nama"];
    // final umur = data["umur"];

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar (
        
        title: const Text("HomePage"),
      ),
      // body: ListView(
      //   children: [
      //     Text("Home"),
      //     Text("Kevin"),Text("Umur")
      //   ],
      // ),

      body: ListView(
        children:[
          Image.asset('assets/images/Aksara.png'),
          Text(
            "Sampusaun",
            style: GoogleFonts.poppins(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.yellow
            ),
            
          ),
        ]
      ),
      bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
              selectedColor: Colors.purple,
            ),

            /// Likes
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite_border),
              title: Text("Likes"),
              selectedColor: Colors.pink,
            ),

            /// Search
            SalomonBottomBarItem(
              icon: Icon(Icons.search),
              title: Text("Search"),
              selectedColor: Colors.orange,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: Icon(Icons.person),
              title: Text("Profile"),
              selectedColor: Colors.teal,
            ),
          ],
        ),
    );
  }
}


class UserTile extends StatelessWidget {
  final String nama;
  final String? job;

  const UserTile({
    super.key,
    required this.nama,
    this.job
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(nama),
      subtitle: Text(job == null ? "": job.toString()),
      leading: Icon(Icons.person),
      trailing: Icon(Icons.menu),
    
    );
  }
}
// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
  
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("HomePage")),
//       body: ListView(
//         children: [
//           userTile(nama: "daep", job: "ui/ux"),
//           userTile(nama: "koma", job: "PM"),
//           userTile(nama: "digar", job: "Fullstack"),
//           userTile(nama: "jr", job: "frontEnd"),
//           userTile(nama: "parat",),
//           ],
//       ),
//     );
//   }
// }

// class userTile extends StatelessWidget {
//   final String nama;
//   final String? job;

//   const userTile({super.key, required this.nama, this.job});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(nama.toString()),
//       subtitle: Text(job == null ? "ngangur" : job.toString()),
//       leading: Icon(Icons.person),
//       trailing: Icon(Icons.menu),
//     );
//   }
// }