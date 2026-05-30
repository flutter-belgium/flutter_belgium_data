class CommunityLinks {
  const CommunityLinks({
    required this.slackInviteUrl,
    required this.youtubeChannelUrl,
    required this.meetupUrl,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.madeInUrl,
  });

  final String slackInviteUrl;
  final String youtubeChannelUrl;
  final String meetupUrl;
  final String linkedinUrl;
  final String githubUrl;
  final String madeInUrl;

  factory CommunityLinks.fromJson(Map<String, dynamic> json) => CommunityLinks(
    slackInviteUrl: json['slackInviteUrl'] as String,
    youtubeChannelUrl: json['youtubeChannelUrl'] as String,
    meetupUrl: json['meetupUrl'] as String,
    linkedinUrl: json['linkedinUrl'] as String,
    githubUrl: json['githubUrl'] as String,
    madeInUrl: json['madeInUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'slackInviteUrl': slackInviteUrl,
    'youtubeChannelUrl': youtubeChannelUrl,
    'meetupUrl': meetupUrl,
    'linkedinUrl': linkedinUrl,
    'githubUrl': githubUrl,
    'madeInUrl': madeInUrl,
  };
}
