import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:sale_spot/classes/user.dart';

class FeedBack extends StatefulWidget {
	User _user;
	FeedBack(this._user);

	@override
	_FeedBackState createState() => _FeedBackState(_user);
}

class _FeedBackState extends State<FeedBack> {
	User _user;
	_FeedBackState(this._user);

	var feedbackForm = GlobalKey<FormState>();

	bool _isLoading = false;

	String emailTitle, emailDescription;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Feedback'),
			),
			body: Padding(
				padding: EdgeInsets.all(10.0),
				child: Form(
					key: feedbackForm,
					child: ListView(
						children: <Widget>[
							Padding(
								padding: const EdgeInsets.all(10.0),
								child: TextFormField(
									validator: (value) {
										if(value.length == 0)
											return 'Enter Title';
										else if(value.length>30)
											return 'Title too long';
										else
											return null;
									},
									onSaved: (value) {
										emailTitle = value;
									},
									decoration: InputDecoration(
										labelText: 'Title',
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(20.0)
										)
									),
								),
							),
							Padding(
								padding: const EdgeInsets.all(10.0),
								child: TextFormField(
									validator: (value) {
										if(value.length == 0)
											return 'Enter Description';
										else
											return null;
									},
									onSaved: (value) {
										emailDescription = value;
									},
									maxLines: 6,
									decoration: InputDecoration(
										labelText: 'Description',
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(20.0)
										)
									),
								),
							),
							Padding(
								padding: const EdgeInsets.all(10.0),
								child: Center(
									child: RaisedButton(
										child: _isLoading?Loading(indicator: BallPulseIndicator(),size: 10.0,):
										Text('Submit',
											style: TextStyle(
												color: Colors.white
											),),
										color: Colors.black,
										onPressed: _isLoading?() {} :sendEmail,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(20.0),
										),
									),
								),
							)
						],
					),
				)
			),
		);
	}
	void sendEmail() async {
		if(feedbackForm.currentState.validate()) {
			setState(() {
			  _isLoading = true;
			});
			feedbackForm.currentState.save();
			Email email = Email(
				body: _user.email+'\n\n'+emailDescription,
				subject: emailTitle,
				recipients: ['tosalespot@gmail.com'],
				isHTML: false
			);
			await FlutterEmailSender.send(email);
			setState(() {
			  _isLoading = false;
			});
		}
	}
}


