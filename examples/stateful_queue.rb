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

dependent_a = Complect.new [:add, :mul], [5, 10]
dependent_b = Complect.new [:add, :mul], [1, 2]

puts 'dA'
print '(((1 + 5) + 1) * 10) * 2 = '
puts dependent_a.weave(1, dependent_b)

puts 'dB'
print '(5 + 5) * 10 = '
puts dependent_a.run(5)


free_a = Complect.new [:addOne, :addOne]
free_b = Complect.new [:mulTwo, :mulTwo]

puts 'fA'
print '((5 * 2) + 1) * 2) + 1) = '
puts free_b.weave(5, free_a)

puts 'fB'
print '5 + 1 + 1 = '
puts free_a.run(5)


