class UserUpdateParams {
  final String id;
  final String name;
  final String lastName;
  final String userName;
  final String phone;
  final String password;

  const UserUpdateParams({
    required this.id,
    required this.name,
    required this.lastName,
    required this.userName,
    required this.phone,
    required this.password
  });
}