import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/glimpse.dart';

void main() {
  runApp(const GlimpseExampleApp());
}

class GlimpseExampleApp extends StatelessWidget {
  const GlimpseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glimpse Example',
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: MediaQuery.of(context).platformBrightness,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Glimpse Example'),
      ),
      child: Center(
        child: CupertinoButton.filled(
          child: const Text('Show Glimpse'),
          onPressed: () async {
            await showGlimpse(
              context: context,
              builder: (context) => Navigator(
                onGenerateRoute: (settings) {
                  return CupertinoPageRoute(
                    builder: (context) {
                      return const AirPodsProChargingDummy();
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class AirPodsProChargingDummy extends StatelessWidget {
  const AirPodsProChargingDummy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AirPods Pro',
              style:
                  CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
              textAlign: TextAlign.center,
            ),
            Expanded(child: Image.asset('assets/airpods_pro_placeholder.jpeg')),
            CupertinoButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const AllDoneDummy(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AllDoneDummy extends StatelessWidget {
  const AllDoneDummy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'That\'s it!',
            style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
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
