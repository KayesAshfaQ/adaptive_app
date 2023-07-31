import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

import 'app_state.dart';

typedef _AdaptiveLoginButtonWidget = Widget Function({
  required VoidCallback? onPressed,
});

class AdaptiveLogin extends StatelessWidget {
  final ClientId clientId;
  final List<String> scopes;
  final Widget loginButtonChild;

  const AdaptiveLogin({
    super.key,
    required this.clientId,
    required this.scopes,
    required this.loginButtonChild,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return _GoogleSignInLogin(
        button: _loginButton,
        scopes: scopes,
      );
    } else {
      return _GoogleApisAuthLogin(
        button: _loginButton,
        scopes: scopes,
        clientId: clientId,
      );
    }
  }

  Widget _loginButton({required VoidCallback? onPressed}) => ElevatedButton(
        onPressed: onPressed,
        child: loginButtonChild,
      );
}

class _GoogleSignInLogin extends StatefulWidget {
  final _AdaptiveLoginButtonWidget button;
  final List<String> scopes;

  const _GoogleSignInLogin({
    required this.button,
    required this.scopes,
  });

  @override
  State<_GoogleSignInLogin> createState() => _GoogleSignInLoginState();
}

class _GoogleSignInLoginState extends State<_GoogleSignInLogin> {
  late final GoogleSignIn _googleSignIn;

  @override
  initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      scopes: widget.scopes,
    );
    _googleSignIn.onCurrentUserChanged.listen((account) {
      print(account!.email);
      if (account != null) {
        _googleSignIn.authenticatedClient().then((authClient) {
          if (authClient != null) {
            print(authClient.credentials.accessToken);
            context.read<AuthedUserPlaylists>().authClient = authClient;
            context.go('/');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.button(onPressed: () {
          _googleSignIn.signIn();
        }),
      ),
    );
  }
}

class _GoogleApisAuthLogin extends StatefulWidget {
  final _AdaptiveLoginButtonWidget button;
  final List<String> scopes;
  final ClientId clientId;

  const _GoogleApisAuthLogin({
    required this.button,
    required this.scopes,
    required this.clientId,
  });

  @override
  State<_GoogleApisAuthLogin> createState() => _GoogleApisAuthLoginState();
}

class _GoogleApisAuthLoginState extends State<_GoogleApisAuthLogin> {
  Uri? _authUrl;

  @override
  initState() {
    super.initState();
    clientViaUserConsent(widget.clientId, widget.scopes, (url) {
      setState(() {
        _authUrl = Uri.parse(url);
      });
    }).then(
      (authClient) {
        context.read<AuthedUserPlaylists>().authClient =
            authClient; // save authClient to provider
        context.go('/'); // go to playlist page
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUrl = _authUrl;
    if (authUrl != null) {
      return Scaffold(
        body: Center(
          child: Link(
            uri: authUrl,
            builder: (context, followLink) =>
                widget.button(onPressed: followLink),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
