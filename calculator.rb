require_relative 'variable.rb'

class Calculator
  def add(x, y)
    x + y
  end

  def sub(x, y)
    x - y
  end
end

class CalculatorGraft
  extend ShowVariable

  attr_reader :var
  shows :var

  def initialize(calc)
    @var = IntVariable.empty
    @calc = calc
  end

  def method_missing(name, *args)
    @var.update! do |state|
      if name.to_s.end_with? '!'
        name = name.to_s.chomp '!'
        args.unshift(state)
      end

      @calc.send(name, *args)
    end
  end
end

cw = CalculatorGraft.new(Calculator.new)
cw.add(5,6)
cw.add!(10)
cw.show