<img src="https://github.com/breitburg/glimpse/assets/25728414/bdd3284f-4c54-4ae4-8c65-c2fbc880247f" width="250px" align="right" />

# Glimpse

A minimalistic modal sheet inspired by AirPods that can be used to present quick information, such as onboarding, permissions, notifications, statuses, or bulletins.

```dart
import 'package:glimpse/glimpse.dart';

await showGlimpse(
    context: context,
    height: 450, // optional
    dismissible: true, // optional
    builder: (context) => Text('Bonjour'),
);
```

## Route

When using a route, you should also insert a `initializeGlimpse()` before your `runApp()` call to manually initialize Glimpse. It is required for calculating the correct corner radius of the modal sheet on iOS.

```dart
void main() async {
    await initializeGlimpse();
    // ...
    runApp(YourApp());
}
```

When you've done that, you can use the `GlimpseModalRoute` to present a modal sheet:

```dart
import 'package:glimpse/glimpse.dart';

await Navigator.of(context).push(
    GlimpseModalRoute(
        builder: (BuildContext context) {
            return Text('Bonjour!');
        },
    ),
);
```