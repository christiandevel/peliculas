import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/actores_model.dart';
import 'package:peliculas/src/models/pelicula_model.dart';

class PeliculasProvider {
  String _apikey = 'fe3fb95de8b14d8e458c2a0eb78371b3';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();
  final _popularesStreamControlers = StreamController<List<Pelicula>>.broadcast();
  Function(List<Pelicula>) get popularesSink => _popularesStreamControlers.sink.add;
  Stream<List<Pelicula>> get popularesStream => _popularesStreamControlers.stream;

  void disposeStream(){
    _popularesStreamControlers?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url)async{
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);

    final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing',
        {'api_key': _apikey, 'language': _language});
        return await _procesarRespuesta(url);
  
  }

  Future<List<Pelicula>> getPopular() async {
    if(_cargando) return [];
    _cargando = true;
    _popularesPage++;
    final url = Uri.https(_url, '3/movie/popular',
        {
          'api_key' : _apikey,
          'language': _language,
          'page'    : _popularesPage.toString()
          });

    final resp = await  _procesarRespuesta(url);

    // final resp = await http.get(url);
    // final decodedData = json.decode(resp.body);

    // final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    // return peliculas.items;

    _populares.addAll(resp);
    popularesSink(_populares);
    _cargando = false;
    return resp;
  }

  
  Future<List<Pelicula>> getPopulares() async {
    if(_cargando) return [];
    _cargando = true;
    _popularesPage++;
    final url = Uri.https(_url, '3/movie/popular',
        {
          'api_key' : _apikey,
          'language': _language,
          'page'    : _popularesPage.toString()
          });

    final resp = await  _procesarRespuesta(url);
    _populares.addAll(resp);
    popularesSink(_populares);
    _cargando = false;
    return resp;
  }

  Future<List<Actor>> getCast(String peliId) async{
    final url = Uri.https(_url, '3/movie/$peliId/credits', {
      'api_key': _apikey, 'language': _language
    });

    final respu = await http.get(url);
    final decodedDate = json.decode(respu.body);

    final cast = new Cast.fromJsonList(decodedDate['cast']);

    return cast.actores;
  }


  Future<List<Pelicula>> buscarPelicula(String query) async {
    final url = Uri.https(_url, '3/search/movie',
        {'api_key': _apikey,
         'language': _language,
         'query' : query
         });

    return await _procesarRespuesta(url);
  
  }
}
