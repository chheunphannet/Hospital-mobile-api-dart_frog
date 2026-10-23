import 'package:bcrypt/bcrypt.dart';

class Hasher {
  String hash(String password) => BCrypt.hashpw(password, BCrypt.gensalt());
  bool verify(String password, String hash) => BCrypt.checkpw(password, hash);
}
