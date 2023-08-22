import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moda/moda.dart';

void main() {
  runApp(const ModaExampleApp());
}

class ModaExampleApp extends StatelessWidget {
  const ModaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moda Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: MediaQuery.of(context).platformBrightness,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Moda Example'),
      ),
      child: Center(
        child: CupertinoButton.filled(
          child: Text('Show bulletin'),
          onPressed: () async {
            await showBulletin(
              context: context,
              builder: (context) => AirPodsProChargingDummy(),
            );
          },
        ),
      ),
    );
  }
}

class AirPodsProRenameDummy extends StatelessWidget {
  const AirPodsProRenameDummy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your\'re all set!',
            style: CupertinoTheme.of(context)
                .textTheme
                .navLargeTitleTextStyle
                .copyWith(letterSpacing: -1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            onPressed: Navigator.of(context, rootNavigator: true).pop,
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}

class AirPodsProChargingDummy extends StatelessWidget {
  const AirPodsProChargingDummy({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
          builder: (context) {
            return Scaffold(
              body: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'AirPods Pro',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navLargeTitleTextStyle
                          .copyWith(letterSpacing: -1),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                        child:
                            Image.asset('assets/airpods_pro_placeholder.jpeg')),
                    CupertinoButton(
                        child: Text('Continue'),
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => AirPodsProRenameDummy()));
                        }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
