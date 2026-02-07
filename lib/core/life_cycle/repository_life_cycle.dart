import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../shared/shared.dart';

mixin class RepositoryLifeCycle {
  final httpAdapter = currentContext.read<HttpAdapter>();
}
