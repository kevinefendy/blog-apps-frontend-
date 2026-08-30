import 'package:flutter/material.dart';

// Import halaman lain biar bisa pindah-pindah
import 'package:project_rpl5/pages/homePage.dart';
import 'package:project_rpl5/navigation/profile.dart';
import 'package:project_rpl5/navigation/search.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; 

 @override
  Widget build(BuildContext context) {
    // final data = 
    //   ModalRoute.of(context) !.settings.arguments as Map<String, dynamic>;

    // final nama = data["nama"];
    // final umur = data["umur"];

    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar (
        title: const Text("Profile"),
      ),
      // body: ListView(
      //   children: [
      //     Text("Home"),
      //     Text("Kevin"),Text("Umur")
      //   ],
      // ),

      body: Center(
        child: Text("data"),
      ),
      bottomNavigationBar: BottomNavigationBar(

        
        selectedItemColor: Colors.blue,      // Warna ikon saat dipilih
        unselectedItemColor: Colors.blueAccent,

        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          label: "home",
          
          ),
          BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: "Profile",
          ),
          BottomNavigationBarItem(
      icon: Icon(Icons.search), 
      label: "Seacrh",
          ),
          BottomNavigationBarItem(
      icon: Icon(Icons.notification_add), 
      label: "Notification",
          ),
          
        ],

        onTap: (int index) {
          if (index == 0) {
            return; // Kalau klik Home, tetap di sini
          }

          setState(() {
          });

          // Pindah halaman pakai Navigator.push
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          
            
          }
        },
        

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