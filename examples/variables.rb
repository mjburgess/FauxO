require_relative '../variable'

# i -> i
def adder(num)
  lambda do |state|
    state + num
  end
end

def add(x, y)
  x + y
end

def add_variables(va, vb)
  if va.is_a? IntVariable and vb.is_a? IntVariable
    va.get do |a|
      return vb.get do |b|
        add(a, b)
      end
    end
  else
    va.empty
  end
end
ta = IntVariable.new 10

ta.update!(&adder(10)).update do |state|
  state**2
end.show


ta.show

ta.derive do |state|
  StrVariable.new "I have #{state} points"
end.show

add_variables(IntVariable.new(10), IntVariable.new(20)).show
