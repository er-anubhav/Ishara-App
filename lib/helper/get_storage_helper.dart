import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class GetStorageHelper {
  static void setinitialdata() {
    box.writeIfNull('is_logged_in', false);
    box.writeIfNull('has_profile_context', false);
    box.writeIfNull('id', "");
    box.writeIfNull('username', "");
    box.writeIfNull('mobileno', "");
    box.writeIfNull('email', "");
    box.writeIfNull('balance', "");
    box.writeIfNull('refer_id', "");
    box.writeIfNull('imagePath', "");
    box.writeIfNull('access_token', "");
  }

  static void setdata(
    String id,
    String username,
    String mobileno,
    String email,
    String profilePic,
    String accessToken, {
    bool hasProfileContext = false,
  }) {
    box.write('is_logged_in', true);
    box.write('has_profile_context', hasProfileContext);
    box.write('id', id);
    box.write('username', username);
    box.write('mobileno', mobileno);
    box.write('email', email);
    box.write('imagePath', profilePic);
    box.write('access_token', accessToken);
  }
}
