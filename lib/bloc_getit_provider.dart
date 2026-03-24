import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class BlocFactory {
  const BlocFactory({required this.injector});

  final GetIt injector;

  T get<T extends StateStreamableSource<Object?>>([
    Object? param1,
    Object? param2,
  ]) => injector.get<T>(param1: param1, param2: param2);
}

class BlocFactoryProvider extends SingleChildStatelessWidget {
  const BlocFactoryProvider({super.key, super.child, required this.getIt});

  final GetIt getIt;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Provider<BlocFactory>(
      create: (context) => BlocFactory(injector: getIt),
      child: child,
    );
  }
}

class SimpleBlocProvider<T extends StateStreamableSource<Object?>>
    extends BlocProvider<T> {
  SimpleBlocProvider({super.key, super.lazy, super.child})
    : super(create: (context) => context.blocFactory.get<T>());
}

extension ContextX on BuildContext {
  BlocFactory get blocFactory => read<BlocFactory>();
}
