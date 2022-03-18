import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/login.dart';
import 'screens/home.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

const AUTH0_DOMAIN = 'gizzz-service.eu.auth0.com';
const AUTH0_CLIENT_ID = '8TJo5suoAGBGH6KjT0i66oFcfS3TW4BL';

const AUTH0_REDIRECT_URI = 'me.freitag.discorsvp://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
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
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  late Map<String, String> _profile;
  late String _authToken;

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();
    print('token');
    print(await FirebaseMessaging.instance.getToken());
    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        print(message.notification?.title);
        print(message.notification?.body);
        showSnackBar(message.notification?.body ?? 'noPushMessageBody');
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiscoRSVP',
      theme:
          ThemeData(primarySwatch: Colors.indigo, brightness: Brightness.dark),
      home: Scaffold(
        body: Center(
          child: isBusy
              ? const CircularProgressIndicator()
              : isLoggedIn
                  ? Home(
                      authToken: _authToken,
                      userProfile: _profile,
                      logoutAction: logoutAction,
                      key: UniqueKey())
                  : Login(loginAction, errorMessage, key: UniqueKey()),
        ),
      ),
    );
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
      print(
          'Initial message with ${initialMessage.notification?.title}, ${initialMessage.notification?.body}');
    }
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      content: Row(children: <Widget>[
        Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary),
        )
      ]),
      duration: const Duration(seconds: 5),
    ));
  }

  @override
  void initState() {
    initAuth();
    registerNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'App opened from push via ${message.notification?.title}: ${message.notification?.body}');
      showSnackBar(
          message.notification?.body ?? 'empty openapp notification body');
    });
    checkForInitialMessage();

    super.initState();
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
}
