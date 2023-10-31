import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/screens/menuScreen.dart';

import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/webview.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class deposit_Money extends StatefulWidget {
  const deposit_Money({Key? key}) : super(key: key);

  @override
  State<deposit_Money> createState() => _deposit_MoneyState();
}

class _deposit_MoneyState extends State<deposit_Money> {
  TextEditingController amount=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return
    Scaffold(
      appBar: QAppBar(
          title: Text(
              "Coin Store"
              // AppLocalization.of(context)!.getTranslatedValues("Add Money")!),
          )),
      // AppBar(
      //     backgroundColor: Colors.transparent,
      //     flexibleSpace: Container(
      //         decoration: BoxDecoration(
      //             borderRadius: BorderRadius.only(
      //                 bottomLeft: Radius.circular(20),
      //                 bottomRight: Radius.circular(20)),
      //             // gradient: LinearGradient(
      //             //     colors: [lightblue,bgcolor],
      //             //     begin: Alignment.bottomCenter,
      //             //     end: Alignment.topCenter
      //             // )
      //             color: Colors.white
      //         )
      //     ),
      //     automaticallyImplyLeading: false,
      //     leading: CustomBackButton(),
      //     centerTitle: true,
      //     title: Text(   "Deposit Money",
      //       style: TextStyle(
      //         fontWeight: FontWeight.w600,
      //         fontSize: 20,
      //         color: primaryColor,
      //       ), )
      // ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: height/15,vertical:height*0.07),
                child: TextFormField(
                  controller: amount,
                  validator:  (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Amount must be a valid number less than 50.';
                    }

                    return null;
                  },
                  keyboardType: TextInputType.number,
                  // style: RighteousMedium.copyWith(fontSize: heights * 0.019, color: Colors.white),
                  decoration: InputDecoration(

                      contentPadding: EdgeInsets.symmetric(vertical: height*0.01,horizontal: width*0.04), // Adjust padding as needed
                      counter: Offstage(),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: Color(0xFFF65054)),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: Color(0xFFF65054)),
                      ),
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: width/40,),
                          Text("₹",style:TextStyle(color: Colors.black,fontSize: 30) ),
                          SizedBox(width: width/60,),


                        ],
                      ),
                      hintText: "Enter Ammount",
                      hintStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
                    fillColor:  Colors.white.withOpacity(0.9),
                    filled: true

                  ),
                  // keyboardType: TextInputType.number,
                  // maxLength: 10,

                ),
                // Row(
                //   children: [
                //     Container(width: width*0.1,height: height*0.07,alignment: Alignment.center,
                //         decoration: BoxDecoration(border:Border.all(color: Colors.grey),
                //             borderRadius: BorderRadius.only(
                //                 topLeft: Radius.circular(5),
                //                 bottomLeft: Radius.circular(5)
                //             ),color: Colors.grey.shade300),
                //         child: Text("₹",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),)
                //     ),
                //     Container(
                //       width: width*0.6,height: height*0.07,
                //       decoration: BoxDecoration(border:Border.all(color: Colors.grey),
                //         borderRadius: BorderRadius.only(
                //             topRight: Radius.circular(5),
                //             bottomRight: Radius.circular(5)
                //         ),),
                //       child:
                //       TextFormField(
                //         controller: amount,
                //         validator:  (value) {
                //           if (value == null || value.isEmpty) {
                //             return 'Please enter an amount.';
                //           }
                //           if (double.tryParse(value) == null || double.parse(value) <= 49) {
                //             return 'Amount must be a valid number less than 50.';
                //           }
                //
                //           return null;
                //           },
                //         // style: RighteousMedium.copyWith(fontSize: heights * 0.019, color: Colors.white),
                //         decoration: InputDecoration(
                //
                //             contentPadding: EdgeInsets.symmetric(vertical: height*0.01,horizontal: width*0.04), // Adjust padding as needed
                //             counter: Offstage(),
                //             // enabledBorder: const OutlineInputBorder(
                //             //   borderRadius: BorderRadius.all(Radius.circular(12.0)),
                //             //   borderSide: BorderSide(color: Colors.white, width: 2),
                //             // ),
                //             focusedBorder: const OutlineInputBorder(
                //               borderRadius: BorderRadius.all(Radius.circular(12.0)),
                //               borderSide: BorderSide(color: Colors.white, width: 2),
                //             ),
                //             border: const OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.white),
                //               borderRadius: BorderRadius.all(
                //                 Radius.circular(12.0),
                //               ),
                //             ),
                //             focusedErrorBorder: const OutlineInputBorder(
                //               borderRadius: BorderRadius.all(Radius.circular(12.0)),
                //               borderSide: BorderSide(color: Color(0xFFF65054)),
                //             ),
                //             errorBorder: const OutlineInputBorder(
                //               borderRadius: BorderRadius.all(Radius.circular(12.0)),
                //               borderSide: BorderSide(color: Color(0xFFF65054)),
                //             ),
                //             // prefixIcon: Row(
                //             //   mainAxisSize: MainAxisSize.min,
                //             //   children: [
                //             //     SizedBox(width: width/60,),
                //             //     Text("₹",style:TextStyle ),
                //             //     SizedBox(width: width/60,),
                //             //     // Icon(Icons.phone,color: Colors.white),
                //             //     // Image.asset(AppAsset.imagesTextfiled),
                //             //   ],
                //             //
                //             // ),
                //
                //             hintText: "Enter Ammount",
                //             hintStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w400)
                //             // fillColor:  Color(0xff010a40).withOpacity(0.9),
                //             // filled: true
                //
                //         ),
                //         // keyboardType: TextInputType.number,
                //         // maxLength: 10,
                //
                //       ),
                //
                //     ),
                //   ],
                // ),

            ),

            CustomRoundedButton(
              widthPercentage: 0.4,
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle:
              "Add Coins",
              radius: 15.0,
              showBorder: false,
              titleColor: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold,
              textSize: 17.0,
              onTap: () async{
                if (_formKey.currentState!.validate()) {

                  final am=amount.text;
                  final prefs = await SharedPreferences.getInstance();
                  final userid=usuid;
                  print("hhhhhhhhhhhhhhhhhhhhh");
                  print(userid);
                  Navigator.push(context, MaterialPageRoute(builder:
                      (context)=>WebViewExample(url:'https://bappatest.wishufashion.com/bappa_phonepay/amount.php?auth=NTM1NDU0MzUyNDUyNDM1NjQyMzY1Mg==&amount=$am&userid=$userid')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
               // webpay(amount.text);


              },
              height: 50.0,
            ),

            // ElevatedButton(
            //     onPressed: (){}, child: Text("Deposit"))

          ],
        ),
      ),
    );
  }
  // webpay(String amount)async{
  //   print("fun invoked");
  //   final prefs = await SharedPreferences.getInstance();
  //   final userid=prefs.getString("userId");
  //   final res = await http.get(Uri.parse('https://bappatest.wishufashion.com/bappa_phonepay/amount.php?auth=NTM1NDU0MzUyNDUyNDM1NjQyMzY1Mg==&amount=$amount&userid=$userid'));
  //   var data = jsonDecode(res.body);
  //   if (data["error"] == '200') {
  //     print(data);
  //     Navigator.push(context, MaterialPageRoute(builder:
  //         (context)=>WebViewExample(url:'https://bappatest.wishufashion.com/bappa_phonepay/amount.php?auth=NTM1NDU0MzUyNDUyNDM1NjQyMzY1Mg==&amount=$am&userid=$userid')));
  //     // final am=amount.text;
  //   }else{
  //     throw Exception();
  //
  //   }
  // }
}
