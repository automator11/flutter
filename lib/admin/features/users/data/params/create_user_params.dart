class CreateUserParams {
  final String? id; // not provide for creating new user
  final String? tenantId; // not provide for creating new user
  final String? email;
  final String? customerId;
  final String? ownerId;
  final String? authority;
  final String? firstName;
  final String? lastName;
  final bool sendActivationMail;

  CreateUserParams(
      {this.id,
      this.tenantId,
      this.email,
      this.customerId,
      this.ownerId,
      this.firstName,
      this.lastName,
      this.authority,this.sendActivationMail = false});
}
