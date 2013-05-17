require_relative '../action'

def add(x, y)
  x + y
end

def mul(x, y)
  x * y
end

def addOne(x)
  x + 1
end

def mulTwo(x)
  x * 2
end



multia = Complect.new [:add, :mul], [5, 10]

puts '(5 + 5) * 10 = ' + multia.run(5).to_s

multib = Complect.new [:add, :mul], [1, 2]

puts '(((1 + 5) + 1) * 10) * 2 = ' + multia.weave(1, multib).to_s

sima = Complect.new [:addOne, :addOne]
puts '5 + 1 + 1 = ' + sima.run(5).to_s

simb = Complect.new [:mulTwo, :mulTwo]
puts '((5 * 2) + 1) * 2) + 1) = ' + simb.weave(5, sima).to_s

print 'With info: '
print ' = ', simb.weave_with(5, sima) { |state, opA, opB|
  print " (#{state}) #{opA.name} #{opB.name}"
  state
}
