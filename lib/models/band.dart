class Band {
  String id;
  String name;
  int votes;

//Definimos el constructor, con llaves para que podamos ponerle nombres a esas propiedades y direcatementes asignarlas en el constructor
  Band({this.id, this.name, this.votes});

  // Un factori constructor: no es mas que un constructor que rebe un cierto tipo de argumentos y regresa una nueva instancia de mi clase

  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
}
