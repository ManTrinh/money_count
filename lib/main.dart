import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_count/apiData.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<MoneyRate>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = getMoneyRate();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
        footerTriggerDistance: 15,
        dragSpeedRatio: 0.91,
        headerBuilder: () => const MaterialClassicHeader(),
        footerBuilder: () => const ClassicFooter(),
        enableLoadingWhenNoData: false,
        enableRefreshVibrate: false,
        enableLoadMoreVibrate: false,
        shouldFooterFollowWhenNotFull: (state) {
          // If you want load more with noMoreData state ,may be you should return false
          futureAlbum = getMoneyRate();
          return false;
        },
        child: MaterialApp(
            home: DefaultTabController(
          length: 3,
          child: Scaffold(
              backgroundColor: const Color.fromRGBO(5, 48, 52, 1),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50.0), // here the desired height
                child: AppBar(
                    backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
                    bottom: const TabBar(
                      tabs: [
                        Tab(
                            icon: Icon(
                          Icons.attach_money,
                          size: 40.0,
                        )),
                        Tab(
                            icon: Icon(
                          Icons.calculate,
                          size: 40.0,
                        )),
                        Tab(
                            icon: Icon(
                          Icons.search_rounded,
                          size: 40.0,
                        )),
                      ],
                    )),
              ),
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: TabBarView(children: [
                  ShowMoneyRate(),
                  //Icon(Icons.car_rental_rounded),
                  CalcularMoney(),
                  const Icon(Icons.pix_outlined),
                ]),
              )),
        )));
  }

  Widget ShowMoneyRate() {
    return Center(
        child: Column(
      children: <Widget>[
        const SizedBox(
          height: 30,
        ),
        FutureBuilder<List<MoneyRate>>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SponsorList(list: snapshot.data!.toList());
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        )
        //Container(child: Text("Man Trinh Design")),
      ],
    ));
  }

  Widget CalcularMoney() {
    return Center(
        child: Column(
      children: <Widget>[
        const SizedBox(
          height: 30,
        ),
        FutureBuilder<List<MoneyRate>>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CalcurlarMoney(list: snapshot.data!.toList());
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        )
        //Container(child: Text("Man Trinh Design")),
      ],
    ));
  }
}

class SponsorList extends StatefulWidget {
  final List<MoneyRate> list;
  const SponsorList({required this.list});

  @override
  _SponsorListState createState() => _SponsorListState();
}

class _SponsorListState extends State<SponsorList> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: widget.list.map((moneyData) {
        return Builder(builder: (BuildContext context) {
          String sMoneyCode = moneyData.sCurrencyCode;
          String sMoneyName = moneyData.sCurrencyName;
          String sBuy = moneyData.sBuyVal;
          String sSel = moneyData.sSelVal;
          String sTranfer = moneyData.sTranferVal;
          return Wrap(
            direction: Axis.horizontal,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/$sMoneyCode.png'),
                    fit: BoxFit.fill,
                  ),
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(255, 152, 0, 1),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.green[100],
                shadowColor: Colors.blueGrey,
                elevation: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.album,
                          color: Color.fromRGBO(255, 152, 0, 60), size: 45),
                      title: Text(
                        "Tỷ đối ngoại hối (theo VCB) của đồng $sMoneyName",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Giá mua vào : $sBuy',
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Giá bán ra : $sSel',
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Giá chuyển đổi : $sTranfer',
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      }).toList(),
      options: CarouselOptions(
        height: 600,
        autoPlay: true,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;
      final f = NumberFormat("#,###");
      final number =
          int.parse(newValue.text.replaceAll(f.symbols.GROUP_SEP, ''));
      final newString = f.format(number);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
            offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }
}

class CalcurlarMoney extends StatefulWidget {
  final List<MoneyRate> list;
  const CalcurlarMoney({required this.list});

  @override
  _CalcurlarMoneyState createState() => _CalcurlarMoneyState();
}

class _CalcurlarMoneyState extends State<CalcurlarMoney> {
  List MoneyName = [];
  late TextEditingController _controller;
  late TextEditingController _controller1;

  @override
  void initState() {
    super.initState();
    for (var data in widget.list) {
      MoneyName.add(data.sCurrencyName);
    }
    _controller = TextEditingController();
    _controller1 = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    _controller1.dispose();
    super.dispose();
  }

  String? selectedValue;
  double selectedMoneyVal = 0.0;
  double changeMoneyVal = 0.0;
  String displayMoneyVal = "0,0";
  bool bCheck = false;
  bool isFirst = true;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        SizedBox(
          width: 350,
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              hint: Row(
                children: const [
                  Icon(
                    Icons.list,
                    size: 16,
                    color: Colors.yellow,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      'Chọn loại tiền quy đổi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              items: MoneyName.map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
              value: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value as String;
                  if (selectedValue == "Chọn loại tiền quy đổi") {
                    _controller.text = "";
                    _controller1.text = "";
                    bCheck = false;
                  } else {
                    _controller.text = "0";
                    _controller1.text = "0.0";
                    bCheck = true;
                    for (var data in widget.list) {
                      //data.sBuyVal.replaceAll("-", "0");
                      if (data.sCurrencyName == selectedValue) {
                        selectedMoneyVal = double.parse(data.sBuyVal
                            .replaceAll("-", "0")
                            .replaceAll(",", ""));
                        if (selectedMoneyVal == 0.0) {
                          _controller.text = "0";
                          _controller1.text = "0.0";
                        }
                      }
                    }
                  }
                });
              },
              icon: const Icon(
                Icons.arrow_forward_ios_outlined,
              ),
              iconSize: 14,
              iconEnabledColor: Colors.yellow,
              iconDisabledColor: Colors.grey,
              buttonHeight: 50,
              buttonWidth: 160,
              buttonPadding: const EdgeInsets.only(left: 14, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black26,
                ),
                color: Colors.redAccent,
              ),
              buttonElevation: 2,
              itemHeight: 40,
              itemPadding: const EdgeInsets.only(left: 14, right: 14),
              dropdownMaxHeight: 200,
              dropdownWidth: 200,
              dropdownPadding: null,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.redAccent,
              ),
              dropdownElevation: 8,
              scrollbarRadius: const Radius.circular(40),
              scrollbarThickness: 6,
              scrollbarAlwaysShow: true,
              offset: const Offset(-20, 0),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 350,
          child: TextField(
            enabled: bCheck,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              NumericTextFormatter(),
            ], //
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.green[100],
              hintText: 'Số tiền chuyển đổi',
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
            ),
            style: const TextStyle(fontSize: 25.0, height: 2.0, color: Colors.black),
            controller: _controller,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _controller1.text = "0.0";
                }

                changeMoneyVal =
                    double.parse(value.replaceAll(",", "")) * selectedMoneyVal;
                var formatter = NumberFormat('#,###,000');
                _controller1.text = formatter.format(changeMoneyVal);
              });
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 350,
          child: TextFormField(
            //initialValue: displayMoneyVal,
            controller: _controller1,
            style: const TextStyle(fontSize: 25.0, height: 2.0, color: Colors.black),
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.green[100],
              hintText: '',
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
            ),
          ),
        )
      ],
    ));
  }
}
