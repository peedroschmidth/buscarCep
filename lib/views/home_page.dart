import 'package:flutter/material.dart';
//import 'package:search_cep/services/via_cep_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:web_service/models/result_cep.dart';
import 'package:web_service/services/via_cep_service.dart';
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _searchCepController = TextEditingController();
  bool _loading = false;
  bool _enableField = true;
  String _result = '';
  String erro = '';

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar CEP'),

        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.ios_share),
            onPressed: (){
              Share.share(_result);

            },
    ),
    ],
    ),


      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'CEP'),
      controller: _searchCepController,
      enabled: _enableField,
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        onPressed: _searchCep,
        child: _loading ? _circularLoading() : Text('Buscar'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  Widget _circularLoading() {
    return Container(
      height: 15.0,
      width: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  void showTopSnackBar(BuildContext contex, String erro) =>
      Flushbar(
            icon: Icon(Icons.error, size: 32, color: Colors.red),
            shouldIconPulse: false,
            title: 'Erro',
            message: erro,
            duration: const Duration(seconds: 4),
            flushbarPosition: FlushbarPosition.TOP,

          )..show(context);


  Future _searchCep() async {
    _searching(true);

    final cep = _searchCepController.text;

    if (cep.length==8) {
      final resultCep = await ViaCepService.fetchCep(cep: cep);
      if (resultCep.erro!=null){
      setState(() {
        _result = resultCep.toJson().toUpperCase().replaceAll("{", "").replaceAll(":", ";").replaceAll("}", "").replaceAll('"', "").replaceAll(",", "\n\n").replaceAll(";", ":  ");

      });
      _searching(false);
      print(cep.length);

    }
      }
    else {
      erro = 'CEP inválido';
      print('CEP inválido');
      showTopSnackBar(context, erro);
      _searching(false);
    }
    }
  //}

  void _share (){

    dynamic cep;
    if(_result !=''){
      cep = ResultCep.fromJson(_result);
      Share.share(
        "cep: ${cep.cep}, Logradouro:${cep.logradouro}, Complemento:${cep.complemento},"
            "Bairro ${cep.bairro}, Cidade${cep.cidade}, UF:${cep.uf}, Ibge:${cep.ibge},"
            "Gia: ${cep.gia}, DDD:${cep.ddd}, Siafi:${cep.siafi}.",

      );
    }
  }

  Widget _buildResultForm() {
    return Container(
        padding: EdgeInsets.only(top: 20.0),
        child: Text(_result ?? '')
    );
  }

  show(BuildContext context, Flushbar flushbar) {}
}