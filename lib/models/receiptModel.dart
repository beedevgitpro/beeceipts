class Receipt{
  String receiptNumber;
  double total,taxes;
  String merchantName,address;
  String date;
  String receiptImage; //this can also be the download URL
   Receipt.fromJson(Map<String, dynamic> json)
      : merchantName = json['merchant_name'],
      receiptImage=json['receipt_image'],
      // taxes=json['taxes'],
        total = json['total'],
        // address=json['address'],
        // receiptNumber=json['invoiceNumber'],
        date=json['date'];
    Map<String, dynamic> toJson() =>
    {
      'merchant_name': merchantName,
      'taxes':taxes,
      'total': total,
      'address':address,
      'receiptNumber':receiptNumber,
      'date':date
    };

}