---
name: bloc_getit_provider-package
description: >
  How to use the bloc_getit_provider Flutter package, which bridges flutter_bloc and get_it
  so that Blocs and Cubits registered in GetIt can be injected into the widget tree without
  boilerplate create: callbacks. ALWAYS use this skill whenever the user wants to provide,
  inject, register, or wire up any Bloc or Cubit in a project that has bloc_getit_provider
  in its pubspec.yaml — even if they don't mention the package by name. This includes adding
  a new BlocProvider, creating a new Cubit or Bloc, connecting state management to a screen,
  using SimpleBlocProvider, BlocFactory, context.blocFactory, or reducing BlocProvider
  boilerplate with get_it. If bloc_getit_provider is present in the project, this skill
  should be the default guide for all Bloc/Cubit provision tasks.
---

# bloc_getit_provider

## What this package does

`bloc_getit_provider` is a thin glue layer between **get_it** (service locator) and
**flutter_bloc** (state management). It lets you register Blocs/Cubits in GetIt once and
inject them anywhere in the widget tree with zero `create:` boilerplate.

**Public API at a glance:**

| Symbol | Role |
|---|---|
| `BlocFactoryProvider` | Wraps the app root; injects `BlocFactory` into the Provider tree |
| `BlocFactory` | GetIt wrapper; `get<T>()` resolves any `StateStreamableSource` |
| `SimpleBlocProvider<T>` | Drop-in `BlocProvider` that resolves `T` from `BlocFactory` automatically |
| `context.blocFactory` | Shorthand for `context.read<BlocFactory>()` |

---

## Setup

### 1. Add dependency

```yaml
dependencies:
  bloc_getit_provider: ^0.0.1
```

### 2. Register Blocs/Cubits in GetIt

Do this before `runApp`. Use `registerFactory` for a fresh instance per screen,
or `registerSingleton` / `registerLazySingleton` for shared state.

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerFactory<CounterCubit>(() => CounterCubit());
}
```

### 3. Wrap the app with `BlocFactoryProvider`

Place it high enough in the tree that all consumers are descendants — typically
right around (or inside) `MaterialApp`.

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
      child: const MaterialApp(home: HomePage()),
    );
  }
}
```

---

## Providing Blocs/Cubits

### Option A — `SimpleBlocProvider<T>` (recommended, zero boilerplate)

Resolves `T` from GetIt automatically and closes it on dispose.

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleBlocProvider<CounterCubit>(
      child: Scaffold(body: const CounterView()),
    );
  }
}
```

Supports the same `lazy` and `child` parameters as the standard `BlocProvider`.

### Option B — `BlocProvider` + `context.blocFactory` (more control)

Use when you need extra lifecycle hooks, a `key`, or want to be explicit about
the `create:` callback.

```dart
BlocProvider<CounterCubit>(
  create: (context) => context.blocFactory.get<CounterCubit>(),
  child: const Scaffold(body: CounterView()),
)
```

### Option C — Parametrised factories (`registerFactoryParam`)

When a Cubit/Bloc needs a runtime argument (e.g. an entity id), register it with
`registerFactoryParam` and forward the argument through `blocFactory.get<T>(param)`.

```dart
// Registration
getIt.registerFactoryParam<DetailCubit, int, void>(
  (id, _) => DetailCubit(id: id),
);

// Injection (param1 maps to the first factory parameter)
BlocProvider<DetailCubit>(
  create: (context) => context.blocFactory.get<DetailCubit>(itemId),
  child: const DetailView(),
)
```

`BlocFactory.get<T>()` accepts up to two positional parameters, forwarded directly
to GetIt's `param1` / `param2`.

---

## Consuming state

Nothing changes here — use standard `flutter_bloc` APIs.

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

`BlocBuilder`, `BlocListener`, `BlocConsumer`, and `MultiBlocProvider` all work
normally — this package only changes how the Bloc/Cubit is *created*, not how it is *consumed*.

---

## Common patterns

### Multiple cubits on one screen

```dart
MultiBlocProvider(
  providers: [
    SimpleBlocProvider<UserCubit>(),
    SimpleBlocProvider<SettingsCubit>(),
  ],
  child: const ProfilePage(),
)
```

### App-wide singleton cubit

```dart
// Registration
getIt.registerLazySingleton<AuthCubit>(() => AuthCubit());

// Injection — same instance returned every time
SimpleBlocProvider<AuthCubit>(child: const AppShell())
```

> **Lifecycle note:** `SimpleBlocProvider` calls `close()` when the widget is
> disposed. For singletons that must outlive a single screen, either manage their
> lifetime externally or avoid wrapping them in a `SimpleBlocProvider` that can
> be unmounted.

---

## Quick-reference checklist

- [ ] `BlocFactoryProvider(getIt: getIt, ...)` wraps the widget tree
- [ ] Each Bloc/Cubit is registered in GetIt (`registerFactory` or `registerSingleton`)
- [ ] Use `SimpleBlocProvider<T>` for the typical zero-boilerplate case
- [ ] Use `BlocProvider(create: (ctx) => ctx.blocFactory.get<T>())` when extra control is needed
- [ ] Forward constructor params via `blocFactory.get<T>(param)` with `registerFactoryParam`
- [ ] Consume state with standard `flutter_bloc` (`context.watch`, `context.read`, `BlocBuilder`, etc.)
