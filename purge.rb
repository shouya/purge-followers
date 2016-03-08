require_relative 'oauth'

THRESHOLD = 0

@victims = []
@victims_info = []

def force_unfo!(user_uri)
  screen_name = user_uri.sub('https://twitter.com/', '')
  $client.block(screen_name)
  $client.unblock(screen_name)
end

def purge
  @victims.each do |victim|
    puts "Goodbye #{victim}!"
    force_unfo! victim
  end
end

items = File.read('report.txt').lines
items.each do |line|
  user_uri, score, _ = line.split
  score = score.to_i
  if score < THRESHOLD
    @victims << user_uri
    @victims_info << line
  end
end


@victims_info.each do |info|
  puts info
end

puts "Number of victims to be removed #{@victims.count}"
print 'Please double check and enter "PURGE": '
if gets.chomp == 'PURGE'
  3.times do |x|
    print "#{3-x}."
    sleep 1
  end
  puts
  purge
end
