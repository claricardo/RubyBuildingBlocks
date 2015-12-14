require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  tmp_number = phone_number.gsub(/\D/, ' ').split.join
  
  if !(10..11).include? tmp_number.length
    '0' * 10
  elsif tmp_number.length == 11
    tmp_number[0] == '1' ? tmp_number[-10..-1] : '0' * 10
  else
	tmp_number
  end
end

def date_from_str(reg_date)
  DateTime.strptime(reg_date, "%y/%d/%m %H:%M")
end

def get_peak_registration_hours(reg_hours)
  max_freq = reg_hours.values.max
  reg_hours.keys.select { |hour| reg_hours[hour] == max_freq }.sort
end

def get_peak_registration_dow(reg_dow)
  max_freq = reg_dow.values.max
  reg_dow.keys.select { |day| reg_dow[day] == max_freq }.sort
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"
  
  filename = "output/thanks_#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"
puts 

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

hours_freq = Hash.new(0)
dow_freq = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  reg_date = date_from_str(row[:regdate])
  hours_freq[reg_date.hour] += 1
  dow_freq[reg_date.strftime("%A")] += 1
  
  puts "#{name}\t\t#{zipcode}\t#{phone_number}\t#{reg_date.strftime("%H:%M")}\t#{reg_date.strftime("%A")}"
  
  legislators = legislators_by_zipcode(zipcode)
  
  form_letter = erb_template.result(binding)
  
  save_letters(id, form_letter)
end

puts
puts "Peak registration hours: " + get_peak_registration_hours(hours_freq).join(', ')
puts "Peak registration days of week: " + get_peak_registration_dow(dow_freq).join(', ')


