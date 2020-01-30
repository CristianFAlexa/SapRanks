import 'package:bored/model/QueueModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:bored/model/Regex.dart';

class CreateQueue extends StatefulWidget {
  CreateQueue({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  @override
  _CreateQueueState createState() => _CreateQueueState(user: user, gameName: gameName);
}

class _CreateQueueState extends State<CreateQueue> {
  _CreateQueueState({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _minPlayers;
  String _maxPlayers;
  String _location;
  String _description;
  DateTime _eventDate;
  TimeOfDay _eventTime;
  String _tmpMin;

  Future addNewQueue(BuildContext context) async {
    final _formState = _formKey.currentState;
    _formState.save();
    var uid = Uuid().v4();

    final DateTime dateTime = new DateTime(_eventDate.year, _eventDate.month, _eventDate.day, _eventTime.hour, _eventTime.minute);
    queueCollectionReference.document(gameName).collection('active').document('$uid').setData(QueueModel(
            new Timestamp.now(),
            new List<String>.from([user.uid]),
            int.parse(_minPlayers),
            int.parse(_maxPlayers),
            new Timestamp.fromDate(dateTime),
            _location,
            _description,
            user.uid,
            new List<String>.from([user.uid]),
            new List<String>.from([null]),
            gameName,
            false)
        .toMap());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: GradientAppBar(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.black38, Colors.black12]),
      ),
      body: Form(
        key: _formKey,
        child: Builder(
          builder: (context) => Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 32),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 50,
                        padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Choose location!';
                            }
                            return null;
                          },
                          onSaved: (input) => _location = input,
                          decoration: InputDecoration(icon: Icon(Icons.location_city), hintText: 'Location'),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 35,
                          ),
                          SizedBox(
                            width: 56,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () {
                                showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                                  setState(() {
                                    _eventTime = time;
                                  });
                                });
                                showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2019), lastDate: DateTime(2050)).then((date) {
                                  setState(() {
                                    _eventDate = date;
                                  });
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.blueGrey,
                              child: new Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.479,
                            height: 50,
                            padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                            child: TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Choose event date!';
                                }
                                return null;
                              },
                              controller: TextEditingController.fromValue((_eventDate == null || _eventTime == null)
                                  ? TextEditingValue(text: '')
                                  : TextEditingValue(
                                      text:
                                          '${_eventDate.day.toString()}.${_eventDate.month.toString()}.${_eventDate.year.toString()} at ${_eventTime.hour.toString()}:${_eventTime.minute.toString()}')),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 50,
                        padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Choose a short description!';
                            }
                            return null;
                          },
                          onSaved: (input) => _description = input,
                          decoration: InputDecoration(icon: Icon(Icons.description), hintText: 'Description'),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 50,
                        padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                        child: TextFormField(
                          validator: (input) {
                            _tmpMin = input;
                            if (input.isEmpty) {
                              return 'Choose minimum players!';
                            } else if (!Regex.number.hasMatch(input)) {
                              return 'Number should be at most 2 digit long!';
                            }
                            return null;
                          },
                          onSaved: (input) => _minPlayers = input,
                          decoration: InputDecoration(icon: Icon(Icons.people), hintText: 'Min players'),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 50,
                        padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Choose maximum players!';
                            } else if (!Regex.number.hasMatch(input)) {
                              return 'Number should be at most 2 digit long!';
                            } else if (int.parse(_tmpMin) > int.parse(input)) {
                              return 'Maximum number of players must be greater than minimum!';
                            }
                            return null;
                          },
                          onSaved: (input) => _maxPlayers = input,
                          decoration: InputDecoration(icon: Icon(Icons.people), hintText: 'Max players'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Spacer(),
                RaisedButton(
                  onPressed: () => {
                    if (_formKey.currentState.validate())
                      addNewQueue(context)
                    else
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Cannot create event!")))
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: Colors.blueGrey,
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.add_to_queue,
                        color: Colors.white,
                      ),
                      new Container(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Text(
                            "All set up",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
