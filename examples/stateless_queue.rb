require_relative '../action'

# FREE

def data_producer
  ['Michael', (Random.rand * 100).to_int]
end

def data_transformer(data)
  {name: data[0], age: data[1]}
end

def data_consumer(data)
  if data[:name].length > 0 && data[:age] > 1
    puts data.inspect
  else
    puts “invalid format”
  end
end


producer = Couple.new Array.new 5, :data_producer
consumer = Couple.new Array.new 5, :data_consumer

producer.weave_with(consumer) do |consumer, producer|
  [[consumer], [->() { (data_transformer(producer.call)) }]]
end

#DEPS

def input(message)
  puts message
  gets
end

def validate(data, regex)
  puts data =~ regex ? 'match' : 'fail'
end

questions = Couple.repeating :input, ['Name?', 'Age?', 'Location?']
validators = Couple.repeating :validate, [/[A-Za-z]+/, /\d{1,3}/, /[A-Za-z]+/]

questions.weave(validators)

# HYBRID

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

