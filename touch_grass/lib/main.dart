import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:touch_grass/components/FeedCard.dart';
import 'package:touch_grass/components/TakePictureScreen.dart';
import 'package:touch_grass/firebaseFunctions.dart';

import 'components/Friends.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late double long;
late double lat;

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
          'friends': [],
          'posts': [
            {
              'imgUrl':
                  'https://th.bing.com/th/id/OIG.s7C78UUTe0gbPGRH2UdB?pid=ImgGn',
              'name': 'Welcome to Touch Grass',
              'timestamp': Timestamp.now(),
              'location': 'HackGT',
              'numOfLikes': 0,
              'grass_points': 1,
              'photoUrl': FirebaseAuth.instance.currentUser?.photoURL
            }
          ],
          'grassPoints': 1
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
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

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
  runApp(MyApp(
    lightTheme: lightTheme,
    darkTheme: darkTheme,
    camera: firstCamera,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final CameraDescription camera;
  const MyApp(
      {super.key,
      required this.lightTheme,
      required this.darkTheme,
      required this.camera});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: LoginPage(camera: camera),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.camera});
  final CameraDescription camera;
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
                          builder: (context) => NavigationExample(
                                camera: camera,
                              )),
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
  final CameraDescription camera;
  const NavigationExample({super.key, required this.camera});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  bool addingFriend = false;
  String? email = FirebaseAuth.instance.currentUser!.email;
  @override
  Widget build(BuildContext context) {
    if (currentPageIndex != 1) {
      setState(() {
        addingFriend = false;
      });
    }
    return Scaffold(
      floatingActionButtonLocation: addingFriend == true
          ? FloatingActionButtonLocation.centerFloat
          : null,
      floatingActionButton: currentPageIndex == 3
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              tooltip: 'Create Post',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        TakePictureScreen(camera: widget.camera),
                  ),
                );
              },
              child: const FaIcon(FontAwesomeIcons.camera),
            )
          : currentPageIndex == 1 && addingFriend == false
              ? FloatingActionButton(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  tooltip: 'Add Friend',
                  onPressed: () {
                    setState(() {
                      addingFriend = true;
                    });
                  },
                  child: const FaIcon(FontAwesomeIcons.userPlus),
                )
              : currentPageIndex == 1 && addingFriend == true
                  ? AddFriend()
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
            icon: const FaIcon(FontAwesomeIcons.leaf),
            label: 'Grassblade',
          ),
          NavigationDestination(
            icon: Icon(Icons.group),
            label: 'My Garden',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            label: 'Find Grass',
          ),
          NavigationDestination(
            icon: Icon(Icons.diversity_1_outlined),
            label: 'My Lawn',
          ),
        ],
      ),
      body: <Widget>[
        Profile(email: email),
        const Friends(),
        GrassNearMe(),
        FeedScreen(
          profile: false,
          email: email,
        ),
      ][currentPageIndex],
    );
  }
}

class GrassNearMe extends StatefulWidget {
  const GrassNearMe({
    super.key,
  });

  @override
  State<GrassNearMe> createState() => _GrassNearMeState();
}

class _GrassNearMeState extends State<GrassNearMe> {
  bool discoverTime = false;
  @override
  void initState() {
    super.initState();
    // here is the logic
    Future.delayed(Duration(seconds: 2)).then((__) {
      setState(() {
        discoverTime = true;
      });
    });
  }

  Widget build(BuildContext context) {
    return !discoverTime
        ? Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          )
        : Discover();
  }
}

class Profile extends StatelessWidget {
  final String? email;
  Profile({
    super.key,
    required this.email,
  });
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(email).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String date = readTimestamp(
              data['posts'][data['posts'].length - 1]['timestamp'].seconds);
          String name = data['displayName'].replaceAll(' ', '');
          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius:
                        70, // Change this radius for the width of the circular border
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius:
                          80, // This radius is the radius of the picture in the circle avatar itself.
                      backgroundImage: NetworkImage(
                        data['photoUrl'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "@$name",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "Last Touched Grass: $date",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Color.fromRGBO(87, 98, 73, 1)),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "${data['grassPoints']}",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          "Grass Points",
                          style: Theme.of(context).textTheme.titleSmall,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "${data['friends'].length}",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          "Total Friends",
                          style: Theme.of(context).textTheme.titleSmall,
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                const Divider(
                  indent: 20,
                  endIndent: 20,
                ),
                Text(
                  "Lawn",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text("Recent Posts"),
                FeedScreen(profile: true, email: email)
              ],
            ),
          );
          //
          // Text(
          //     "Full Name: ${data['displayName']} ${data['displayName']}");
        }

        return CircularProgressIndicator();
      },
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.profile,
    required this.email,
  });
  final bool profile;
  final String? email;
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List> posts;
  @override
  void initState() {
    super.initState();
    if (widget.profile == false) {
      posts = getFeed();
    } else {
      posts = getProfileFeed(widget.email);
    }
  }

  Widget build(BuildContext context) {
    getFeed();

    return FutureBuilder<List>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var postList = snapshot.data!;

            return ListView(
              physics:
                  widget.profile ? const NeverScrollableScrollPhysics() : null,
              shrinkWrap: true,
              children: [
                for (var post in postList)
                  FeedCard(
                    grassPoints: post['grass_points'].toString(),
                    name: post['name'],
                    picUrl: post['imgUrl'],
                    timestamp: readTimestamp(post['timestamp'].seconds),
                    location: post['location'],
                    postImgUrl: post['imgUrl'],
                    photoUrl: post['photoUrl'],
                  )
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return Center(
              child: Container(
                  height: 100,
                  width: 100,
                  child: const CircularProgressIndicator()));
        });
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
  List<LocationData> locations = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String response = await rootBundle.loadString('assets/db.json');
    final List<dynamic> data = await json.decode(response);

    //final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    //print(response.body);
    // if (response.statusCode == 200) {
    //  = json.decode(stuff);
    //final Map<String, dynamic> data = json.decode(response.body);
    setState(() {
      locations =
          data.map((location) => LocationData.fromJson(location)).toList();
      //locations = data.values.toList().where((location) => location is Map<String, dynamic>).map((location) => LocationData.fromJson(location)).toList();
    });
    // } else {
    //   throw Exception('Failed to load data');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(locations[index].name),
              subtitle: Text('Distance: ${locations[index].distance} miles'),
            ),
          );
        },
      ),
    );
  }
}

class LocationData {
  final String name;
  final double distance;

  LocationData({
    required this.name,
    required this.distance,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      name: json['Location'],
      distance: json['Distance'].toDouble(),
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
  long = location.longitude;
  lat = location.latitude;

  return await Geolocator.getCurrentPosition();
}

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  String currentEmail = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: TextField(
          onChanged: (value) => {
                setState(() {
                  currentEmail = value;
                })
              },
          decoration: InputDecoration(
            fillColor: Theme.of(context).colorScheme.primaryContainer,
            filled: true,
            border: const OutlineInputBorder(),
            hintText: 'Enter member email address',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                addFriend(currentEmail);
              },
            ),
          )),
    );
  }
}
