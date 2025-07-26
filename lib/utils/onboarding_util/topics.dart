class Topics {
  static const world = Topic('World');
  static const nation = Topic('Nation');
  static const business = Topic('Business');
  static const technology = Topic('Technology');
  static const entertainment = Topic('Entertainment');
  static const science = Topic('Science');
  static const sports = Topic('Sports');
  static const health = Topic('Health');
  static const politics = Topic('Politics');
  static const education = Topic('Education');

  // Custom topics
  static const lifestyle = Topic('Lifestyle');
  static const defaultTopic = Topic('Default');
  static const latest = Topic('Latest');
  static const trending = Topic('Trending');
  static const top = Topic('Top');
  static const popular = Topic('Popular');
  static const breaking = Topic('Breaking');
  static const opinion = Topic('Opinion');
  static const analysis = Topic('Analysis'); 
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
  Topics.nation,
  Topics.business,
  Topics.technology,
  Topics.entertainment,
  Topics.science,
  Topics.sports,
  Topics.health,
  Topics.politics,
  Topics.education,
  Topics.lifestyle,
  Topics.defaultTopic,
  Topics.latest,
  Topics.trending,
  Topics.top,
  Topics.popular,
  Topics.breaking,
  Topics.opinion,
  Topics.analysis,  
  // Tchad specific topics
  Topics.alwihdainfo,
  Topics.tchadinfos,
  Topics.tchadactu,
  Topics.lePays,
  Topics.tchadone,
  Topics.makaila, 
  
];