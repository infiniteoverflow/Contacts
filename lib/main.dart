import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.contacts.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future getContacts() async{
    List<Contact> contacts = await ContactsService.getContacts();
    print(contacts.length);
    return contacts;
  }

  ScrollController _controller = ScrollController();

  int currentIndex = 50;
  int totalSize = 0;
  late Future _future;
  late List<Contact> contacts;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = getContacts();
    _controller.addListener(() {
      if(_controller.position.atEdge) {
        if(_controller.position.pixels == 0) {

        } else {
          if(currentIndex+30 <= totalSize) {
            currentIndex += 30;
          } else {
            currentIndex = totalSize;
          }

          setState(() {

          });
        }
      }
    });
  }

  String getPhones(List<Item>? n) {
    if(n == null) return "null";
    String numbers = "";
    for(int i=0;i<n.length;i++) numbers+= (n[i].value! + " ");
    return numbers;
  }

  Future? showAlertDialog(BuildContext context,Contact contact,int index) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete"),
      onPressed: () async{
        await ContactsService.deleteContact(contact);
        contacts.removeAt(index);
        if(currentIndex+1 <= totalSize) {
          currentIndex += 1;
        } else {
          currentIndex = totalSize;
        }
        setState(() {

        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete ${contact.displayName?? "null"}"),
      content: Text("Are you sure you wanna delete this contact?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context,snapshot) {
          if(snapshot.hasData) {
            contacts = snapshot.data as List<Contact>;
            totalSize = contacts.length;
            if(currentIndex > totalSize) currentIndex = totalSize;
            return Scrollbar(
              thickness: 10,
              interactive: true,
              controller: _controller,
              showTrackOnHover: true,
              child: ListView.builder(
                controller: _controller,
                itemCount: contacts.take(currentIndex).length,
                itemBuilder: (context,index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        contacts[index].displayName?? "null",
                      ),
                      subtitle: Text(
                        getPhones(contacts[index].phones),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,color: Colors.red,),
                        onPressed: () async{
                          await showAlertDialog(context,contacts[index],index);

                        },
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
