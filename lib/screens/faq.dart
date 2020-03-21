import 'package:flutter/material.dart';

class Faq extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

  	// Add question here
  	List<String> question=[
  		'Is this App free?',
		'Is it going to be the end of the world in 2020?'
	];
  	// Add answer here(In order)
  	List<String> answer=[
  		'The app is completely free of cost.',
		"Its just March, let's wait and watch.",

	];


    return Scaffold(
		appBar: AppBar(
			title: Text('FAQ'),
		),
		body: Padding(
		  padding: const EdgeInsets.all(10.0),
		  child: ListView.builder(
		  	itemBuilder: (BuildContext context, int index) {
		  		return ExpansionTile(
		  			title: Text(question[index]),
		  			children: <Widget>[
		  				ListTile(
							title: Text(answer[index]),
						)
		  			],
		  		);
		  	},
		  	itemCount: question.length,
		  ),
		),
	);
  }
}
