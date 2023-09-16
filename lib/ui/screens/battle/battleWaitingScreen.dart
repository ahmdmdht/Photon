import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class battleWaitingScreen extends StatefulWidget {
  const battleWaitingScreen({Key? key}) : super(key: key);

  @override
  State<battleWaitingScreen> createState() => _battleWaitingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(

            providers: [],
            child: battleWaitingScreen(
             /// isGuest: routeSettings.arguments as bool,
            )));
  }

}

class _battleWaitingScreenState extends State<battleWaitingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
             color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
