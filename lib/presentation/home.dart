import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;
  LatLng? initialPosition;
  LatLng? currentPosition;
  double mapZoom = 5;
  late GoogleMapController _mapController;
  Set<Marker> markers = {};
  List<LatLng> track = [];
  bool normalMapview = true;
  bool moveCameraToUserLocation = false;
  Color moveCameraToUserLocationButtonColor = Colors.black;
  String mapView = "Satellite View";

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            moveCameraToUserLocation = !moveCameraToUserLocation;
            moveCameraToUserLocationButtonColor =
                moveCameraToUserLocation ? Colors.green : Colors.black;
            String msg = moveCameraToUserLocation ? "Focus on My Location" : "Remove Focus From My Location";
            showToastMessage(msg);
            setState(() {});
          },
          icon: Icon(
            Icons.my_location,
            color: moveCameraToUserLocationButtonColor,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.amberAccent),
              elevation: MaterialStateProperty.all(10),
              padding: MaterialStateProperty.all(
                const EdgeInsets.only(left: 5, right: 5),
              ),
            ),
            onPressed: () {
              normalMapview = !normalMapview;
              mapView = normalMapview ? "Satellite View" : "Normal View";
              setState(() {});
            },
            child: Text(mapView),
          ),
        ],
        title: const Text(
          "Map",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: GoogleMap(
        mapType: normalMapview ? MapType.normal : MapType.satellite,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: const LatLng(24.045652376297024, 90.25369598155177),
          zoom: mapZoom,
        ),
        markers: markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId("distanceFromInitialLocation"),
            color: Colors.red,
            points: track,
          ),
        },
      ),
    );
  }

  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      LocationPermission requestStatus = await Geolocator.requestPermission();
      if (requestStatus == LocationPermission.whileInUse ||
          requestStatus == LocationPermission.always) {
        getUserLocation();
      } else {
        getUserLocation();
      }
    }
    showToastMessage("Getting Your Location. Please Wait.....");
    initialPosition = LatLng(position!.latitude, position!.longitude);
    currentPosition = initialPosition;
    track.add(initialPosition!);
    await Future.delayed(const Duration(seconds: 5));
    await animateToCurrentPosition();
    markers.add(
      Marker(
        markerId: const MarkerId("initialLocation"),
        position: initialPosition!,
        infoWindow: InfoWindow(
          title: "Initial Location",
          snippet: "${position!.latitude} ${position!.longitude}",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    setState(() {});
    getUpdateLocationManager();
  }

  Future<void> animateToCurrentPosition() async {
    showToastMessage("Pointing to Your Current Location......");
    await _mapController
        .animateCamera(CameraUpdate.newLatLngZoom(initialPosition!, 10));
    await Future.delayed(const Duration(seconds: 1));
    await _mapController
        .animateCamera(CameraUpdate.newLatLngZoom(initialPosition!, 13));
    await Future.delayed(const Duration(seconds: 1));
    await _mapController
        .animateCamera(CameraUpdate.newLatLngZoom(initialPosition!, 15));
    await Future.delayed(const Duration(seconds: 1));
    mapZoom = 17;
    await _mapController
        .animateCamera(CameraUpdate.newLatLngZoom(initialPosition!, mapZoom));
  }

  Future<void> getUpdateLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = LatLng(position!.latitude, position!.longitude);
    if (moveCameraToUserLocation) {
      await _mapController
          .animateCamera(CameraUpdate.newLatLng(currentPosition!));
    }
    track.add(currentPosition!);
    markers.add(
      Marker(
        markerId: const MarkerId("currentLocation"),
        position: currentPosition!,
        infoWindow: InfoWindow(
          title: "My Current Location",
          snippet: "${position!.latitude} ${position!.longitude}",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    setState(() {});
  }

  Future<void> getUpdateLocationManager() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 10));

      /// Fetch the user's current location every 10 seconds.
      await getUpdateLocation();
    }
  }

  void showToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.green,
        fontSize: 16.0);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
