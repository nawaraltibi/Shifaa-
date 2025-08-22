class UserAuthModel {
  final bool hasAccount;
  final bool twoFactorEnabled;
  final String? token;
  final Map<String, dynamic>? user;

  UserAuthModel({
    required this.hasAccount,
    required this.twoFactorEnabled,
    this.token,
    this.user,
  });

  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    return UserAuthModel(
      hasAccount: data['has_account'] ?? false,
      twoFactorEnabled: parseBool(data['two_factor_enabled']),
      token: data['token'],
      user: data['user'],
    );
  }
}
