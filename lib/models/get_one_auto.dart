class GetOneAuto {
  bool? status;
  String? message;
  Res? res;

  GetOneAuto({this.status, this.message, this.res});

  GetOneAuto.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    res = json['res'] != null ? new Res.fromJson(json['res']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.res != null) {
      data['res'] = this.res!.toJson();
    }
    return data;
  }
}

class Res {
  int? start;
  String? body;
  int? interval;
  String? charset;
  String? subject;
  int? stop;
  String? from;
  int? isHtml;

  Res(
      {this.start,
        this.body,
        this.interval,
        this.charset,
        this.subject,
        this.stop,
        this.from,
        this.isHtml});

  Res.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    body = json['body'];
    interval = json['interval'];
    charset = json['charset'];
    subject = json['subject'];
    stop = json['stop'];
    from = json['from'];
    isHtml = json['is_html'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start'] = this.start;
    data['body'] = this.body;
    data['interval'] = this.interval;
    data['charset'] = this.charset;
    data['subject'] = this.subject;
    data['stop'] = this.stop;
    data['from'] = this.from;
    data['is_html'] = this.isHtml;
    return data;
  }
}
