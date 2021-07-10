import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/app/app.dart';
import 'package:flutter_firebase_login/home/view/maps.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    // final textTheme = Theme.of(context).textTheme;
    print(user);
    return Scaffold(
        body: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () =>
                  context.read<AppBloc>().add(AppLogoutRequested()),
              icon: Icon(Icons.exit_to_app),
              tooltip: 'Logout',
            )
          ],
          //   bottom: TabBar(
          //     tabs: [
          //       Tab(icon: Icon(Icons.map_sharp)),
          //       // Tab(icon: Icon(Icons.group_work)),
          //       // Tab(icon: Icon(Icons.chat)),
          //     ],
          //   ),
          //   title: Text('HMMMMMMM'),
          // ),
          // body: TabBarView(
          //   children: [
          //     // Icon(Icons.directions_car),
          //     FireMap(),
          //     // Icon(Icons.directions_transit),
          //     // Icon(Icons.directions_bike),
          //   ],
          // ),
        ),
        body: FireMap(),
      ),
      // body: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [Center(child: CircularProgressIndicator())],
      // )
      // body: Align(
      //   alignment: const Alignment(0, -1 / 3),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: <Widget>[
      //       Avatar(photo: user.photo),
      //       const SizedBox(height: 4.0),
      //       Text(user.email ?? '', style: textTheme.headline6),
      //       const SizedBox(height: 4.0),
      //       Text(user.name ?? '', style: textTheme.headline5),
      //     ],
      //   ),
      // ),
    ));
  }
}
