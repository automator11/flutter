class CreateCustomerParams {
  final String? id; // not provide for creating new customer
  final int? createdTime;
  final String? tenantId; // not provide for creating new customer
  final String title;
  final String? email;
  final String? phone;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? address2;
  final String? zip;
  final String? parentCustomerId;
  final String? customerId;
  final String? ownerId;

  CreateCustomerParams(
      {this.id,
      this.createdTime,
      this.tenantId,
      required this.title,
      this.email,
      this.phone,
      this.country,
      this.state,
      this.city,
      this.address,
      this.address2,
      this.zip,
      this.parentCustomerId,
      this.customerId,
      this.ownerId});
}
