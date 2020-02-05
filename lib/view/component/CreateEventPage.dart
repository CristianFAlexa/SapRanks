import 'package:bored/model/Constants.dart';
import 'package:bored/model/QueueModel.dart';
import 'package:bored/model/Regex.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

class CreateEventPage extends StatefulWidget {
  CreateEventPage({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  @override
  _CreateEventPageState createState() => _CreateEventPageState(user: this.user, gameName: this.gameName);
}

class _CreateEventPageState extends State<CreateEventPage> {
 _CreateEventPageState({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _minPlayers;
  String _maxPlayers;
  String _tmpMin;
  String _location;
  String _description;
  DateTime _eventDate;
  TimeOfDay _eventTime;

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
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      body: Form(
        key: _formKey,
        child: Builder(
          builder: (context) => ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft, end: Alignment.centerRight, colors: Constants.appColors),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 100,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            'Create event',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Material(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Event Details',
                              style: TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      elevation: 10,
                      shadowColor: Constants.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 16, right: 8, left: 8),
                            child: TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Choose location!';
                                }
                                return null;
                              },
                              onSaved: (input) => _location = input,
                              decoration: InputDecoration(
                                  enabledBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                  focusedBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                  errorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  focusedErrorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  prefixIcon: Icon(Icons.location_city),
                                  hintText: 'Timisoara, st. Corleone, no 10',
                                  labelText: 'Location',
                                  helperText: 'Choose a event location.'),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: SizedBox(
                                  width: 56,
                                  height: 60,
                                  child: RaisedButton(
                                    onPressed: () {
                                      showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                                        setState(() {
                                          _eventTime = time;
                                        });
                                      });
                                      showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2019), lastDate: DateTime(2050))
                                          .then((date) {
                                        setState(() {
                                          _eventDate = date;
                                        });
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: Constants.primaryColor,
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
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 330,
                                height: 100,
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
                                  onSaved: (input) => _minPlayers = input,
                                  decoration: InputDecoration(
                                      enabledBorder: new OutlineInputBorder(
                                          borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                      focusedBorder:
                                          new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                      errorBorder:
                                          new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                      focusedErrorBorder:
                                          new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                      labelText: 'Date and time',
                                      helperText: 'Pick event date and time.'),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
                            child: TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Choose a short description!';
                                }
                                return null;
                              },
                              onSaved: (input) => _description = input,
                              decoration: InputDecoration(
                                  enabledBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                  focusedBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                  errorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  focusedErrorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  prefixIcon: Icon(Icons.description),
                                  hintText: 'Life is good.',
                                  labelText: 'Description',
                                  helperText: 'Additional informations.'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: (input) {
                                _tmpMin = input;
                                if (input.isEmpty) {
                                  return 'Minimum required!';
                                } else if (!Regex.number.hasMatch(input)) {
                                  return 'Number should be at most 2 digits long!';
                                }
                                return null;
                              },
                              onSaved: (input) => _minPlayers = input,
                              decoration: InputDecoration(
                                  enabledBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                  focusedBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                  errorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  focusedErrorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  prefixIcon: Icon(FontAwesomeIcons.minus),
                                  hintText: '2',
                                  labelText: 'Minimum',
                                  helperText: 'Minimum number of players.'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Maximum required!';
                                } else if (!Regex.number.hasMatch(input)) {
                                  return 'Number should be at most 2 digits long!';
                                } else if (int.parse(_tmpMin) > int.parse(input)) {
                                  return 'Maximum number of players must be greater than minimum!';
                                }
                                return null;
                              },
                              onSaved: (input) => _maxPlayers = input,
                              decoration: InputDecoration(
                                  enabledBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                  focusedBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                  errorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  focusedErrorBorder:
                                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                  prefixIcon: Icon(Icons.add),
                                  hintText: '99',
                                  labelText: 'Maximum',
                                  helperText: 'Maximum number of players.'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState.validate())
              addNewQueue(context);
            else
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Cannot create event!")));
          },
          child: Icon(Icons.check),
          backgroundColor: Constants.primaryColor,
          heroTag: 'createEventFloatingActionButton',
        ),
      ),
    );
  }
}
