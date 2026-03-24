# bloc_getit_provider

A Flutter package that bridges [flutter_bloc](https://pub.dev/packages/flutter_bloc) and [get_it](https://pub.dev/packages/get_it), letting you provide Blocs and Cubits from your GetIt service locator directly into the widget tree — with no boilerplate `create:` callbacks.

## Features

- **`BlocFactoryProvider`** — wraps your `GetIt` instance and exposes a `BlocFactory` to the widget tree via `Provider`.
- **`SimpleBlocProvider<T>`** — a drop-in replacement for `BlocProvider` that resolves `T` from GetIt automatically and closes it when the widget is disposed.
- **`context.blocFactory`** — extension for direct access to the `BlocFactory` anywhere in the tree.
- Works with any `Bloc` or `Cubit` registered in GetIt, including factories and singletons.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  bloc_getit_provider: ^0.0.1
```

Register your Blocs/Cubits in GetIt before runApp:

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerFactory<CounterCubit>(() => CounterCubit());
}
```

## Usage

### 1. Wrap your app with `BlocFactoryProvider`

```dart
void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocFactoryProvider(
      getIt: getIt,
      child: const MaterialApp(home: CounterPage()),
    );
  }
}
```

### 2. Use `SimpleBlocProvider<T>` to inject a Bloc or Cubit

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleBlocProvider<CounterCubit>(
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter')),
        body: const CounterView(),
      ),
    );
  }
}
```

### 3. Consume state as usual with `flutter_bloc`

```dart
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterCubit>().state;

    return Column(
      children: [
        Text('$count'),
        ElevatedButton(
          onPressed: () => context.read<CounterCubit>().increment(),
          child: const Text('+'),
        ),
      ],
    );
  }
}
```

### Alternative: use `BlocProvider` with `context.blocFactory`

If you need more control — e.g. passing constructor parameters or chaining multiple providers — you can use a plain `BlocProvider` and call `context.blocFactory.get<T>()` directly:

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (context) => context.blocFactory.get<CounterCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter')),
        body: const CounterView(),
      ),
    );
  }
}
```

`context.blocFactory.get<T>()` also accepts up to two positional parameters that are forwarded to GetIt, which is useful when the Cubit/Bloc is registered with `registerFactoryParam`:

```dart
// registration
getIt.registerFactoryParam<DetailCubit, int, void>(
  (id, _) => DetailCubit(id: id),
);

// usage
BlocProvider<DetailCubit>(
  create: (context) => context.blocFactory.get<DetailCubit>(itemId),
  child: const DetailView(),
)
```

See the [`/example`](example) folder for a full working counter app.

## API

| Class / Extension       | Description                                                                                                                    |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `BlocFactoryProvider`   | `SingleChildStatelessWidget` that injects a `BlocFactory` built from the provided `GetIt` instance.                            |
| `BlocFactory`           | Thin wrapper around `GetIt` with a typed `get<T>()` method constrained to `StateStreamableSource`.                             |
| `SimpleBlocProvider<T>` | Extends `BlocProvider<T>` and resolves `T` from the nearest `BlocFactory` in the tree. Supports `lazy` and `child` forwarding. |
| `context.blocFactory`   | `BuildContext` extension that calls `context.read<BlocFactory>()`.                                                             |

## Additional information

- File issues and feature requests on the project repository.
- Pull requests are welcome.
- Requires Flutter ≥ 1.17.0 and Dart ≥ 3.10.7.
