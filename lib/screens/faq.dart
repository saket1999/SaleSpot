import 'package:flutter/material.dart';

class Faq extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

  	// Add question here
  	List<String> question=[
  		'Is this the FAQ page?',
  		'Is this App free?',
			'Can I sell anything and everything?',
			'How can I see the details of product I added in the cart?',
			'Does this app contain Ads?',
			'Do the products I list expire?',
			'Why do I need to provide my address?',
			'\'I cannot find the relevant Category/Subcategory.\' What should I do?'
	];
  	// Add answer here(In order)
  	List<String> answer=[
  		'Yes, you have reached the correct screen.',
  		'The app is completely free of cost.',
			'It\'s not good if you think so.'
					'Anyways every advertisement you list is checked before becoming public.',
			'Just click the image icon of the product in the cart.',
			'Only the promotional section of the application contains Ads.',
			'The products expire in 30 days if not renewed.',
			'Your address is shown as the location of the products you have listed. The address can be updated through profile page',
			'There is an option named \'Other\' in each of the categories. If you believe that your category must be exclusively listed then you can always leave a feedback.'


	];


    return Scaffold(
		appBar: AppBar(
			title: Text('FAQ'),
		),
		body: Padding(
		  padding: const EdgeInsets.all(10.0),
		  child: ListView.builder(
		  	itemBuilder: (BuildContext context, int index) {
		  		return Card(
		  		  child: ExpansionTile(
		  		  	title: Text(question[index]),
		  		  	children: <Widget>[
		  		  		ListTile(
							title: Text(answer[index]),
						)
		  		  	],
		  		  ),
		  		);
		  	},
		  	itemCount: question.length,
		  ),
		),
	);
  }
}
