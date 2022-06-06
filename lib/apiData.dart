//import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show utf8;

class MoneyRate
{
    String sCurrencyCode;
    String sCurrencyName;
    String sSelVal;
    String sTranferVal;
    String sBuyVal;

    MoneyRate(this.sCurrencyCode, this.sCurrencyName , this.sBuyVal, this.sTranferVal, this.sSelVal);
}

Future<List<MoneyRate>> getMoneyRate() async {
  Map<String, String> headers = {"Accept": "text/html,application/xml"};
  final response = await http.get(
      Uri.parse('https://portal.vietcombank.com.vn/Usercontrols/TVPortal.TyGia/pXML.aspx'), headers: headers);
  if (response.statusCode == 200) {
    // status code == 200 thì trả về kết quả thành công
    // nếu sucess == true thì có giá trị
    final document = XmlDocument.parse(utf8.decode(response.bodyBytes));
    var rateList = document.getElement('ExrateList');
    var rateData = List<MoneyRate>.empty();
    rateData = rateList!.findAllElements('Exrate').map<MoneyRate>((e) => MoneyRate(e.getAttribute('CurrencyCode').toString(),
    e.getAttribute('CurrencyName').toString(), 
    e.getAttribute('Buy').toString(),
    e.getAttribute('Transfer').toString(),
    e.getAttribute('Sell').toString())).toList();
      return rateData;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Kết nối thất bại!');
  }
}