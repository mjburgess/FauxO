# interleaving

# Calculator

class Calculator
  attr_reader :state

  def initialize(initial)
    @state = initial
  end

  def add!(x)
    @state += x
  end
end

require 'time'

def get_user(id)
  "Michael is 24 on May 30th"
end

def extract_date_from_user(user)
  user.match(/\w+ is \d\d on (\w+) (\d\d)/).captures.join(' ')
end

def diff_days(date)
  Date.parse(date) - Date.today
end

def print_message(days)
  puts days.to_int.to_s + ' days until birthday'
end

#[:get_user, :extract_date_from_user, :diff_days, :print_message].map { |s|
#  method(s)
#}.inject(1) { |state, fn|
#  fn.call state
#}

def validate_x(value)
  if value !~ /xyz/
    raise "Invalid"
  end
end

def get_x()
  puts "Enter X"
  gets
end

form_values = [:get_username, :get_password, :get_email]
validators  = [:validate_username, :validate_password, :validate_email]


