require 'csv'
require 'open-uri'
require 'date'

def get_one_day_from_amion(password)
  csv = get_all_csv_data(password, Date.today)
  s = make_schedule(csv)
  ds = one_day_schedule(s, Date.today)
end

private

def get_one_file(password, month, year)
  url = URI.escape("http://www.amion.com/cgi-bin/ocs?Lo=#{password}&Rpt=619&Month=#{month}&Year=#{year}")
  data = open(url).read
  if data =~ /NOFI=No file/
    raise "Invalid AMION password."
  else
    data
  end
end

def get_all_csv_data(password, date)
  # Choose 2 dates which will cover all possible stretch lengths.
  # A stretch is never more than 10 days long, so 30 days will
  # definitely cover it.
  dates = [date - 15, date + 15]
  schedules_to_get = dates.map { |d| { :month => d.month, :year => d.year} }.uniq

  data = []
  schedules_to_get.each do |sched|
    # parse the CSV and strip the first 6 lines (HEADER)
    csv = CSV.parse(get_one_file(password, sched[:month], sched[:year])).slice(6..-1)
    data += csv
  end
  return data
end

def parse_date(line)
  Date.strptime(line[6],'%m-%e-%y')
end

def parse_name(line)
  line[0]
end

def parse_long_shift(line)
  line[3]
end

def parse_shift(line)
  ls = parse_long_shift(line)
  return "Flex" if ls =~ /^Hospitalist 7/
  return "12-9" if ls =~ /Day Admit/
  return "Day Shift" if ls =~ /^Hospitalist [1-6]/
  return ls.split[0]
end

def parse_service(line)
  ls = parse_long_shift(line)
  service = /\((5.[123])\)/.match(ls)
  service[1] if service
end

def make_schedule(csv_data)
  schedule = {}

  csv_data.each do |line|
    # skip unwanted shifts
    next if parse_long_shift(line) =~ /^Teaching|^Administrator|^Jeopardy|^NP-PA|^Ortho|Palliative|^9050 Morning/

    # date will be our key
    date = parse_date(line)

    name = parse_name(line)
    shift = parse_shift(line)
    service = parse_service(line)

    # create or append to the date's entry in our schedule
    schedule[date] ||= []
    schedule[date] << { name: name, shift: shift, service: service}
  end

  return schedule
end

def one_day_schedule(schedule, date)
  day_schedule = schedule[date]

  day_schedule.map! do |hosp|
    if hosp[:shift] == "Day Shift"
      # Calculate which day of the stretch they are
      hosp_day = 1
      # Check if they worked yesterday. If so, increment hosp_day
      day = date - 1
      while schedule[day].index{ |past| past[:name] == hosp[:name] and past[:shift] == "Day Shift"} 
        hosp_day += 1
        day -= 1
      end
      
      hosp_stretch = hosp_day
      day = date + 1
      while schedule[day].index{ |future| future[:name] == hosp[:name] and future[:shift] == "Day Shift"} 
        hosp_stretch += 1
        day += 1
      end
      
      hosp[:day] = hosp_day
      hosp[:stretch] = hosp_stretch
    else
      hosp[:day] = 0
      hosp[:stretch] = 0
    end
    hosp
  end
  day_schedule
end

