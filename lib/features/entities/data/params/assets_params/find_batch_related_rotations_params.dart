class FindBatchRelatedRotationsParams {
  String? currentBatchId;
  String batchId;
  String batchName;
  DateTime startDate;
  DateTime endDate;

  FindBatchRelatedRotationsParams(
      {required this.batchId,
      required this.batchName,
      required this.startDate,
      required this.endDate,
      this.currentBatchId});
}
