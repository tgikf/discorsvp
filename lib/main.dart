import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';

import 'screens/login.dart';
import 'screens/home.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

const AUTH0_DOMAIN = 'gizzz-service.eu.auth0.com';
const AUTH0_CLIENT_ID = '8TJo5suoAGBGH6KjT0i66oFcfS3TW4BL';

const AUTH0_REDIRECT_URI = 'me.freitag.discorsvp://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

MaterialColor customOrange = MaterialColor(
  0xFFFFA726,
  <int, Color>{
    50: Color(0xFFFFF3E0),
    100: Color(0xFFFFE0B2),
    200: Color(0xFFFFCC80),
    300: Color(0xFFFFB74D),
    400: Color(0xFFFFA726),
    500: Color(0xFFF57C00),
    600: Color(0xFFF57C00),
    700: Color(0xFFF57C00),
    800: Color(0xFFEF6C00),
    900: Color(0xFFE65100),
  },
);

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() {
  runApp(MyApp(key: UniqueKey()));
}

class MyApp extends StatefulWidget {
  const MyApp({required Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseMessaging _messaging;
  late String _deviceToken;
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  late Map<String, String> _profile;
  late String _authToken;

  void registerNotification() async {
    await Firebase.initializeApp();
    _deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Messaging permissions granted');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final body = message.notification?.body;

        if (body != null) {
          showSimpleNotification(Text(body),
              background: customOrange.shade400, foreground: Colors.black);
        }
      });
    } else {
      debugPrint('Messaging permissions rejected');
    }
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final List<String> parts = idToken.split('.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    const String url = 'https://$AUTH0_DOMAIN/userinfo';
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          scopes: <String>['openid', 'profile', 'offline_access'],
          // promptValues: ['login']
        ),
      );

      final idToken = result?.idToken;
      final accessToken = result?.accessToken;
      final refreshToken = result?.refreshToken;
      if (idToken != null && accessToken != null && refreshToken != null) {
        final Map<String, dynamic> idFields = parseIdToken(idToken);
        final Map<String, dynamic> profile = await getUserDetails(accessToken);

        await secureStorage.write(key: 'refresh_token', value: refreshToken);

        setState(() {
          isBusy = false;
          isLoggedIn = true;
          _profile = {
            'userName': idFields['name'].toString(),
            'userId': idFields['sub'].toString().split('|')[2],
            'pictureUri': profile['picture'].toString(),
          };
          _authToken = idToken;
        });
      }
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> logoutAction() async {
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  Future<void> checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
          'Initial message with ${initialMessage.notification?.title}, ${initialMessage.notification?.body}');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      initAuth();
      registerNotification();
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final body = message.notification?.body;
        if (body != null) {
          showSimpleNotification(Text(body),
              background: customOrange.shade400, foreground: Colors.black);
        }
      });
      checkForInitialMessage();
    });
  }

  Future<void> initAuth() async {
    final String? storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    setState(() {
      isBusy = true;
    });

    try {
      final TokenResponse? response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final idToken = response?.idToken;
      final accessToken = response?.accessToken;
      if (idToken != null && accessToken != null) {
        final Map<String, dynamic> idFields = parseIdToken(idToken);
        final Map<String, dynamic> profile = await getUserDetails(accessToken);

        setState(() {
          isBusy = false;
          isLoggedIn = true;
          _profile = {
            'userName': idFields['name'].toString(),
            'userId': idFields['sub'].toString().split('|')[2],
            'pictureUri': profile['picture'].toString(),
          };
          _authToken = idToken;
        });
      }

      final refreshToken = response?.refreshToken;
      if (refreshToken != null) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
    } on Exception catch (e, s) {
      debugPrint('error on refresh token: $e - stack: $s');
      await logoutAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      title: 'DiscoRSVP',
      theme:
          ThemeData(primarySwatch: customOrange, brightness: Brightness.dark),
      home: Scaffold(
        body: Center(
          child: isBusy
              ? const CircularProgressIndicator()
              : isLoggedIn
                  ? Home(
                      userProfile: _profile,
                      authToken: _authToken,
                      deviceToken: _deviceToken,
                      logoutAction: logoutAction,
                      key: UniqueKey())
                  : Login(loginAction, errorMessage, key: UniqueKey()),
        ),
      ),
    ));
  }
}
