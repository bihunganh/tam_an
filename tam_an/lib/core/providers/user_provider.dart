import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;

  Future<void> loadUser() async {
    final u = await _authService.getCurrentUser();
    _user = u;
    notifyListeners();
  }

  void setUser(UserModel? u) {
    _user = u;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
