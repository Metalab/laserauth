import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/api.dart';
import 'package:laserauth/cubit/configuration_state.dart';

class AuthorizedUserCubit extends Cubit<List<AuthorizedUser>> {
  AuthorizedUserCubit({required Configuration configuration}) : super(const []) {
    userList(configuration.updateUrl, configuration.authToken).listen(emit);
  }
}
