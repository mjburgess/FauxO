# T
class Action
  # a -> T a
  def initialize(action)
    @container = action
  end

  # a -> T a
  def container
    lambda do |action|
      Action.new action
    end
  end

  def self.empty
    raise NotImplementedError
  end

  # <T a> -> (a -> T b) -> T b
  # take the action of current action,
  # and derive a new action from it
  def derive(&a_to_tb)
    a_to_tb.call(@container)
  end


  # (a -> b) -> <T a> -> T b
  # get the action's action (pure)
  def get(&a_to_b)
    Action.new a_to_b.call(@container)
  end

  # change the action's action (impure)
  def update!(&a_to_b)
    @container = a_to_b.call(@container)
    self
  end

  # <T T a> -> T a
  # if the action's action is itself a action
  # this will unpack the innter action and use its action (impure)
  def unpack!
    @container = @container.container
  end

  #if the action's action is itself a action
  #this will unpack the inner action and use its action (pure)
  def unpack
    Action.new @container.container
  end
end

class WriteAction < Action
  # i -> T i
  def initialize(action)
    super
  end

  def self.from_writable(writable)
    WriteAction.new(lambda {|str| writable.write(str) })
  end

  def self.empty
    WriteAction.new(lambda {|str| puts str })
  end

  # (a -> b) -> Action a
  def write(&str_provider)
    super.update! do |writer|
      writer.call(str_provider.call)
    end

    self
  end
end