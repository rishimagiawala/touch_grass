import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:touch_grass/components/FeedCard.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<UserCredential> signInWithGoogle() async {
  print("This was called");
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  await FirebaseAuth.instance.signInWithCredential(credential);
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document exists on the database');
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.email)
            .set({
          'uid': FirebaseAuth.instance.currentUser?.uid,
          'displayName': FirebaseAuth.instance.currentUser?.displayName,
          'photoUrl': FirebaseAuth.instance.currentUser?.photoURL,
          'drafts': []
        });
      }
    });
  }
  // Once signed in, return the UserCredential
  return FirebaseAuth.instance.signInWithCredential(credential);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final lightThemeStr =
      await rootBundle.loadString('assets/appainter_light_theme.json');
  final lightThemeJson = jsonDecode(lightThemeStr);
  final lightTheme = ThemeDecoder.decodeThemeData(lightThemeJson)!;
  final darkThemeStr =
      await rootBundle.loadString('assets/appainter_dark_theme.json');
  final darkThemeJson = jsonDecode(darkThemeStr);
  final darkTheme = ThemeDecoder.decodeThemeData(darkThemeJson)!;
  runApp(MyApp(lightTheme: lightTheme, darkTheme: darkTheme));
}

class MyApp extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  const MyApp({super.key, required this.lightTheme, required this.darkTheme});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Touch Grass",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: "Pacifico",
                  color: const Color.fromRGBO(62, 106, 0, 1)),
            ),
            const SizedBox(
              height: 30,
            ),
            const Card(
              elevation: 14.0,
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: Image(
                image: AssetImage('assets/images/logo.jpg'),
                width: 280,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            OutlinedButton.icon(
                onPressed: () async {
                  await signInWithGoogle();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const NavigationExample()),
                      (Route route) => false);
                },
                icon: const FaIcon(FontAwesomeIcons.google),
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15)),
                label: const Text("Login with Google")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Check us out on GitHub',
        onPressed: () {},
        child: const FaIcon(FontAwesomeIcons.github),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Touch Grass",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: "Pacifico",
              color: const Color.fromRGBO(62, 106, 0, 1)),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.data_exploration_outlined),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            label: 'Find Grass',
          ),
          NavigationDestination(
            icon: Icon(Icons.diversity_1_outlined),
            label: 'Feed',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          alignment: Alignment.center,
          child: const Text('Page 1'),
        ),
        const Discover(),
        ListView(
          children: const [
            FeedCard(
                name: 'Donald Glover',
                picUrl:
                    'https://th.bing.com/th/id/OIG.KjRSRH87v0JTie8aIPyW?pid=ImgGn',
                timestamp: '8:00pm',
                location: 'NYC',
                postImgUrl:
                    'https://th.bing.com/th/id/OIG.KjRSRH87v0JTie8aIPyW?pid=ImgGn')
          ],
        ),
      ][currentPageIndex],
    );
  }
}

class Discover extends StatefulWidget {
  const Discover({
    super.key,
  });

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  final Future<Position> _position = _determinePosition();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: _position,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text('Result: ${snapshot.data}');
        } else if (snapshot.hasError) {
          return Text('Result: ${snapshot.error}');
        } else {
          return const Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: SpinKitCubeGrid(
                color: Color.fromRGBO(62, 106, 0, 1),
                size: 100,
              ),
            ),
          );
        }
      },
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position location = await Geolocator.getCurrentPosition();
  double long = location.longitude;
  double lat = location.latitude;

  return await Geolocator.getCurrentPosition();
}
