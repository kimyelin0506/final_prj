import 'package:bootpay/bootpay.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/model/browser_open_type.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:bootpay/model/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:final_prj/payment/webapp_payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

//고양이 후원하기 코드!! 결제 테스트 아직 하시면 안댐미다~!
void main() {
  runApp(MaterialApp(
    title: '안서동 고양이',
    home: FirstRoute(),
  ));
  // runApp(FirstRoute());
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('안서동 고양이 후원하기').tr(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'asset/image/animal_neko.png',
                width: 200.0, // 이미지의 폭
                height: 200.0, // 이미지의 높이
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20.0), // 버튼과 이미지 사이의 간격 조절
            ElevatedButton(
              onPressed: () {
                // 눌렀을 때 두 번째 route, 결제선택창으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondRoute()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  tr('후원하기'),
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class SecondRoute extends StatefulWidget {

  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {

  Payload payload = Payload();
  //
  String webApplicationId = '5b8f6a4d396fa665fdc2b5e7';  //현재는 공식키!!!!! 수정해야함!!!
  String androidApplicationId = '5b8f6a4d396fa665fdc2b5e8';
  String iosApplicationId = '5b8f6a4d396fa665fdc2b5e9';


  String get applicationId {
    return Bootpay().applicationId(
        webApplicationId,
        androidApplicationId,
        iosApplicationId
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bootpayAnalyticsUserTrace(); //통계용 함수 호출
    bootpayAnalyticsPageTrace(); //통계용 함수 호출
    bootpayReqeustDataInit(); //결제용 데이터 init
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return Container(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0), // 버튼과 버튼 사이의 간격 조절
                    child: ElevatedButton(
                      onPressed: () => goBootpayTest(context),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey, // 버튼 배경색
                        padding: EdgeInsets.all(20.0), // 패딩 값
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // 모서리를 덜 둥글게 조절
                        ),
                      ),
                      child: Text(
                        tr('일반결제'),
                        style: TextStyle(
                          fontSize: 24.0, // 글씨 크기 키우기
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // 글씨 색상
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // 버튼과 버튼 사이의 간격을 조금 더 넓힘
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0), // 버튼과 버튼 사이의 간격 조절
                    child: ElevatedButton(
                      onPressed: () => goBootpayWebapp(context),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey, // 버튼 배경색
                        padding: EdgeInsets.all(20.0), // 패딩 값
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // 모서리를 덜 둥글게 조절
                        ),
                      ),
                      child: Text(
                        tr('웹결제'),
                        style: TextStyle(
                          fontSize: 24.0, // 글씨 크기 키우기
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // 글씨 색상
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }



  void bootpayPasswordTest(BuildContext context, String userToken, User user) {
    payload.userToken = userToken;
    if(kIsWeb) {
      //flutter web은 cors 이슈를 설정으로 먼저 해결해주어야 한다.
      payload.extra?.openType = 'iframe';
    }

    Bootpay().requestPassword(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data)  {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onCancel: $data');
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirm: (String data) {
        return true;
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }



  User generateUser() {
    var user = User();
    user.id = '123411aaaaaaaaaaaabd4ss11';
    user.gender = 1;
    user.email = 'test1234@gmail.com';
    user.phone = '01012345678';
    user.birth = '19880610';
    user.username = '홍길동';
    user.area = '서울';
    return user;
  }


  //통계용 함수
  bootpayAnalyticsUserTrace() async {

    await Bootpay().userTrace(
        id: 'user_1234',
        email: 'user1234@gmail.com',
        gender: -1,
        birth: '19941014',
        area: '서울',
        applicationId: applicationId
    );
  }

  //통계용 함수
  bootpayAnalyticsPageTrace() async {

    StatItem item1 = StatItem();
    item1.itemName = "미키 마우스"; // 주문정보에 담길 상품명
    item1.unique = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격
    item1.cat1 = '컴퓨터';
    item1.cat2 = '주변기기';

    StatItem item2 = StatItem();
    item2.itemName = "키보드"; // 주문정보에 담길 상품명
    item2.unique = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    item2.price = 500; // 상품의 가격
    item2.cat1 = '컴퓨터';
    item2.cat2 = '주변기기';

    List<StatItem> items = [item1, item2];

    await Bootpay().pageTrace(
        url: 'main_1234',
        pageType: 'sub_page_1234',
        applicationId: applicationId,
        userId: 'user_1234',
        items: items
    );
  }

  //결제용 데이터 init
  bootpayReqeustDataInit() {
    Item item1 = Item();
    item1.name = "미키 '마우스"; // 주문정보에 담길 상품명
    item1.qty = 1; // 해당 상품의 주문 수량
    item1.id = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격

    Item item2 = Item();
    item2.name = "키보드"; // 주문정보에 담길 상품명
    item2.qty = 1; // 해당 상품의 주문 수량
    item2.id = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    item2.price = 500.50; // 상품의 가격
    List<Item> itemList = [item1, item2];

    payload.webApplicationId = webApplicationId; // web application id
    payload.androidApplicationId = androidApplicationId; // android application id
    payload.iosApplicationId = iosApplicationId; // ios application id


    // payload.pg = '다날';
    // payload.method = '카드';
    // payload.method = '네이버페이';
    // payload.methods = ['카드', '휴대폰', '가상계좌', '계좌이체', '카카오페이'];
    payload.orderName = "고양이 후원하기"; //결제할 상품명
    payload.price = 1000.50; //정기결제시 0 혹은 주석


    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함


    payload.metadata = {
      "callbackParam1" : "value12",
      "callbackParam2" : "value34",
      "callbackParam3" : "value56",
      "callbackParam4" : "value78",
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    payload.items = itemList; // 상품정보 배열


    User user = User(); // 구매자 정보
    user.id = "12341234";
    user.username = "사용자 이름";
    user.email = "user1234@gmail.com";
    user.area = "서울";
    user.phone = "010-0000-0000";
    user.addr = 'null';

    Extra extra = Extra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutter';


    if(BootpayConfig.ENV == -1) {
      payload.extra?.redirectUrl = 'https://dev-api.bootpay.co.kr/v2';
    } else if(BootpayConfig.ENV == -2) {
      payload.extra?.redirectUrl = 'https://stage-api.bootpay.co.kr/v2';
    }  else {
      payload.extra?.redirectUrl = 'https://api.bootpay.co.kr/v2';
    }

    payload.user = user;
    payload.items = itemList;
    payload.extra = extra;
  }


  //버튼클릭시 부트페이 결제요청 실행
  void goBootpayTest(BuildContext context) {
    if(kIsWeb) {
      payload.extra?.openType = 'iframe';
    }
    payload.extra?.browserOpenType = [
      BrowserOpenType.fromJson({"browser": "naver", "open_type": 'popup'}),
    ];


    payload.pg = '키움페이';
    payload.method = "카드";

    payload.extra?.displayCashReceipt = false;

    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel 1 : $data');
      },
      onError: (String data) {
        print('------- onError: $data');
      },
      onClose: () {
        print('------- onClose');
        Future.delayed(Duration(seconds: 0)).then((value) {

          if (mounted) {
            print('Bootpay().dismiss');
            Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
          }
        });

        // Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirm: (String data)  {

        print('------- onConfirm: $data');

        Bootpay().dismiss(context);

        return false;
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  void goBootpayWebapp(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => WebAppPayment()));

  }




  Future<void> checkQtyFromServer(String data) async {
    //TODO 서버로부터 재고파악을 한다
    print('checkQtyFromServer start: $data');
    return Future.delayed(Duration(seconds: 1), () {
      print('checkQtyFromServer end: $data');

      Bootpay().transactionConfirm();
      return true;
    });
  }
}