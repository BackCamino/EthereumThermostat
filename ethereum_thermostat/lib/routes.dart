
import 'package:ethereumthermostat/pages/auth_page.dart';
import 'package:ethereumthermostat/pages/wallet_page.dart';
import 'package:ethereumthermostat/pages/home_page.dart';
import 'package:ethereumthermostat/pages/splash_page.dart';
import 'package:ethereumthermostat/pages/edit_private_key.dart';
import 'package:flutter/material.dart';

class Routes {

  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => SplashPage(),
    };
  }

  static Route onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case 'ConnectionError': return CustomRoute<bool>(builder: (BuildContext context) => SplashPage());
      case 'HomePage': return CustomRoute<bool>(builder: (BuildContext context) => HomePage());
      case 'AnaliticsPage': return CustomRoute<bool>(builder: (BuildContext context) => WalletPage());
      case 'WalletConfigPage': return CustomRoute<bool>(builder: (BuildContext context) => EditPrivateKey());
      case 'AuthPage': return CustomRoute<bool>(builder: (BuildContext context) => AuthPage());
      default: return onUnknownRoute(RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Comming soon..'),
        ),
      ),
    );
  }
}


class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == "SplashPage") {
      return child;
    }
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
      child: child,
    );
  }
}