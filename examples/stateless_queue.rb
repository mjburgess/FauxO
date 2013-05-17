require_relative '../action'

def inputter(message)
  ->() {
    puts message
    gets
  }
end

def validator(regex)
  ->(data) { puts data =~ regex ? 'match' : 'fail'}
end


Couple.weave [inputter('Name?'), inputter('Age?')], [validator(/[A-Za-z]+/), validator(/\d\d/)]

def input(message)
  puts message
  gets
end

def validate(data, regex)
  puts data =~ regex ? 'match' : 'fail'
end

questions  = Couple.repeating :input, ['Name?', 'Age?', 'Location?']
validators = Couple.repeating :validate, [/[A-Za-z]+/, /\d{1,3}/, /[A-Za-z]+/]

questions.weave(validators)
