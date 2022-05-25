import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Length extends StatefulWidget {
  const Length({Key? key}) : super(key: key);

  @override
  _LengthState createState() => _LengthState();
}

class _LengthState extends State<Length> {
  late TextEditingController _destinationController; // 입력 처리 컨트롤러
  late GoogleMapController _mapController; // 지도 컨트롤러

  static CameraPosition _kGooglePlex = const CameraPosition( // 카메라 초기 위치
    target: LatLng(37.011289, 127.265021),
    zoom: 10.0,
  );

  LatLng _currentPosition = const LatLng(37.011289, 127.265021); // 현재 위치
  final List<Marker> _markers = []; // 마커 배열
  late BitmapDescriptor _markerIcon; // 현재 위치를 나타낼 아이콘
  late Marker _currentMarker; // 현재 위치 마커
  late Marker _startPoint; // 시작지점 마커
  late Marker _destinationPoint = const Marker(markerId: MarkerId("non")); // 목적지 마커

  List<LatLng> _track = []; // 이동 경로를 저장할 배열

  double _lenght = 0; // 오늘 산책한 총 이동 거리
  double _walkingLength = 0; // 목적지까지 남은 잔여 거리
  String today = ""; // DB date

  bool _isWalking = false; // 산책 중인지 아닌지, 산책 중이면 true.

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat format = DateFormat('yyyy/MM/dd');
    today = format.format(now);
    return today;
  }

  void setIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'images/icons/putprint_pin.png');
  }

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController();
    getToday(); // 오늘 날짜를 받아올 메소드, 이후 저장 전 등에 다시 호출되어야.
    setIcon(); // 현재 위치 아이콘 지정 메소드
    getLocation(); // 일회적으로 위치를 받아오는 메소드, 첫 실행 시 한 번만 수행할 예정
    asyncGetLocation(); // 실시간 위치 정보 갱신 메소드
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
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
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(deviceWidth * 0.08, deviceHeight * 0.01, deviceWidth * 0.08, deviceHeight * 0.005),
                child: TextField(controller: _destinationController, // 목적지 입력 필드
                  onSubmitted: (String value) async {
                  await showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('목적지'),
                          content: Text(value),
                          actions: <Widget>[
                            TextButton(onPressed: () {
                              Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            )
                          ],
                        );
                      });},
                  decoration: const InputDecoration(
                      labelText: '목적지',
                      hintText: '이곳에 목적지를 입력해주세요',
                      labelStyle: TextStyle(color: Colors.lightGreen),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                              width: 1, color: Colors.lightGreen)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                              width: 1, color: Colors.lightGreen)
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                      )
                  ),
                ),
              ),
              Container( // 구글 지도
                width: deviceWidth * 0.95,
                height: deviceHeight * 0.5,
                //color: Colors.lightGreen,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                    });
                    _currentMarker = Marker(markerId: const MarkerId("now"),
                        position: _currentPosition,
                        icon: _markerIcon,
                    );
                  },
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  onCameraMove: (_) {},
                  myLocationButtonEnabled: false,
                  markers: _markers.toSet(),
                  onTap: (chosen) { // 왜 탭하면 밀릴까.... 왜 이전에 터치한 지점이 마커로 뜰까......
                    if(!_isWalking) { // 산책 중이 아닐 때만 탭한 위치에 마커 추가
                      if (_destinationPoint.markerId != const MarkerId('non')) {
                        _markers.remove(_destinationPoint);
                      }
                      _destinationPoint =
                          Marker(markerId: const MarkerId("destination"),
                            position: chosen,
                          );
                      setState(() {
                        _markers.add(_destinationPoint);
                      });
                    } // 산책 중일 땐 지도에 들어오는 터치 무시
                  },
                  //zoomControlsEnabled: false,
                ),
              ),
              Row(children: [
                Column( children:[ // 산책 거리를 보여줄 위젯
                  Text('총 산책 거리 ${_lenght}m'),
                  Text('목적지까지의 거리 ${_walkingLength}m'),
                ]),
                SizedBox(width: deviceWidth * 0.2,),
                TextButton( // 길 안내 시작 / 산책 완료 버튼 위젯
                  onPressed: () {
                    if (_isWalking) { // 산책 중일 때
                      print("산책 완료 버튼");
                      // 목적지까지의 거리 0으로 초기화
                      // db에 총 산책 거리 갱신 -> 일기 페이지에 전달하는 편이..
                      // _startPoint랑 _destinationPoint 초기화
                      // 일기를 쓸지 질의하는 창 띄우기
                      // 일기 작성이 선택되면 일기 쪽으로 이동시키는 편이 낫지 않을지?
                      _track = []; // 이동 경로 초기화
                    } else { // 산책 중이 아닐 때
                      print("길 안내 시작 버튼");
                      // 시작지점 저장
                      _startPoint = Marker(markerId: const MarkerId("start"),
                        position: _currentPosition,
                      );
                      // 목적지까지 길안내 시작
                      // 이동한 경로를 기록해 지도에 띄우기 시작
                      _track.add(_startPoint.position);
                    }

                    setState(() { // 산책 상태 갱신
                      _isWalking = !_isWalking;
                    });
                  },
                  child: _isWalking ? const Text("산책 완료") : const Text("길 안내 시작"),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(fontSize: deviceArea * 0.00005),
                    primary: Colors.black,
                    backgroundColor: _isWalking ? Colors.green : Colors.orange,
                  ),
                ),
              ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),

            ],
          ),
        )
    );
  }

  // 호출 시 일시적으로 위치 정보를 받아옴
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
        SystemNavigator.pop(); // 앱 종료
        return;
      }
    }
    else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // 정확도 높음으로 위치 정보 받아옴

      print("현재 위치 = " + position.toString());

      lat = double.parse(position.latitude.toString());
      lon = double.parse(position.longitude.toString());
      _currentPosition = LatLng(lat, lon);

      _kGooglePlex = CameraPosition(target: _currentPosition, zoom: 14.0);
      // 현재 위치로 카메라 설정
      // initState에서 호출되는 메소드라 상태를 갱신해야되는 animationCamara 사용 불가능

      _currentMarker = Marker(markerId: const MarkerId("now"),
        position: _currentPosition,
        icon: _markerIcon,
      );

      setState(() {
        _markers.add(_currentMarker);
      });
    }
  }

  // 실시간 위치 탐색
  void asyncGetLocation() async {
    var locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5
    );

    // 스트림을 통해서 위치 정보가 (distanceFilter)m 변화할 때마다 위치 정보를 다시 받아오도록 함
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream
      (locationSettings: locationSettings).listen((Position? position) async {

      if (position != null) {
        if (_isWalking) { // 산책 중이면
          // 이전 위치들을 이동 경로 배열에 저장
          _track.add(_currentMarker.position);
          // 실시간 위치를 저장해서 지도에 그려줘야

          // 총 산책 거리 증가
          _lenght += 5;

          if (_destinationPoint.markerId != const MarkerId('non')) { // 목적지 마커가 초기 상태가 아니면
            _walkingLength = Geolocator.distanceBetween( // 목적지까지의 거리 계산 => 근데 이거 직선 경로일텐데...?
                _currentPosition.latitude, _currentPosition.longitude,
                _destinationPoint.position.latitude,
                _destinationPoint.position.longitude);
          } else {
            _walkingLength = 0;
          }
        }

        _markers.remove(_currentMarker);

        _currentPosition = LatLng(position.latitude, position.longitude);
        _currentMarker = Marker(
            markerId: const MarkerId("now"),
            position: _currentPosition,
            icon: _markerIcon);

        setState((){
          _markers.add(_currentMarker);
          _mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 14.0));
        });
      }
    });
  }
}