class Topics {
  static const world = Topic('World');
  static const business = Topic('Business');
  static const technology = Topic('Technology');
  static const entertainment = Topic('Entertainment');
  static const science = Topic('Science');
  static const sports = Topic('Sports');
  static const health = Topic('Health');

  //Tchad specific topics
  static const alwihdainfo = Topic('AlwihdaInfo');
  static const tchadinfos = Topic('TchadInfos');
  static const tchadactu = Topic('TchadActu');
  static const lePays = Topic('LePays');
  static const tchadone = Topic('TchadOne');
  static const makaila = Topic('Makaila');
}

class Topic {
  final String value;

  const Topic(this.value);
}

List<Topic> topicList = [
  Topics.world,
  Topics.business,
  Topics.technology,
  Topics.entertainment,
  Topics.science,
  Topics.sports,
  Topics.health,
  // Tchad specific topics
  Topics.alwihdainfo,
  Topics.tchadinfos,
  Topics.tchadactu,
  Topics.lePays,
  Topics.tchadone,
  Topics.makaila,
];
