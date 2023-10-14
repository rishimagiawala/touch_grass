import 'dart:convert';
import 'dart:io';

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

import 'package:camera/camera.dart';

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

// Future<CameraDescription> getAvailableCamera() async {
//   // Obtain a list of the available cameras on the device.
//   final cameras = await availableCameras();

//   // Get a specific camera from the list of available cameras.
//   return cameras.first;
// }
late CameraDescription firstCamera;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  firstCamera = cameras.first;

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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Container(
                  child: Image.file(File(image.path)),
                  height: 120,
                  width: 120,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Image.file(File(imagePath)),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Check us out on GitHub',
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        //getAvailableCamera()
                        const NavigationExample()),
                (Route route) => false);
          },
          child: const FaIcon(FontAwesomeIcons.github),
        ));
  }
}

class _NavigationExampleState extends State<NavigationExample> {
  //final firstCamera = cameras.first;
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: currentPageIndex == 2
          ? FloatingActionButton(
              tooltip: 'Check us out on GitHub',
              onPressed: () {
                if (currentPageIndex == 2) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) =>
                              //getAvailableCamera()
                              TakePictureScreen(camera: firstCamera)),
                      (Route route) => false);
                }
              },
              child: const FaIcon(FontAwesomeIcons.github),
            )
          : null,
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
        Placeholder(),
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
