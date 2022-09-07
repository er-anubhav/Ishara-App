import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class GetStorageHelper {
  static setinitialdata() {
    box.writeIfNull('is_logged_in', false);
    box.writeIfNull('id', "");
    box.writeIfNull('username', "");
    box.writeIfNull('mobileno', "");
    box.writeIfNull('email', "");
    box.writeIfNull('balance', "");
    box.writeIfNull('refer_id', "");
    box.writeIfNull('imagePath', "");
    box.writeIfNull('access_token', "");
  }

  static setdata(id, username, mobileno, email, profilePic, accessToken) {
    box.write('is_logged_in', true);
    box.write('id', id);
    box.write('username', username);
    box.write('mobileno', mobileno);
    box.write('email', email);
    box.write('imagePath', profilePic);
    box.write('access_token', accessToken);
  }
}
