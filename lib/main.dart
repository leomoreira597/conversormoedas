import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=92219317";

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controleDoReal = TextEditingController();
  final controleDoDolar = TextEditingController();
  final controleDoEuro = TextEditingController();
  
  double dolar;
  double euro;
  
  void _trocaDoReal(String text){
    double real = double.parse(text);
    controleDoDolar.text = (real/dolar).toStringAsFixed(2);
    controleDoEuro.text = (real/euro).toStringAsFixed(2);
  }

  void _trocaDoDolar(String text){
    double dolar = double.parse(text);
    controleDoReal.text = (dolar* this.dolar).toStringAsFixed(2);
    controleDoEuro.text = (dolar * this.dolar/euro).toStringAsFixed(2);
  }

  void _trocaDoEuro(String text){
    double euro = double.parse(text);
    controleDoReal.text = (euro * this.euro).toStringAsFixed(2);
    controleDoDolar.text = (euro * this.euro/dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados :(",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField("Reais", "R\$: ", controleDoReal, _trocaDoReal),
                      Divider(),
                      buildTextField("Dolares", "US\$: ", controleDoDolar, _trocaDoDolar),
                      Divider(),
                      buildTextField("Euros", "€: ", controleDoEuro, _trocaDoEuro),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controle, Function f){
  return  TextField(
    controller: controle,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      fillColor: Colors.amber,
      hoverColor: Colors.amber,
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
