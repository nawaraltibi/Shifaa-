import 'package:shifaa/core/utils/shared_prefs_helper.dart';

String? userToken;

void loadToken() async {
  userToken = await SharedPrefsHelper.instance.getToken();
  print("Token: $userToken");
}
