import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/firebase_options.dart';


Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TO DO APP',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final CollectionReference _todos = FirebaseFirestore.instance.collection("tasks_management");
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do List'),
        elevation: 12,
      ),
      body: SafeArea(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ajouter une tache',
                      border:OutlineInputBorder(),
                      suffixIcon:IconButton(
                          onPressed: () async{
                              await _todos.add({
                                'task': _controller.text,
                                'done': false,
                              }
                             );
                              _controller.clear();
                          },
                          icon: Icon(Icons.add),
                      )
                    ),
                  ),
              ),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _todos.snapshots(),
                      builder: (context, snapshot){
                        if (snapshot.hasData) {
                            return ListView(
                              children:
                              snapshot.data!.docs.map((doc) {
                                  return ListTile(
                                    title: Text(doc['task']),
                                    trailing: IconButton(
                                        onPressed: () async{
                                          await _todos.doc(doc.reference.id).delete();
                                        },
                                        icon: Icon(Icons.delete))

                                  );
                              }).toList(),
                            );}
                        else if(snapshot.connectionState == ConnectionState.waiting){
                              return Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                        }
                        else{
                          return Center(
                            child:  Text('Aucune tache disponible'),
                          );
                        }
                      }
                  )
              )
            ],
          )
      )
    );
  }
}

