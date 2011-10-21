### AmionSchedule

[Amion](http://amion.com) is a physician scheduling service. They
offer a programming interface that allows you to get a group's
schedule in CSV format.

This module parses that CSV format and returns a list of physicians
working on a certain day, with data about how many days in a row
they've worked and how many days in a row they're scheduled to work.

#### How to use it

Call the `get_one_day_from_amion` function, passing it an Amion group
password. It will return an array of hashes. Each hash will be one
physician on the schedule with values for :name, :shift, :service, :day,
and :stretch. Day and stretch will only be calculated for physicians
doing day shifts. For all others, they will be zero.

    vinod:~/dev/amion_schedule$ irb
    irb(main):001:0> require './amion_schedule.rb'
    => true
    irb(main):003:0> get_one_day_from_amion("YourAmionPassword")
    [{:name=>"Molitor", :shift=>"Day Shift", :service=>"5-1", :day=>7, :stretch=>8},
     {:name=>"Yount", :shift=>"Day Shift", :service=>"5-1", :day=>4, :stretch=>5},
     {:name=>"Cooper", :shift=>"Day Shift", :service=>"5-2", :day=>5, :stretch=>9},
     {:name=>"Thomas", :shift=>"Day Shift", :service=>"5-2", :day=>3, :stretch=>5},
     {:name=>"Ogilvie", :shift=>"Day Shift", :service=>"5-3", :day=>6, :stretch=>6},
     {:name=>"Simmons", :shift=>"Day Shift", :service=>"5-3", :day=>1, :stretch=>4},
     {:name=>"Moore", :shift=>"Flex", :service=>nil, :day=>0, :stretch=>0},
     {:name=>"Gantner", :shift=>"12-9", :service=>nil, :day=>0, :stretch=>0},
     {:name=>"Howell", :shift=>"Evening", :service=>nil, :day=>0, :stretch=>0},
     {:name=>"Sutton", :shift=>"Night", :service=>nil, :day=>0, :stretch=>0},
     {:name=>"Fingers", :shift=>"Night", :service=>nil, :day=>0, :stretch=>0}]
