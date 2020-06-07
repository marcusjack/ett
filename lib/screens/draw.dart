import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:ett_app/domains/Usuario.dart';
import 'package:ett_app/domains/solicitacao.dart';
import 'package:ett_app/screens/appBar.dart';
import 'package:ett_app/style/lightColors.dart';
import 'package:ett_app/screens/login.dart';
import 'package:ett_app/screens/relatorioOcorrenciaTransito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class Draw extends StatefulWidget {
  Solicitacao sol;
  Usuario user;
  Token token;

  Draw({Key key, this.sol, this.user, this.token})
      : super(key: key);

  @override
  _DrawState createState() => _DrawState(sol: sol, user: user, token: token);
}



class _DrawState extends State<Draw> {
  Solicitacao sol;
  Usuario user;
  Token token;

  _DrawState({this.sol, this.user, this.token});

  //legenda
  double busTop = 0;
  double left = 0;
  double carTop = 15;
  double carLeft = 50;
  double bikeTop = 17;
  double bikeLeft = 90;
  double personTop = 15;
  double personLeft = 130;
  double truckTop = 13;
  double truckLeft = 170;
  double pickUpTop = 12;
  double pickUpLeft = 215;

  //Capture image png
  GlobalKey _captureImageKey = new GlobalKey();

  bool inside = false;
  Uint8List imageInMemory;

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
      _captureImageKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
//      String bs64 = base64Encode(pngBytes);
//      print(pngBytes);
//      print(bs64);
      print('png done');
      setState(() {
        imageInMemory = pngBytes;
        inside = false;
      });
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }


  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black,
    Colors.grey
  ];


  //Opcao do cursor virar pincel ou arrastar
  // Toggles the password show status
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      tapped = !tapped;
    });
  }
  bool tapped = false;

  _opcaoCursor(){
    if (tapped == false) {
      print(tapped);
     // painter:
      return null;
  } else{
      return CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
          pointsList: points,
      ));
    }}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LightColors.kDarkYellow,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            //captura a imagem quando volta para a tela anterior
            _capturePng();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RelatorioOcorrenciaTransito(user: user, token: token, sol: sol,)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.arrow_back_ios,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: LightColors.kLightYellow2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.album),
                                onPressed: () {
                                setState(() {
                                _toggle();
                                tapped = true;
                                print(tapped);
                                if (selectedMode == SelectedMode.StrokeWidth)
                                  showBottomList = !showBottomList;
                                selectedMode = SelectedMode.StrokeWidth;
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.opacity),
                            onPressed: () {
                              setState(() {
                                _toggle();
                                tapped = true;
                                print(tapped);
                                if (selectedMode == SelectedMode.Opacity)
                                  showBottomList = !showBottomList;
                                selectedMode = SelectedMode.Opacity;
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.color_lens),
                            onPressed: () {
                              setState(() {
                                _toggle();
                                tapped = true;
                                print(tapped);
                                if (selectedMode == SelectedMode.Color)
                                  showBottomList = !showBottomList;
                                selectedMode = SelectedMode.Color;

                              });
                            }),
                        //Acessar ícones da legenda
                        new IconButton(
                          icon: Icon(Icons.directions_bike),
                          //child: Text('SALVAR IMAGEM'),
                          onPressed: (){
                            //_capturePng();
                            points;
                            _toggle();
                            tapped = false;
                            print(tapped);
                          }
                        ),

                        IconButton(
                            icon: Icon(Icons.replay),
                            onPressed: () {
                              setState(() {
                                _toggle();
                                tapped = true;
                                print(tapped);
                                showBottomList = false;
                                points.clear();
                              });
                            }),
                      ],
                    ),
                    Visibility(
                      child: (selectedMode == SelectedMode.Color)
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getColorList(),
                      )
                          : Slider(
                          value: (selectedMode == SelectedMode.StrokeWidth)
                              ? strokeWidth
                              : opacity,
                          max: (selectedMode == SelectedMode.StrokeWidth)
                              ? 50.0
                              : 1.0,
                          min: 0.0,
                          onChanged: (val) {
                            setState(() {
                              if (selectedMode == SelectedMode.StrokeWidth)
                                strokeWidth = val;
                              else
                                opacity = val;
                            });
                          }),
                      visible: showBottomList,
                    ),
                  ],
                ),
              )),

      ),
      body:
      RepaintBoundary(
        key: _captureImageKey,
            child: Stack(
              children: <Widget>[
                //show legendas
                Column(
                  children: <Widget>[
                    Flexible(
                      //ícones da legenda
                      child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.all(30),
                        height: 500,
                        width: 300,
                        color: LightColors.kLightYellow,
                        child: Stack(
                            children: <Widget>[

                              Draggable(
                                      child: Container(
                                        padding: EdgeInsets.only(top: busTop, left: left),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.directions_bus,
                                            size: 47,
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              //_toggle();
                                              tapped = true;
                                            });
                                            print(tapped);
                                          },
                                        ),
                                      ),
                                      feedback: Container(
                                        padding: EdgeInsets.only(top: busTop, left: left),
                                        child: FlatButton(
                                          child: Icon(
                                            Icons.directions_bus,
                                            //IconData(57744, fontFamily: 'MaterialIcons'),
                                            size: 47,
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              //_toggle();
                                              tapped = true;
                                            });
                                            print(tapped);
                                          },
                                        ),

                                      ),
                                      childWhenDragging: Container(
                                        padding: EdgeInsets.only(top: busTop, left: left),
                                        child:  IconButton(
                                          icon: Icon(
                                            Icons.directions_bus,
                                            //IconData(57744, fontFamily: 'MaterialIcons'),
                                            size: 47,
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              //_toggle();
                                              tapped = true;
                                            });
                                            print(tapped);
                                          },
                                        ),

                                      ),
                                      onDragCompleted: () {},
                                      onDragEnd: (drag) {
                                        setState(() {
                                          if((busTop + drag.offset.dy) > (300.0 - 30.0)){
                                            busTop = (300.0 - 30.0);
                                          }else if((busTop + drag.offset.dy-30.0) < 0.0){
                                            busTop = 0;
                                          }else{
                                            busTop =  busTop + drag.offset.dy-30.0;
                                          }if((left + drag.offset.dx) > (300.0 - 30.0)){
                                            left = (300.0 - 30.0);
                                          }else if((left + drag.offset.dx-30.0) < 0.0){
                                            left = 0;
                                          }else{
                                            left =  left + drag.offset.dx-30.0;
                                          }});
                                      },
                                    ),


                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _toggle();
                                    tapped = true;
                                  });
                                  print(tapped);
                                },
                                  child: Draggable(
                                    child: Container(
                                      padding: EdgeInsets.only(top: carTop, left: carLeft),
                                      child: DragCar(),
                                    ),
                                    feedback: Container(
                                      padding: EdgeInsets.only(top: carTop, left: carLeft),
                                      child: DragCar(),

                                    ),
                                    childWhenDragging: Container(
                                      padding: EdgeInsets.only(top: carTop, left: carLeft),
                                      child:  DragCar(),

                                    ),
                                    onDragCompleted: () {},
                                    onDragEnd: (drag) {
                                      setState(() {
                                        if((carTop + drag.offset.dy) > (300.0 - 30.0)){
                                          carTop = (300.0 - 30.0);
                                        }else if((carTop + drag.offset.dy-30.0) < 0.0){
                                          carTop = 0;
                                        }else{
                                          carTop =  carTop + drag.offset.dy-30.0;
                                        }if((left + drag.offset.dx) > (300.0 - 30.0)){
                                          carLeft = (300.0 - 30.0);
                                        }else if((carLeft + drag.offset.dx-30.0) < 0.0){
                                          carLeft = 0;
                                        }else{
                                          carLeft =  carLeft + drag.offset.dx-30.0;
                                        }});
                                    },
                                  ),

                              ),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _toggle();
                                    tapped = true;
                                  });
                                  print(tapped);
                                },
                                child: Draggable(
                                  child: Container(
                                    padding: EdgeInsets.only(top: bikeTop, left: bikeLeft),
                                    child: DragBike(),
                                  ),
                                  feedback: Container(
                                    padding: EdgeInsets.only(top: bikeTop, left: bikeLeft),
                                    child: DragBike(),

                                  ),
                                  childWhenDragging: Container(
                                    padding: EdgeInsets.only(top: bikeTop, left: bikeLeft),
                                    child:  DragBike(),

                                  ),
                                  onDragCompleted: () {},
                                  onDragEnd: (drag) {
                                    setState(() {
                                      if((bikeTop + drag.offset.dy) > (300.0 - 30.0)){
                                        bikeTop = (300.0 - 30.0);
                                      }else if((bikeTop + drag.offset.dy-30.0) < 0.0){
                                        bikeTop = 0;
                                      }else{
                                        bikeTop =  bikeTop + drag.offset.dy-30.0;
                                      }if((left + drag.offset.dx) > (300.0 - 30.0)){
                                        bikeLeft = (300.0 - 30.0);
                                      }else if((bikeLeft + drag.offset.dx-30.0) < 0.0){
                                        bikeLeft = 0;
                                      }else{
                                        bikeLeft =  bikeLeft + drag.offset.dx-30.0;
                                      }});
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _toggle();
                                    tapped = true;
                                  });
                                  print(tapped);
                                },
                                child: Draggable(
                                  child: Container(
                                    padding: EdgeInsets.only(top: personTop, left: personLeft),
                                    child: DragPerson(),
                                  ),
                                  feedback: Container(
                                    padding: EdgeInsets.only(top: personTop, left: personLeft),
                                    child: DragPerson(),

                                  ),
                                  childWhenDragging: Container(
                                    padding: EdgeInsets.only(top: personTop, left: personLeft),
                                    child:  DragPerson(),

                                  ),
                                  onDragCompleted: () {},
                                  onDragEnd: (drag) {
                                    setState(() {
                                      if((personTop + drag.offset.dy) > (300.0 - 30.0)){
                                        personTop = (300.0 - 30.0);
                                      }else if((personTop + drag.offset.dy-30.0) < 0.0){
                                        personTop = 0;
                                      }else{
                                        personTop =  personTop + drag.offset.dy-30.0;
                                      }if((left + drag.offset.dx) > (300.0 - 30.0)){
                                        personLeft = (300.0 - 30.0);
                                      }else if((personLeft + drag.offset.dx-30.0) < 0.0){
                                        personLeft = 0;
                                      }else{
                                        personLeft =  personLeft + drag.offset.dx-30.0;
                                      }});
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _toggle();
                                    tapped = true;
                                  });
                                  print(tapped);
                                },
                                child: Draggable(
                                  child: Container(
                                    padding: EdgeInsets.only(top: truckTop, left: truckLeft),
                                    child: DragTruck(),
                                  ),
                                  feedback: Container(
                                    padding: EdgeInsets.only(top: truckTop, left: truckLeft),
                                    child: DragTruck(),

                                  ),
                                  childWhenDragging: Container(
                                    padding: EdgeInsets.only(top: truckTop, left: truckLeft),
                                    child:  DragTruck(),

                                  ),
                                  onDragCompleted: () {},
                                  onDragEnd: (drag) {
                                    setState(() {
                                      if((truckTop + drag.offset.dy) > (300.0 - 30.0)){
                                        truckTop = (300.0 - 30.0);
                                      }else if((truckTop + drag.offset.dy-30.0) < 0.0){
                                        truckTop = 0;
                                      }else{
                                        truckTop =  truckTop + drag.offset.dy-30.0;
                                      }if((left + drag.offset.dx) > (300.0 - 30.0)){
                                        truckLeft = (300.0 - 30.0);
                                      }else if((truckLeft + drag.offset.dx-30.0) < 0.0){
                                        truckLeft = 0;
                                      }else{
                                        truckLeft =  truckLeft + drag.offset.dx-30.0;
                                      }});
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _toggle();
                                    tapped = true;
                                  });
                                  print(tapped);
                                },
                                child: Draggable(
                                  child: Container(
                                    padding: EdgeInsets.only(top: pickUpTop, left: pickUpLeft),
                                    child: DragPickUp(),
                                  ),
                                  feedback: Container(
                                    padding: EdgeInsets.only(top: pickUpTop, left: pickUpLeft),
                                    child: DragPickUp(),

                                  ),
                                  childWhenDragging: Container(
                                    padding: EdgeInsets.only(top: pickUpTop, left: pickUpLeft),
                                    child:  DragPickUp(),

                                  ),
                                  onDragCompleted: () {},
                                  onDragEnd: (drag) {
                                    setState(() {
                                      if((pickUpTop + drag.offset.dy) > (300.0 - 30.0)){
                                        pickUpTop = (300.0 - 30.0);
                                      }else if((pickUpTop + drag.offset.dy-30.0) < 0.0){
                                        pickUpTop = 0;
                                      }else{
                                        pickUpTop =  pickUpTop + drag.offset.dy-30.0;
                                      }if((left + drag.offset.dx) > (300.0 - 30.0)){
                                        pickUpLeft = (300.0 - 30.0);
                                      }else if((pickUpLeft + drag.offset.dx-30.0) < 0.0){
                                        pickUpLeft = 0;
                                      }else{
                                        pickUpLeft =  pickUpLeft + drag.offset.dx-30.0;
                                      }});
                                  },
                                ),
                              ),

                            ],
                          ),

                      ),
                    ),
                  ],
                ),

                //show image capture PNG
                inside ? CircularProgressIndicator()
                    :
                imageInMemory != null
                    ? Padding(
                      padding: const EdgeInsets.only(top: 400),
                      child: Container(
                      child: Image.memory(imageInMemory),
                      margin: EdgeInsets.all(10),
                      decoration: myBoxDecoration(),
                      ),
                    )
                    : Container(),
                //paint
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();
                      points.add(DrawingPoints(
                          points: renderBox.globalToLocal(details.globalPosition),
                          paint: Paint()
                            ..strokeCap = strokeCap
                            ..isAntiAlias = true
                            ..color = selectedColor.withOpacity(opacity)
                            ..strokeWidth = strokeWidth));
                    });
                  },
                  onPanStart: (details) {
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();
                      points.add(DrawingPoints(
                          points: renderBox.globalToLocal(details.globalPosition),
                          paint: Paint()
                            ..strokeCap = strokeCap
                            ..isAntiAlias = true
                            ..color = selectedColor.withOpacity(opacity)
                            ..strokeWidth = strokeWidth));
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      points.add(null);
                    });
                  },

//cursor vira pincel ou arrasta os ícones legenda
                  child: Container(
                    child: _opcaoCursor(),

//                    CustomPaint(
//                      size: Size.infinite,
////                      painter: _opcaoCursor(),
//                      painter: DrawingPainter(
//                        pointsList: points,
//                      ),
//                    ),
                  ),
                ),
//                new Stack(
//                 // mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    new Text(
//                      ' ',
//                    ),
//                    new RaisedButton(
//                      child: Text('SALVAR IMAGEM'),
//                      onPressed: _capturePng,
//                    ),
//                    inside ? CircularProgressIndicator()
//                        :
//                    imageInMemory != null
//                        ? Container(
//                        child: Image.memory(imageInMemory),
//                        margin: EdgeInsets.all(10))
//                        : Container(),
//                  ],
//                ),
              ],
            ),
          ),

    );
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
    //  onTap: () {
//        showDialog(
//          context: context,
//          child: AlertDialog(
//            title: const Text('Pick a color!'),
//            content: SingleChildScrollView(
//              child: ColorPicker(
//                pickerColor: pickerColor,
//                onColorChanged: (color) {
//                  pickerColor = color;
//                },
//                //enableLabel: true,
//                pickerAreaHeightPercent: 0.8,
//              ),
//            ),
//            actions: <Widget>[
//              FlatButton(
//                child: const Text('Save'),
//                onPressed: () {
//                  setState(() => selectedColor = pickerColor);
//                  Navigator.of(context).pop();
//                },
//              ),
//            ],
//          ),
//        );
   //   },
      child: ClipOval(
//        child: Container(
//          padding: const EdgeInsets.only(bottom: 16.0),
//          height: 36,
//          width: 36,
//          decoration: BoxDecoration(
//              gradient: LinearGradient(
//                colors: [Colors.red, Colors.green, Colors.blue],
//                begin: Alignment.topLeft,
//                end: Alignment.bottomRight,
//              )),
//        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }

//legendas
class DragBus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
        Icons.directions_bus,
        //IconData(57744, fontFamily: 'MaterialIcons'),
        size: 47,
      );

  }
}
class DragCar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Icon(
          Icons.directions_car,
          //IconData(57744, fontFamily: 'MaterialIcons'),
          size: 40,
        );
  }
}
class DragBike extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
          Icons.directions_bike,
          //IconData(57744, fontFamily: 'MaterialIcons'),
          size: 37,
        );
  }
}
class DragPerson extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
          Icons.directions_run,
          //IconData(57744, fontFamily: 'MaterialIcons'),
          size: 37,
        );
  }
}
class DragTruck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ImageIcon(
          // Image.asset("images/ETT.png", fit: BoxFit.contain)
          AssetImage('images/caminhao.png'),
          size: 45,
          //color: Colors.black,
        );
  }
}
class DragPickUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ImageIcon(
          // Image.asset("images/ETT.png", fit: BoxFit.contain)
          AssetImage('images/caminhoneta.png'),
          size: 50,
          //color: Colors.black,
        );
  }
}

//salvar imagem
//https://stackoverflow.com/questions/50320479/flutter-how-would-one-save-a-canvas-custompainter-to-an-image-file