class UserChangePasswordParams {
  final String oldPassword;
  final String newPassword;
  final String verifyNewPassword;

  const UserChangePasswordParams(
      {required this.newPassword, required this.oldPassword, required this.verifyNewPassword});
}
