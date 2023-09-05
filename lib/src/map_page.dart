import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:letovo_outside/src/profile_page.dart';
import 'package:letovo_outside/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import 'models.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  String? userIdSelected;

  // DB init
  final database = FirebaseDatabase.instance;
  final long_database = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Maps init
  late final MapController mapController;
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  List<Marker> allMarkers = [];
  LocationMarkerPosition _currentPosition = LocationMarkerPosition(
    latitude: 0,
    longitude: 0,
    accuracy: 0,
  );

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    activeListeners();
    updateUserLocation();
  }

  void activeListeners() {
    database.ref('userLocations').onValue.listen((event) {
      try {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        List<Marker> _allMarkers = [];
        map.forEach((key, value) {
          if (key != uid) {
            _allMarkers.add(Marker(
                key: Key(key),
                point: LatLng(
                  value['lastLocation']['latitude'],
                  value['lastLocation']['longitude'],
                ),
                builder: (context) {
                  var d = daysBetween(DateTime.now(),
                      DateTime.parse(value['lastLocationUpdateTime']));
                  return GestureDetector(
                    onTap: () {
                      print("HELLO");
                    },
                    child: const Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 30,
                    ),
                  );
                }));
          }
        });
        setStateIfMounted(() {
          allMarkers = _allMarkers;
        });
      } catch (e) {
        print('An error during collecting user locations:');
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.only(bottom: 150),
          child: _backgroundWidget(),
        ),
        Positioned(
            right: 3,
            top: 20,
            child: ElevatedButton(
              onPressed: () => setStateIfMounted(() {
                userIdSelected = null;
                openProfilePage(uid);
              }),
              child: Icon(Icons.person, color: colors['text']),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
                backgroundColor: colors['background'],
              ),
            )),
        Positioned(
            left: 3,
            top: 20,
            child: ElevatedButton(
              onPressed: () => updateUserLocation(),
              child: Icon(Icons.near_me, color: colors['text']),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
                backgroundColor: colors['background'],
              ),
            )),
        Container(
          child: DraggableScrollableSheet(
            builder: (BuildContext context, ScrollController scrollController) {
              return _expandedWidget(scrollController);
            },
          ),
        ),
      ]),
    ));
  }

  Widget _backgroundWidget() {
    // TODO add padding
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          center: LatLng(50, 20),
          zoom: 3,
          minZoom: 4,
          maxZoom: 18,
          interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
          onPositionChanged: (MapPosition position, bool hasGesture) {
            setStateIfMounted(() {
              if (hasGesture) {
                userIdSelected = null;
              }
              LatLngBounds? bounds = position.bounds;
            });
          }),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        MarkerLayer(markers: allMarkers),
        AnimatedLocationMarkerLayer(
          position: _currentPosition,
        ),
      ],
    );
  }

  Widget _expandedWidget(ScrollController scrollController) {
    return Container(
        padding: const EdgeInsets.only(top: 16, left: 18, right: 18),
        decoration: BoxDecoration(
          color: colors['background'],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              var data = streamSnapshot.data;
              if (data != null) {
                var docs = data.docs;
                docs.removeWhere((element) => element.id == uid);
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  controller: scrollController,
                  itemCount: docs.length + 1,
                  itemBuilder: (context, int index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors['backgroundLight'],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text('летовцы рядом',
                              textAlign: TextAlign.center,
                              style: textStyles['title']),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                    UserData user = UserData(
                        userId: docs[index - 1].id,
                        name: docs[index - 1].get('name'),
                        graduationYear: docs[index - 1].get('graduationYear'));
                    return Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: userIdSelected == docs[index - 1].id
                              ? colors['text']
                              : colors['backgroundLight'],
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              if (userIdSelected == docs[index - 1].id) {
                                setStateIfMounted(() {
                                  openProfilePage(docs[index - 1].id);
                                });
                              } else {
                                var marker = allMarkers.firstWhere((element) {
                                  return element.key == Key(docs[index - 1].id);
                                });
                                _animatedMapMove(
                                    LatLng(marker.point.latitude,
                                        marker.point.longitude),
                                    18);
                                setStateIfMounted(() {
                                  userIdSelected = docs[index - 1].id;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: userIdSelected ==
                                                  docs[index - 1].id
                                              ? textStyles['textOnLight']
                                              : textStyles['text'],
                                        ),
                                        Text(
                                          calculateDistance(user.userId),
                                          style: userIdSelected ==
                                                  docs[index - 1].id
                                              ? textStyles['subtextOnLight']
                                              : textStyles['subtext'],
                                        )
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                      visible:
                                          userIdSelected == docs[index - 1].id,
                                      child: Icon(
                                        Icons.keyboard_arrow_right,
                                        size: 40,
                                        color: colors['background'],
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ));
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  void openProfilePage(profileUid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProfilePage(profileUid: profileUid);
        },
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  String calculateDistance(String userId) {
    try {
      var marker = allMarkers.firstWhere((element) {
        return element.key == Key(userId);
      });
      int d = Distance()
          .as(
              LengthUnit.Meter,
              LatLng(_currentPosition.latitude, _currentPosition.longitude),
              LatLng(marker.point.latitude, marker.point.longitude))
          .toInt();
      return '${d >= 1000 ? '${d ~/ 1000} км' : '$d м'} от вас';
    } catch (e) {
      return 'Не загружены маркеры';
    }
  }

  Future updateUserLocation() async {
    Position position = await _determinePosition();
    setStateIfMounted(() {
      _currentPosition = LocationMarkerPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy);
      _animatedMapMove(LatLng(position.latitude, position.longitude), 18);
    });
    // TODO implement user ask
    // TODO replace with server time
    // TODO implement saving last update time, every 5 hour update location
    // TODO if accuracy too big, deny

    DateTime now = DateTime.now();
    database.ref('userLocations/$uid').set({
      'lastLocation': {
        'latitude': position.latitude,
        'longitude': position.longitude
      },
      'lastLocationUpdateTime': now.toString()
    });
  }
}
