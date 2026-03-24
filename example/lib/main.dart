import 'package:bloc_getit_provider/bloc_getit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'counter_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register CounterCubit as a factory so each registration creates a new
  // instance. Use registerSingleton if you want a shared instance instead.
  getIt.registerFactory<CounterCubit>(() => CounterCubit());
}

void main() {
  setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocFactoryProvider wraps GetIt and exposes BlocFactory via Provider,
    // making context.blocFactory available throughout the widget tree.
    return BlocFactoryProvider(
      getIt: getIt,
      child: const MaterialApp(home: CounterPage()),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SimpleBlocProvider<T> creates the cubit from BlocFactory (GetIt) and
    // automatically closes it when the widget is disposed.
    return SimpleBlocProvider<CounterCubit>(
      child: Scaffold(
        appBar: AppBar(title: const Text('bloc_getit_provider example')),
        body: const CounterView(),
      ),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterCubit>().state;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Counter value:'),
          Text('$count', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'decrement',
                onPressed: () => context.read<CounterCubit>().decrement(),
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'increment',
                onPressed: () => context.read<CounterCubit>().increment(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
