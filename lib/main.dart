import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "*****",
    anonKey: "*****",
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App - AT117',
      home: NotesApp(),
    )
  );
}

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {

  final notesStream = Supabase.instance.client.from('notes').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes App'),
        elevation: 0,
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, builder: (BuildContext context){
              return SimpleDialog(
                title: Text('Add a Note', textAlign: TextAlign.center,),
                contentPadding: EdgeInsets.all(50),
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) async{
                      await Supabase.instance.client.from('notes').insert({'body':value});
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red)
                    ),
                    child: Text('Close', style: TextStyle(color: Colors.white),),
                  )
                ],
              );
            }
          );
        },
        backgroundColor: Colors.cyan,
        child: Icon(Icons.note_add_outlined,),
      ),
      body:
       StreamBuilder<List<Map <String, dynamic>>>(
        stream: notesStream,
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator(color: Colors.cyan,));
          }
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 2)
                  ),
                  child: ListTile(
                    title: Text(notes[index]['body']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await Supabase.instance.client.from('notes').delete().eq('id', notes[index]['id']);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}