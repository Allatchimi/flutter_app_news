class Topics {

  //Tchad specific topics
  static const ManaraTv = Topic('ManaraTv');
  static const alwihdainfo = Topic('AlwihdaInfo');
  static const leNdjampost = Topic('LeNdjamPost');
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
  Topics.ManaraTv,
  Topics.alwihdainfo,
  Topics.leNdjampost,
  Topics.tchadinfos,
  Topics.tchadactu,
  Topics.lePays,
  Topics.tchadone,
  Topics.makaila,
];
