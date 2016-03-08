require 'twitter'
require 'twitter_oauth'
require 'json'
require 'time'

require_relative 'oauth'

def my_followers
  $client.followers(include_user_entities: true)
end

@force_unfo_list = []
def force_unfo(user, reason)
  puts "#{user.uri} #{reason}"
  @force_unfo_list << [user, reason]
end

KEYWORDS_BLACKLIST = File.read('keywords.txt').try(:split) || []

def match_keywords(attrs)
  kwds = []
  KEYWORDS_BLACKLIST.each do |kwd|
    kwds << kwd if attrs[:screen_name].downcase.include?(kwd)
    kwds << kwd if attrs[:name].downcase.include?(kwd)
    kwds << kwd if attrs[:description].downcase.include?(kwd)
  end
  return nil if kwds.empty?
  return kwds
end

def inactive_days(attrs)
  return 999 if attrs[:status].nil?
  nsec = (Time.now - Time.parse(attrs[:status][:created_at]))
  nsec / 60 / 60 / 24
end

def examine(user)
  @score = 100
  @reasons = []
  @keywords = []

  def punish(delta, reason = nil)
    @score += delta
    @reasons << reason if reason
  end

  attrs = user.attrs
  punish(9999) if attrs[:following]
  punish(10)  if attrs[:url]
  punish(10)  if attrs[:location]
  punish(-999, :protected) if attrs[:protected] and !attrs[:following]
  punish(-90, :def_avatar) if attrs[:default_profile_image]
  punish(-90, :no_media)   if attrs[:media_count] <= 2
  punish(-90, :no_tweet)   if attrs[:statuses_count] < 10
  punish(-20, :empty_bio)  if attrs[:description].empty?
  punish(-20, :little_likes) if attrs[:favourites_count] < 40
  punish(-20, :unlisted)   if attrs[:listed_count] < 2

  @keywords = match_keywords(attrs)
  punish(-51*@keywords.count, :keywords) if @keywords

  days = inactive_days(attrs)
  punish(-days, :inactive) if days > 5

  {
    user: user,
    score: @score.truncate || 0,
    reasons: @reasons,
    keywords: @keywords
  }
end

def print_result(result)
  print "#{result[:user].uri}"
  print " #{result[:score]}"
  print " #{result[:reasons].join(',')}"
  print " #{result[:keywords].join(',')}" if result[:keywords]
  puts ''
end

results = []

my_followers.each do |fo|
  results << examine(fo)
  print '.'
end
puts

results.sort_by! {|x| x[:score] }


results.each do |res|
  print_result(res)
end

File.open('report.txt', 'w') do |f|
  $orig_stdout, $stdout = $stdout, f
  results.each do |res|
    print_result(res)
  end
end

$stdout = $orig_stdout
