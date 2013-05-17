require_relative '../optional'

a = 10
b = nil
oa = Optional.new a
ob = Optional.new b

#inner never gets exec'd when b = nil
oa.get do |a|
  ob.get do |b|
    puts a + b
  end
end

oa.get do |a|
  ob.getOr(100) do |b|
    puts a + b
  end
end