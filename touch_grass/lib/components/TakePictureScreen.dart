import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:touch_grass/firebaseFunctions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

_determineCity() async {
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

  // ignore: avoid_print
  var locationInfo = await http.get(Uri.parse(
      'https://api.geoapify.com/v1/geocode/reverse?lat=$lat&lon=$long&format=json&apiKey=14ce672613894a82b9d9c3f9189be469'));

  var locationInfoJSON = await jsonDecode(locationInfo.body);

  // Map<String, dynamic> user = jsonDecode(jsonString);

  var city = locationInfoJSON['city'];
  var country = locationInfoJSON['country'];

  return {'city': city, 'country': country};
}

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
  bool clicked = false;

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
      appBar: AppBar(
        title: Text(
          "Touch Grass",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: "Pacifico",
              color: const Color.fromRGBO(62, 106, 0, 1)),
        ),
        centerTitle: true,
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return SizedBox.expand(child: CameraPreview(_controller));
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,

        // Provide an onPressed callback.
        onPressed: () async {
          setState(() {
            clicked = true;
          });
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

            final storageRef = FirebaseStorage.instance.ref();

// Create a reference to "mountains.jpg"
            var value = await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .get();

            var posts = value.get('posts').length.toString();
            final mountainsRef = storageRef
                .child("${FirebaseAuth.instance.currentUser!.email}/$posts");
            await mountainsRef.putFile(
                File(image.path), SettableMetadata(contentType: 'image/jpeg'));

            String imgurl = await mountainsRef.getDownloadURL();
            DateTime lastM = await image.lastModified();
            await addPost(imgurl, lastM)
                .then((value) => Navigator.of(context).pop());
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },

        child: !clicked
            ? const Icon(Icons.camera_alt)
            : const CircularProgressIndicator.adaptive(),
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
    );
  }
}
