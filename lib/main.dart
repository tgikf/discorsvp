import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/profile.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

const AUTH0_DOMAIN = 'gizzz-service.eu.auth0.com';
const AUTH0_CLIENT_ID = '8TJo5suoAGBGH6KjT0i66oFcfS3TW4BL';

const AUTH0_REDIRECT_URI = 'me.freitag.discorsvp://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

void main() {
  runApp(MyApp(key: UniqueKey()));
}

class MyApp extends StatefulWidget {
  const MyApp({required Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  late String name;
  late String picture;
  late String authToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiscoRSVP',
      theme:
          ThemeData(primarySwatch: Colors.indigo, brightness: Brightness.dark),
      home: Scaffold(
        //appBar: AppBar(title: const Text('DiscoRsvp'), centerTitle: true),
        body: Center(
          child: isBusy
              ? const CircularProgressIndicator()
              : isLoggedIn
                  ? Home(
                      authToken,
                      Profile(
                        logoutAction,
                        name,
                        picture,
                        key: UniqueKey(),
                      ),
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
          name = idFields['name'].toString();
          picture = profile['picture'].toString();
          authToken = idToken;
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

  @override
  void initState() {
    initAction();
    super.initState();
  }

  Future<void> initAction() async {
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
          name = idFields['name'].toString();
          picture = profile['picture'].toString();
          authToken = idToken;
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
