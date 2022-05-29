import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class third extends StatefulWidget {
  @override
  _ThirdState createState() => _ThirdState();
}

class _ThirdState extends State<third> {
  late GoogleMapController _controller; // 지도 컨트롤러
  static const CameraPosition _kGooglePlex = CameraPosition( // 초기 카메라 위치
    target: LatLng(37.011289, 127.265021),
    zoom: 14.0,
  );
  LatLng _currentPosition = const LatLng(37.011287, 127.265188); // 현재 위치
  late Marker _currentMark; // 현재 위치 마커
  late String _now; // 현재 위치 - 한글로 시, 동
  bool _setPosition = false; // 현재 위치가 찾아져 있으면 true
  final List<Marker> _markers = []; // 지도에 띄울 마커 list
  late final BitmapDescriptor _markerIcon; // 현재 위치 마커 아이콘 객체
  late final BitmapDescriptor _naviIcon;

  double _minPoint = 2000.0; // 가장 가까운 거리
  String recommend = "가장 가까운 시설";
  String facilityName = "이름"; // 선택한 시설 이름
  String facilityAddr = "주소"; // 선택한 시설 주소
  String facilityWidth = "123m"; // 현재 위치에서 선택한 시설까지의 거리
  String category = ''; // 선택한 카테고리
  late LatLng point; // 선택된 지점

  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline> {};
  List<LatLng> _navigationPoint = [];

  bool _isNaviWork = false; // 길안내가 떠있는 중이면 true
  bool _isNear = false; // 선택된 마커가 가장 가까운 지점이면 true
  bool _onMarkerTab = false; // 마커가 선택된 상태면 true
  bool _onSalonTab = false;
  bool _onPakrTab = false;
  bool _onHotelTab = false;
  bool _onPetTab = false;
  bool _onHospitalTab = false;

  void setViewInit() {
    _polylines = <PolylineId, Polyline> {};
    _navigationPoint = [];
    _markers.clear();

    _isNaviWork = false;
    _isNear = false;
    _onMarkerTab = false;
    _onSalonTab = false;
    _onPakrTab = false;
    _onHotelTab = false;
    _onPetTab = false;
    _onHospitalTab = false;

    _minPoint = 2000.0;
    point = const LatLng(0, 0);
    recommend = "가장 가까운 시설";
    facilityName = "이름";
    facilityAddr = "주소";
    facilityWidth = "123m";
    category = '';
  }

  @override
  void initState() {
    super.initState();
    getLocation(); // 현재 위치를 가져옴
    setIcon(); // 현재 위치 아이콘 설정
    _onSalonTab = false;
    _onPakrTab = false;
    _onHotelTab = false;
    _onPetTab = false;
    _onHospitalTab = false;
  }

  void setIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'images/icons/putprint_pin.png'
    );
    _naviIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 1),
      'images/icons/wayPoint.png'
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceArea = deviceHeight * deviceWidth;

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), 
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              Row( children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(deviceWidth * 0.08, deviceHeight * 0.05, 0, deviceHeight * 0.001),
                  child: Text('주변시설',
                    style: TextStyle(fontSize: deviceArea * 0.00007, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(deviceWidth * 0.07, deviceHeight * 0.075, 0, deviceHeight * 0.025),
                  child: GestureDetector(
                      child: Container(
                        width: deviceWidth * 0.58,
                        height: deviceHeight * 0.05,
                        child: Center(
                          child: Text(_setPosition ? _now : "터치해서 현재 위치 찾기",
                            style: TextStyle(fontSize: deviceArea * 0.000043, color: Colors.lightGreen[900]),),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.lightGreen[100],
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(width: 2.0, color: Colors.lightGreen.shade700),
                        ),
                      ),
                    onTap: () async {
                        getLocation();
                      final url = Uri.parse("https://maps.googleapis.com/"
                          "maps/api/geocode/json?latlng="
                          "${_currentPosition.latitude.toString()},"
                          "${_currentPosition.longitude.toString()}"
                          "&language=ko"
                          "&key=AIzaSyCxnMmwLCN6PlyGaqXd8Z7BTqCbVQ35bXk");
                      // 구글 Geocoding API 요청 url
                      final response = await http.get(url); // 구글 서버에서 PC로 받아옴, API key에 IP 주소 추가해야.
                      // Geocoding API는 사용량 제한 없어서 그냥 써도 됨

                      String dong = jsonDecode(response.body)['results'][1]['address_components'][1]['long_name'];
                      String sy = jsonDecode(response.body)['results'][1]['address_components'][2]['long_name'];
                      // json 형식으로 들어옴
                      print("위치 정보 성공적으로 받아옴 " + sy + ", " + dong);
                      _now = sy + ", " + dong;

                      _controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 14.0));

                      setState(() {
                        _setPosition = true;
                        _markers.add(_createMarker());
                        _onSalonTab = false;
                        _onPakrTab = false;
                        _onHotelTab = false;
                        _onPetTab = false;
                        _onHospitalTab = false;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
              ],),
              Container(
                width: deviceWidth * 0.97,
                height: deviceHeight * 0.08,
                decoration: BoxDecoration(
                  color: Colors.lightGreen[100],
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(width: 2.0, color: Colors.lightGreen.shade900),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                          child: Image.asset('images/icons/salon.png', width: 30, height: 30,),
                        color: _onSalonTab ? Colors.lightGreen[300] : Colors.lightGreen[100],
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      ),
                      onTap: _chooseSalon,
                    ),
                    const SizedBox(width: 40,),
                    InkWell(
                      child: Container(child: Image.asset('images/icons/park.png', width: 30, height: 30,),
                        color: _onPakrTab ? Colors.lightGreen[300] : Colors.lightGreen[100],
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      ),
                        onTap: _choosePark,
                    ),
                    const SizedBox(width: 40,),
                    InkWell(
                      child: Container(child: Image.asset('images/icons/hotel.png', width: 30, height: 30,),
                        color: _onHotelTab ? Colors.lightGreen[300] : Colors.lightGreen[100],
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      ),
                      onTap: _chooseHotel,
                    ),
                    const SizedBox(width: 40,),
                    InkWell(
                      child: Container(child: Image.asset('images/icons/pets.png', width: 30, height: 30,),
                        color: _onPetTab ? Colors.lightGreen[300] : Colors.lightGreen[100],
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      ),
                      onTap: _choosePets,
                    ),
                    const SizedBox(width: 40,),
                    InkWell(
                      child: Container(child: Image.asset('images/icons/hospital.png', width: 30, height: 30,),
                        color: _onHospitalTab ? Colors.lightGreen[300] : Colors.lightGreen[100],
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      ),
                      onTap: _chooseHospital,
                    ),
                  ],
                ),
              ),
              Container(
                width: deviceWidth * 0.965,
                height: _onMarkerTab ? deviceHeight * 0.51 : deviceHeight * 0.67,
                //color: Colors.lightGreen,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      _controller = controller;
                    });
                  },
                  markers: _markers.toSet(),
                  polylines: Set<Polyline>.of(_polylines.values),
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  onCameraMove: (_) {},
                  myLocationButtonEnabled: true,
                  onTap: (chosen){
                    _controller.animateCamera(CameraUpdate.newLatLng(chosen));
                  },
                ),
              ),
              SizedBox(
                  width: deviceWidth * 0.98,
                  child: _onMarkerTab ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: deviceHeight * 0.01,),
                      Row(
                        children: [
                          SizedBox(width: deviceWidth * 0.01,),
                          Text(facilityName,
                            style: TextStyle(fontSize: deviceArea * 0.00005,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: deviceWidth * 0.02,),
                          Text(category,
                            style: TextStyle(fontSize: deviceArea * 0.000035,
                              color: Colors.black45,
                            ),
                          ),
                          SizedBox(width: deviceWidth * 0.06,),
                          _isNear ? Text(recommend,
                            style: TextStyle(
                              fontSize: deviceArea * 0.00004,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            )
                          ) : const SizedBox(width: 0,),
                          SizedBox(width: deviceWidth * 0.03,),
                          Text(facilityWidth,
                            style: TextStyle(fontSize: deviceArea * 0.000045,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      Text(facilityAddr,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      _isNaviWork ? const SizedBox() : TextButton(onPressed: () {
                        if(!_isNaviWork) {
                          _isNaviWork = true;

                          print('길 안내 버튼이 클릭됐어요.');
                          print('$facilityName까지의 길안내를 출력합니다.');

                          _navigationPoint.add(_currentPosition);
                          // 길 안내 google Directions API 이용
                          _navigation();

                          Polyline line = Polyline(
                              polylineId: const PolylineId('navigation'),
                              color: Colors.blue,
                              points: _navigationPoint,
                              width: 4);

                          setState(() {
                            _polylines[const PolylineId('navigation')] = line;
                          });
                        }},
                        child: const Text('길 안내'),
                        style: TextButton.styleFrom(
                          textStyle: TextStyle(fontSize: deviceArea * 0.00004),
                          primary: Colors.black,
                          backgroundColor: Colors.lightGreen,
                          minimumSize: const Size(3, 3),
                          shape: const BeveledRectangleBorder(),
                        ),
                      ),
                    ],
                  ) : const SizedBox(width: 5,),
              ),
            ],
          ),
        )
    );
  }

  Marker _createMarker() {
    if (_markers.isEmpty){
      return _currentMark = Marker(markerId: const MarkerId("now"),
          position: _currentPosition,
          icon: _markerIcon
      );
    } else {
      _markers.remove(_currentMark);
      return _currentMark = Marker(markerId: const MarkerId("now"),
          position: _currentPosition,
          icon: _markerIcon
      );
    }
  }

  void getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    double lat, lon;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("위치 정보 서비스 사용 불가");
      return;
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("위치 정보 액세스 거부됨");
        return;
      }
    }
    else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print("현재 위치 = " + position.toString());

      lat = double.parse(position.latitude.toString());
      lon = double.parse(position.longitude.toString());
      _currentPosition = LatLng(lat, lon);
      _controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 14));
    }
  }

  _checkResult (i, lat, lon, addr, name) async {
    String id = "id";
    final Marker marker;

    LatLng p = LatLng(lat, lon);
    double distance = Geolocator.distanceBetween(
        _currentPosition.latitude, _currentPosition.longitude,
        p.latitude, p.longitude
    );
    print(distance);

    if (distance < 2000) { // 현재 위치 반경 약 1.5km 이내의 시설을 필터링하기 위한 부분
      if (_minPoint > distance) {
        _minPoint = distance;
        id = "recommend";
        // 약 20개의 검색 결과가 반환되는데, 가장 가까운 지점이 가장 먼저 들어오는 양상을 보임

        marker = Marker(markerId: MarkerId(id),
            position: p,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            onTap: () => _markerTap(name, addr, p, i, true),
        );

        setState(() {
          _markers.add(marker);
        });
      } else {
        id = i.toString();

        marker = Marker(markerId: MarkerId(id),
            position: p,
            onTap: () => _markerTap(name, addr, p, i, false),
        );

        setState(() {
          _markers.add(marker);
        });
      }
    }
  }

  _markerTap(String name, String addr, LatLng p, int i, bool near) async {
    print("주소 : " + addr);

    var exactDistance = Geolocator.distanceBetween(
        _currentPosition.latitude, _currentPosition.longitude,
        p.latitude, p.longitude);
    String distanceMater = exactDistance.toInt().toString() + "m";

    if (near) {
      _isNear = true;
      recommend = "가장 가까운 시설";
    } else {
      _isNear = false;
    }
    point = p;
    facilityName = name;
    facilityAddr = addr;
    facilityWidth = distanceMater;

    setState((){
      _onMarkerTab = true;
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/response.txt');
  }
  Future<File> get _getDB async {
    final path = await _localPath;
    return File('$path/length_walk.txt');
  }
  Future<File> writeContext(context) async {
    final file = await _localFile;
    return file.writeAsString('$context');
  }

  void _navigation() async {
    if (facilityName == "이름") {
      print('지점 선택 없이 길찾기가 호출됨');
      return;
    }

    final url = Uri.parse("https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${_currentPosition.latitude},${_currentPosition.longitude}" // 출발점
        "&destination=$facilityName" // 도착점
        "&mode=transit" // 어떤 방식의 길안내인지
        "&language=ko" // 반환값의 언어
        "&key=AIzaSyCxnMmwLCN6PlyGaqXd8Z7BTqCbVQ35bXk");

    final response = await http.get(url);
    print("길 안내 결과 받아옴");
    //writeContext(response.body); // 받아온 결과를 파일로 저장

    Map<String, dynamic> map = jsonDecode(response.body);
    catchPoint(map);
  }

  // json에서 내용을 가져오기 위한 메소드
  void catchPoint(Map<String, dynamic> map) {

    // 반환받는 json의 구조가, steps list가 오는데, 이동 방식이 달라질 때마다 steps의 index가 바뀜
    dynamic tmp;
    double lat = 0, long = 0;
    bool isTransit = false;

    for(int i = 0; i < 50; i++) {
      try {
        tmp = map['routes'][0]['legs'][0]['steps'][i];

        while (true) {
          isTransit = tmp['travel_mode'] == 'WALKING' ? false : true;
          lat = tmp['end_location']['lat'];
          long = tmp['end_location']['lng'];

          _navigationPoint.add(LatLng(lat, long));
          setState((){
            _markers.add(
                Marker(
                  markerId: isTransit ? MarkerId('transit' + i.toString()) : MarkerId('walking' + i.toString()),
                  position: LatLng(lat, long),
                  infoWindow: InfoWindow(title: isTransit ? '여기까지 대중교통으로' : '여기까지 도보로'),
                  icon: _naviIcon,)
            );
          });
          try {
            tmp = tmp['steps'][0];
          } catch (ex) {
            break;
          }
        }
      } catch (ex) {
        break;
      }
    }
  }

  /// 미용실 button event handler
  Future<void> _chooseSalon() async {

    setViewInit();
    _onSalonTab = true;
    _markers.add(_currentMark);

    category = "미용";

    final url = Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query= 애완동물 미용" // 검색어
        "&location=${_currentPosition.latitude}%2C${_currentPosition.longitude}" // 검색 중심지
        "&radius=500" // 검색 범위(m)
        "&language=ko" // 반환값의 언어
        "&type=salon" // 시설 카테고리
        "&key=AIzaSyCxnMmwLCN6PlyGaqXd8Z7BTqCbVQ35bXk");

    final response = await http.get(url);

    for (int i = 0; i < 20; i++) {
      try {
        if (jsonDecode(response.body)['results'][i] != null) {
          String placeName = jsonDecode(response.body)['results'][i]['name'];
          double placeLocationLat = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lat'];
          double placeLocationLon = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lng'];
          String placeAddr = jsonDecode(
              response.body)['results'][i]['formatted_address'];
          _checkResult(
              i, placeLocationLat, placeLocationLon, placeAddr, placeName);
          print(i.toString() + ", " + placeName);
        } else {
          break;
        }
      } catch (e) {
        print("전달받은 시설물 개수가 20개 미만이에요...");
      }
    }
  }

  /// 병원 button event handler
  Future<void> _chooseHospital() async{

    setViewInit();
    _onHospitalTab = true;
    _markers.add(_currentMark);

    category = "동물병원";

    final url = Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query=동물병원" // 검색어
        "&location=${_currentPosition.latitude}%2C${_currentPosition.longitude}" // 검색 중심지
        "&radius=500" // 검색 범위(m)
        "&language=ko" // 반환값의 언어
        "&type=동물병원" // 시설 카테고리
        "&key=AIzaSyCxnMmwLCN6PlyGaqXd8Z7BTqCbVQ35bXk");

    final response = await http.get(url);

    for (int i = 0; i < 20; i++) {
      try {
        if (jsonDecode(response.body)['results'][i] != null) {
          String placeName = jsonDecode(response.body)['results'][i]['name'];
          double placeLocationLat = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lat'];
          double placeLocationLon = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lng'];
          String placeAddr = jsonDecode(
              response.body)['results'][i]['formatted_address'];
          _checkResult(
              i, placeLocationLat, placeLocationLon, placeAddr, placeName);
          print(i.toString() + ", " + placeName);
        } else {
          break;
        }
      } catch (e) {
        print("전달받은 시설물 개수가 20개 미만이에요...");
      }
    }
  }

  /// 숙박시설 button event handler
  Future<void> _chooseHotel() async{

    setViewInit();
    _onHotelTab = true;
    _markers.add(_currentMark);

    category = "반려동물 호텔";

    final url = Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query=반려 호텔" // 검색어
        "&location=${_currentPosition.latitude}%2C${_currentPosition.longitude}" // 검색 중심지
        "&radius=500" // 검색 범위(m)
        "&language=ko" // 반환값의 언어
        "&key=AIzaSyCxnMmwLCN6PlyGaqXd8Z7BTqCbVQ35bXk");

    final response = await http.get(url);

    for (int i = 0; i < 20; i++) {
      try {
        if (jsonDecode(response.body)['results'][i] != null) {
          String placeName = jsonDecode(response.body)['results'][i]['name'];
          double placeLocationLat = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lat'];
          double placeLocationLon = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lng'];
          String placeAddr = jsonDecode(
              response.body)['results'][i]['formatted_address'];
          _checkResult(
              i, placeLocationLat, placeLocationLon, placeAddr, placeName);
          print(i.toString() + ", " + placeName);
        } else {
          break;
        }
      } catch (e) {
        print("전달받은 시설물 개수가 20개 미만이에요...");
      }
    }
  }

  /// 공원 button event handler
  Future<void> _choosePark() async{

    setViewInit();
    _onPakrTab = true;
    _markers.add(_currentMark);

    category = "공원";

    final url = Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query=공원" // 검색어
        "&location=${_currentPosition.latitude}%2C${_currentPosition.longitude}" // 검색 중심지
        "&radius=500" // 검색 범위(m)
        "&language=ko" // 반환값의 언어
        "&key=AIzaSyCxnMmwLCN6PlyGaqXd8Z7BTqCbVQ35bXk");

    final response = await http.get(url);

    for (int i = 0; i < 20; i++) {
      try {
        if (jsonDecode(response.body)['results'][i] != null) {
          String placeName = jsonDecode(response.body)['results'][i]['name'];
          double placeLocationLat = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lat'];
          double placeLocationLon = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lng'];
          String placeAddr = jsonDecode(
              response.body)['results'][i]['formatted_address'];
          _checkResult(
              i, placeLocationLat, placeLocationLon, placeAddr, placeName);
          print(i.toString() + ", " + placeName);
        } else {
          break;
        }
      } catch (e) {
        print("전달받은 시설물 개수가 20개 미만이에요...");
      }
    }
  }

  /// 반려동물 용품점 button event handler
  Future<void> _choosePets() async {

    setViewInit();
    _onPetTab = true;
    _markers.add(_currentMark);

    category = "용품점";

    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json"
            "?query=애완용품" // 검색어
            "&location=${_currentPosition.latitude}%2C${_currentPosition
            .longitude}" // 검색 중심지
            "&radius=500" // 검색 범위(m)
            "&language=ko" // 반환값의 언어
            "&key=AIzaSyCxnMmwLCN6PlyGaqXd8Z7BTqCbVQ35bXk");

    final response = await http.get(url);

    for (int i = 0; i < 20; i++) {
      try {
        if (jsonDecode(response.body)['results'][i] != null) {
          String placeName = jsonDecode(response.body)['results'][i]['name'];
          double placeLocationLat = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lat'];
          double placeLocationLon = jsonDecode(
              response.body)['results'][i]['geometry']['location']['lng'];
          String placeAddr = jsonDecode(
              response.body)['results'][i]['formatted_address'];
          _checkResult(
              i, placeLocationLat, placeLocationLon, placeAddr, placeName);
          print(i.toString() + ", " + placeName);
        } else {
          break;
        }
      } catch (e) {
        print("전달받은 시설물 개수가 20개 미만이에요...");
      }
    }
  }
}