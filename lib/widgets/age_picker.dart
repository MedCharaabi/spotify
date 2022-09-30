import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// import 'weight_picker.dart';

class AgePickerPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AgeScreen(),
    );
  }
}

class AgeScreen extends StatefulWidget {
  @override
  _AgeScreenState createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  double? _height;
  double? _width;
  var date;
  var cmheight = 26;
  var AGE = 26;
  void _submit2() {
    // Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(builder: ((_) => WPickerPage3())),
    //     (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Material(
      color: const Color(0xFF000000),
      child: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              createAccountText(),
              SizedBox(height: _height! / 8),
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Color(0xFF3C3C3E),
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        NumberPicker(
                            itemWidth: _width!,
                            selectedTextStyle: TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: 42,
                                fontWeight: FontWeight.normal),
                            textStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 21,
                                fontWeight: FontWeight.normal),
                            axis: Axis.vertical,
                            value: AGE,
                            minValue: 20,
                            maxValue: 80,
                            itemCount: 7,
                            onChanged: (newValue) =>
                                setState(() => AGE = newValue)),
                      ],
                    )),
              ),
              SizedBox(height: _height! / 8),
              button()
            ],
          ),
        ),
      ),
    );
  }

  Widget createAccountText() {
    return Container(
      margin: const EdgeInsets.only(top: 100.0),
      child: const Text(
        "HOW OLD ARE YOU?",
        style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 21),
      ),
    );
  }

  Widget button() {
    return MaterialButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45.0)),
      onPressed: _submit2,
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width: 320,
        height: 50,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(45.0)),
            color: Color(0xFF00F0FF)
            // gradient: LinearGradient(
            //   colors: <Color>[Color(0xFF00F0FF), Color(0xFF008190)],
            // ),
            ),
        padding: const EdgeInsets.all(12.0),
        child: const Text('Next',
            style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
    );
  }

  SizedBox get smallHeightSpacing => SizedBox(height: 10);
  SizedBox get smallWidthSpacing => SizedBox(width: 10);
}
