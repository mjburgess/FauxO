module ShowVariable
  def shows(*args)
    define_method :show do
      args.each do |a|
          self.send(a).get do |state|
          puts state
        end
      end
    end
  end
end

# T
class Variable
  # a -> T a
  def initialize(state)
    @container = state
  end

  # <T a> -> IO ()
  def show
    puts @container
  end

  # a -> T a
  def container
    lambda do |state|
      Variable.new state
    end
  end

  def self.empty
    raise NotImplementedError
  end

  # <T a> -> (a -> T b) -> T b
  # take the state of current variable,
  # and derive a new variable from it
  def derive(&a_to_tb)
    a_to_tb.call(@container)
  end


  # (a -> b) -> <T a> -> T b
  # access the variable's state (pure)
  def get(&a_to_b)
    Variable.new a_to_b.call(@container)
  end

  # change the variable's state (impure)
  def update!(&a_to_b)
    @container = a_to_b.call(@container)
    self
  end

  # <T T a> -> T a
  # if the variable's state is itself a variable
  # this will unpack the innter variable and use its state (impure)
  def unpack!
    @container = @container.container
  end

  #if the variable's state is itself a variable
  #this will unpack the inner variable and use its state (pure)
  def unpack
    Variable.new @container.container
  end
end

class IntVariable < Variable
  # i -> T i
  def initialize(state)
    super
  end

  # T i -> T s
  def format(fmt)
    StrVariable.new sprintf(fmt, @container)
  end

  def self.empty
    IntVariable.new 0
  end
end

class StrVariable < Variable
  # s -> T s
  def initialize(state)
    super
  end

  def self.empty
    StrVariable.new ''
  end

  def from_int(int)
    StrVariable.new "#{int}"
  end
end