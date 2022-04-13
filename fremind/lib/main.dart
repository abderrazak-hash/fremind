import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_picker/image_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_cmoon_icons/flutter_cmoon_icons.dart';
import 'package:fremind/konstants.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'ElMessiri',
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: FRemind(),
        ),
      ),
    ),
  );
}

class FRemind extends StatefulWidget {
  const FRemind({Key? key}) : super(key: key);

  @override
  _FRemindState createState() => _FRemindState();
}

class _FRemindState extends State<FRemind> with SingleTickerProviderStateMixin {
  FocusNode fxNd = FocusNode();
  TextEditingController ctrl = TextEditingController();
  ScreenshotController screenCtrl = ScreenshotController();
  late AnimationController ctrlPen;
  late int kBgNdx, kTxtNdx;
  late bool isImage, kLang, kIntro;
  late String wpPath;
  late File image;
  late DateTime dttm;
  late SharedPreferences prefs;
  late double deviceWidth, deviceHeight;
  Widget myScreen(double noteSize) => Container(
        width: noteSize == 55 ? double.infinity : deviceWidth * 0.7 - 8,
        height: noteSize == 55 ? double.infinity : deviceHeight * 0.7 - 70,
        decoration: isImage
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: kBgClrs[kBgNdx],
                ),
              ),
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                ctrl.clear();
                fxNd = FocusNode();
                fxNd.requestFocus();
              });
            },
            child: Text(
              note,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kTxtClrs[kTxtNdx],
                fontFamily: 'ElMessiri',
                fontSize: noteSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  Column iconWidget(
          {required String appName,
          required IconData appIcon,
          required Color appClr}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            appIcon,
            size: 30.0,
            color: appClr,
          ),
          Text(
            appName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            ),
          ),
        ],
      );

  Row tip(String english, arabic, IconData icona) => Row(
        textDirection: kLang ? TextDirection.ltr : TextDirection.rtl,
        children: [
          Icon(
            icona,
            size: 32.0,
            color: Color(0xFF0f2027),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            kLang ? english : arabic,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0f2027),
            ),
          ),
        ],
      );

  void imgFromGallery() async {
    XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedImage!.path);
      wpPath = pickedImage.path;
      isImage = true;
    });
    prefs.setString('imagePath', wpPath);
    prefs.setBool('isImage', isImage);
  }

  GestureDetector bgClrBtn(int bgNdx) => GestureDetector(
        onTap: () async {
          setState(() {
            kBgNdx = bgNdx;
            isImage = false;
          });
          prefs.setInt('bgNdx', bgNdx);
          prefs.setBool('isImage', false);
        },
        child: Container(
          height: 35.0,
          width: 35.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: kBgClrs[bgNdx],
            ),
          ),
          child: bgNdx == kBgNdx
              ? Icon(
                  IconMoon.icon_checkmark2,
                  color: Colors.black,
                )
              : null,
        ),
      );

  GestureDetector noteClrBtn(int txtNdx) => GestureDetector(
        onTap: () async {
          setState(() {
            kTxtNdx = txtNdx;
          });
          prefs.setInt('txtNdx', txtNdx);
        },
        child: Container(
          height: 35.0,
          width: 35.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kTxtClrs[txtNdx],
            border: Border.all(
              width: txtNdx == 1 ? 2.0 : 0.0,
              color: txtNdx == 1 ? Colors.blueGrey : Colors.white,
            ),
          ),
          child: txtNdx == kTxtNdx
              ? Icon(
                  IconMoon.icon_checkmark2,
                  color: txtNdx == 0 ? Colors.white : Colors.black,
                )
              : null,
        ),
      );

  void getData() async {
    prefs = await SharedPreferences.getInstance();
    isImage = prefs.getBool('isImage') ?? false;
    kIntro = prefs.getBool('kIntro') ?? true;
    kLang = prefs.getBool('kLang') ?? true;
    kBgNdx = prefs.getInt('bgNdx') ?? 0;
    kTxtNdx = prefs.getInt('txtNdx') ?? 0;
    // Dealing with case of image is removed or replaced
    wpPath = prefs.getString('imagePath') ?? '';
    try {
      image = File(wpPath);
    } catch (e) {
      isImage = false;
    }
  }

  void captureIt() {
    setState(() {
      showToast = true;
      if (note.trim() == '' || note.isEmpty) {
        ctrlPen.value = 1;
        isCenter = true;
      }
      screenCtrl
          .captureFromWidget(
        myScreen(55.0),
      )
          .then((capturedImage) async {
        final directory = await getExternalStorageDirectory();
        String p = join(directory!.path, 'image.jpg');
        File theFile = await File(p).create();
        await theFile.writeAsBytes(capturedImage);
        String res = "";
        while (res != "Wallpaper set") {
          try {
            res = await WallpaperManager.setWallpaperFromFile(theFile.path, 1);
          } catch (e) {}
        }
      });
      Future.delayed(Duration(seconds: 1)).then((value) {
        setState(() {
          showToast = false;
        });
      });
    });
  }

  void getTime() async {
    dttm = DateTime.now();
    await Future.delayed(Duration(seconds: 59 - dttm.second)).then((value) {
      setState(() {
        dttm = DateTime.now();
      });
    });
    getTime();
  }

  @override
  void initState() {
    super.initState();
    getData();
    Future.delayed(Duration(milliseconds: 1)).then((value) {
      setState(() {
        dttm = DateTime.now();
      });
    });
    getTime();
    ctrlPen = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
    );
    setState(() {
      ctrlPen.value = 1;
    });
  }

  @override
  Container build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: isImage
          ? BoxDecoration(
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: kBgClrs[kBgNdx],
              ),
            ),
      child: Container(
        color: Colors.white70,
        child: kIntro
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                    width: double.infinity,
                    height: 390.0,
                    margin: EdgeInsets.symmetric(
                      horizontal: deviceWidth * 0.1,
                    ),
                    padding: EdgeInsets.only(
                      top: kLang ? 22.0 : 32.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          kLang ? 'Your Guide' : 'دليـلك',
                          style: TextStyle(
                            fontSize: kLang ? 27.0 : 30.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0f2027),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 20.0,
                            ),
                            child: firstSlide
                                ? ListView(
                                    children: [
                                      Container(
                                        child: Center(
                                          child: Text(
                                            kLang
                                                ? 'fRemindApp makes your habit Alarms.\nAs soon as you unlock your phone, you find the wallpaper reminding you of the thing you wanted to remember.\n\nDeveloped by:\nAbdErrazak KENNICHE'
                                                : 'تطبيق فذكّـر يجعل من عاداتك منبها\nفبمجرد فتح الهاتف ستجد الخلفية تذكرك بالشيء الذي أردت تذكره\n\nالمطور: عبد الرزاق قنيش',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF0f2027),
                                              letterSpacing: kLang ? 0.5 : 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView(
                                    children: [
                                      tip(
                                        'Start typing your note.',
                                        '.بدأ تدوين ملاحظتك',
                                        IconMoon.icon_pencil,
                                      ),
                                      Divider(
                                        thickness: 2.0,
                                      ),
                                      tip(
                                        'Change wallpaper & text\ncolor.',
                                        '.تغيير الخلفية ولون الخط',
                                        Icons.settings_suggest_outlined,
                                      ),
                                      Divider(
                                        thickness: 2.0,
                                      ),
                                      tip(
                                        'Reset default wallpaper.',
                                        '.استعادة خلفية الهاتف اﻷصلية',
                                        IconMoon.icon_refresh1,
                                      ),
                                      Divider(
                                        thickness: 2.0,
                                      ),
                                      tip(
                                        'Read about fRemind.',
                                        '.قراءة المزيد حول فذكّــر',
                                        IconMoon.icon_information_outline,
                                      ),
                                      Divider(
                                        thickness: 2.0,
                                      ),
                                      tip(
                                        'Share it with friends.',
                                        '.مشاركة فذكّـر مع اﻷصدقاء',
                                        IconMoon.icon_share1,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        Container(
                          height: 50.0,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: kLang
                                        ? Color(0xFF0f2027)
                                        : Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      kLang = true;
                                    });
                                  },
                                  child: Center(
                                    child: Text(
                                      'English',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: kLang
                                            ? Colors.white
                                            : Color(0xFF0f2027),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: kLang
                                        ? Colors.white
                                        : Color(0xFF0f2027),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      kLang = false;
                                    });
                                  },
                                  child: Center(
                                    child: Text(
                                      'العربية',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: kLang
                                            ? Color(0xFF0f2027)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0f2027),
                    ),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: firstSlide
                          ? () {
                              setState(() {
                                firstSlide = false;
                              });
                            }
                          : () async {
                              setState(() {
                                kIntro = false;
                              });
                              prefs.setBool('kIntro', false);
                              prefs.setBool('kLang', kLang);
                            },
                      icon: Icon(
                        firstSlide
                            ? Icons.arrow_forward_ios
                            : IconMoon.icon_checkmark2,
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  // Cover
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: deviceWidth * 0.3 / 4,
                      vertical: 40.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 2.0,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  // AppName
                  Positioned(
                    top: 20.0,
                    left: MediaQuery.of(context).size.width / 2 - 75,
                    child: Container(
                      width: 150.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.white,
                        border: Border.all(
                          width: 2.0,
                          color: Colors.black,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          kLang ? 'fRemind' : 'فذكّــر',
                          style: TextStyle(
                            fontSize: kLang ? 22.0 : 30.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // 2nd App Name
                  Positioned(
                    bottom: 15.0,
                    left: MediaQuery.of(context).size.width / 2 - 25,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.white,
                        border: Border.all(
                          width: 2.0,
                          color: Colors.black,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          IconMoon.icon_checkmark2,
                        ),
                        onPressed: captureIt,
                      ),
                    ),
                  ),
                  // Phone
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: deviceHeight * 0.7 - 30,
                          width: deviceWidth * 0.7,
                          padding: EdgeInsets.only(
                            left: 4.0,
                            right: 4.0,
                            top: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Stack(
                            children: [
                              // BG & 3 Buttons
                              Column(
                                children: [
                                  Container(
                                    height: 0.0,
                                    child: TextField(
                                        controller: ctrl,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        focusNode: fxNd,
                                        onChanged: (value) {
                                          setState(() {
                                            note = value;
                                          });
                                        },
                                        onSubmitted: (value) {
                                          captureIt();
                                        }),
                                  ),
                                  // Background
                                  myScreen(30.0),
                                  // 3 Buttons
                                  Container(
                                    height: 30.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            setState(() {
                                              showSettings = !closed;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.crop_square,
                                            size: 14.0,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            setState(() {
                                              showSettings = false;
                                              showAbout = false;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.circle_outlined,
                                            color: Colors.blueGrey,
                                            size: 14.0,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            setState(() {
                                              showSettings = false;
                                              showAbout = false;
                                            });
                                          },
                                          icon: Transform.rotate(
                                            angle: 3.14,
                                            child: Icon(
                                              Icons.play_arrow_outlined,
                                              color: Colors.blueGrey,
                                              size: 20.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Info Bar
                              Positioned(
                                top: 0,
                                left: 0.0,
                                child: Container(
                                  color: Colors.white24,
                                  height: 8.0,
                                  width: deviceWidth * 0.8 - 8,
                                ),
                              ),
                              // Small Time
                              Positioned(
                                top: -2,
                                right: 3,
                                child: Text(
                                  dttm.toString().substring(11, 16),
                                  style: TextStyle(
                                    fontSize: 9.0,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                              // The notch
                              Positioned(
                                top: -12.0,
                                right: deviceWidth * 0.2,
                                child: Container(
                                  height: 20.0,
                                  width: deviceWidth * 0.3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(12.0),
                                    ),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Time && Settings
                              Positioned(
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 50.0,
                                                fontFamily: 'Roboto',
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: dttm
                                                      .toString()
                                                      .substring(11, 13),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: dttm
                                                      .toString()
                                                      .substring(13, 16),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w100,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            dttm.toString().substring(0, 10),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          Text(
                                            kLang
                                                ? days[dttm.weekday - 1]
                                                : ayam[dttm.weekday - 1],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                showAbout = false;
                                                showSettings = true;
                                                closed = false;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.settings_suggest_outlined,
                                              size: 42.0,
                                            ),
                                          ),
                                          Text(
                                            kLang ? 'Settings' : 'اﻹعدادات',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // The Pen
                              Positioned(
                                right: (deviceWidth * 0.7 / 2 - 40.0) *
                                        ctrlPen.value.toDouble() +
                                    5.0,
                                top: (deviceHeight * 0.7 - 30) / 2 -
                                    50 +
                                    20 * ctrlPen.value.toDouble(),
                                child: Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          ctrl.clear();
                                          fxNd = FocusNode();
                                          fxNd.requestFocus();
                                          isCenter = false;
                                          ctrlPen.reverse();
                                        });
                                        ctrlPen.addListener(() {
                                          setState(() {});
                                        });
                                      },
                                      icon: Icon(
                                        IconMoon.icon_pencil,
                                        size: 35.0,
                                      ),
                                    ),
                                    Text(isCenter && kLang
                                        ? 'Tap here'
                                        : isCenter
                                            ? 'اضغط هنا'
                                            : ''),
                                  ],
                                ),
                              ),
                              // Apps
                              Positioned(
                                bottom: 33.0,
                                child: Container(
                                  width: deviceWidth * 0.7 - 8,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      iconWidget(
                                        appIcon: IconMoon.icon_phone,
                                        appClr: Colors.greenAccent,
                                        appName: kLang ? 'Phone' : 'الهاتف',
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showToast = true;
                                          });
                                          Future.delayed(Duration(seconds: 1))
                                              .then((value) {
                                            setState(() {
                                              showToast = false;
                                            });
                                          });
                                          WallpaperManager.setWallpaperFromFile(
                                              'default', 1);
                                        },
                                        child: iconWidget(
                                          appIcon: IconMoon.icon_refresh1,
                                          appClr: Colors.black,
                                          appName:
                                              kLang ? 'ResetWP' : 'استعادة',
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showAbout = true;
                                            showSettings = false;
                                            closed = true;
                                          });
                                        },
                                        child: iconWidget(
                                          appIcon:
                                              IconMoon.icon_information_outline,
                                          appClr: Colors.blueGrey,
                                          appName: kLang ? 'About' : 'حول',
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Share.share(
                                            kLang
                                                ? 'fRemindApp\n\n   The idea and simplicity of fRemindApp helps remembering personal stuffs thanks to the habit of checking phone each moment.\n\nDeveloper: AbdErrazak KENNICHE.'
                                                : 'تطبيق فذكّــر\nفكرة وبساطة تطبيق فذكّــر تساعدك على تذكر أي أمر بفضل عادة الفتح المتكرر للهاتف.\nالمطور: عبد الرزاق قنيش.',
                                            subject: kLang
                                                ? 'fRemindApp'
                                                : 'تطبيق فذكّــر',
                                          );
                                        },
                                        child: iconWidget(
                                          appIcon: IconMoon.icon_share1,
                                          appClr: Colors.blue,
                                          appName: kLang ? 'SHAREit' : 'مشاركة',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // About Part
                              if (showAbout)
                                Center(
                                  child: Container(
                                    height: 200.0,
                                    width: deviceWidth * 0.65,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: 30.0),
                                              Text(
                                                kLang ? 'fRemind' : 'فذكّــر',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    showAbout = false;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 26.0,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                                fontFamily: 'ElMessiri',
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: kLang
                                                      ? 'fRemindApp makes your habit Alarms.\nUnlcok phone will help you remember your stuffs.\n'
                                                      : 'تطبيق فذكّـر يجعل من عاداتك منبها، فبمجرد فتح الهاتف ستجد الخلفية تذكرك بالشيء الذي أردت تذكره\n',
                                                ),
                                                TextSpan(
                                                  text: kLang
                                                      ? 'Developed by:\nAbdErrazak KENNICHE'
                                                      : '\nالمطور: عبد الرزاق قنيش',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Real Settings
                              if (showSettings)
                                Center(
                                  child: Container(
                                    height: 170.0,
                                    width: deviceWidth * 0.62,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: 30.0),
                                              Text(
                                                isWalp && kLang
                                                    ? 'Wallpaper'
                                                    : isWalp
                                                        ? 'الخلفية'
                                                        : kLang
                                                            ? 'Text'
                                                            : 'الخـطّ',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    showSettings = false;
                                                    closed = true;
                                                  });
                                                },
                                                child: Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 26.0,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        isWalp
                                            ? Container(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        bgClrBtn(0),
                                                        bgClrBtn(1),
                                                        bgClrBtn(2),
                                                        bgClrBtn(3),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        bgClrBtn(4),
                                                        bgClrBtn(5),
                                                        bgClrBtn(6),
                                                        GestureDetector(
                                                          onTap: () {
                                                            imgFromGallery();
                                                          },
                                                          child: Container(
                                                            width: 35.0,
                                                            child: Icon(
                                                              IconMoon
                                                                  .icon_image,
                                                              size: 30,
                                                              color: Colors
                                                                  .blueGrey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        noteClrBtn(0),
                                                        noteClrBtn(1),
                                                        noteClrBtn(2),
                                                        noteClrBtn(3),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        noteClrBtn(4),
                                                        noteClrBtn(5),
                                                        noteClrBtn(6),
                                                        noteClrBtn(7),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        Container(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isWalp = !isWalp;
                                              });
                                            },
                                            child: Icon(
                                              isWalp
                                                  ? Icons.arrow_forward_ios
                                                  : Icons.arrow_back_ios,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Toast
                              if (showToast)
                                Positioned(
                                  width: deviceWidth * 0.7 - 4,
                                  bottom: 110,
                                  left: 0,
                                  child: Text(
                                    kLang ? 'Check Wallpaper!' : 'تفقد الخلفية',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kTxtClrs[kTxtNdx],
                                    ),
                                  ),
                                ),
                              // The Four Dots
                              Positioned(
                                bottom: 90.0,
                                left: deviceWidth * 0.7 / 2 - 20,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 6.0,
                                        width: 6.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            width: 0.5,
                                            color: Colors.white,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Container(
                                        height: 6.0,
                                        width: 6.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.5,
                                            color: Colors.white,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Container(
                                        height: 6.0,
                                        width: 6.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.5,
                                            color: Colors.white,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Container(
                                        height: 6.0,
                                        width: 6.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.5,
                                            color: Colors.white,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // The Camera
                        Positioned(
                          top: 7,
                          left: deviceWidth * 0.7 / 2 - 8,
                          child: Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // The Flash
                        Positioned(
                          top: 8,
                          left: deviceWidth * 0.7 / 2 + 1,
                          child: Container(
                            height: 4,
                            width: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
