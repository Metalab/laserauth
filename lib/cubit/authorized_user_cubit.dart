import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/api.dart';

final authorizedUser = AuthorizedUserCubit();

class AuthorizedUserCubit extends Cubit<List<AuthorizedUser>> {
  AuthorizedUserCubit() : super(const []) {
    userList().listen(emit);
  }
}
