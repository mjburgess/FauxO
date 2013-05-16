# T
class Optional
  # a -> T a
  def initialize(state)
    @container = state
  end

  # a -> T a
  def container
    lambda do |state|
      Optional.new state
    end
  end

  def self.empty
    Optional.new nil
  end

  # <T a> -> (a -> T b) -> T b
  # take the state of current optional,
  # and derive a new optional from it
  def derive(&a_to_tb)
    a_to_tb.call(@container)
  end


  # (a -> b) -> <T a> -> T b
  # access the optional's state (pure)
  def get(&a_to_b)
    if @container.nil?
      Optional.empty
    else
      Optional.new a_to_b.call(@container)
    end
  end

  def getOr(default, &a_to_b)
    if @container.nil?
      Optional.new a_to_b.call(default)
    else
      Optional.new a_to_b.call(@container)
    end
  end

  # change the optional's state (impure)
  def update!(&a_to_b)
    @container = a_to_b.call(@container) unless @container.nil?
    self
  end

  # <T T a> -> T a
  # if the optional's state is itself a optional
  # this will unpack the inner optional and use its state (impure)
  def unpack!
    @container = @container.container
  end

  #if the optional's state is itself a optional
  #this will unpack the inner optional and use its state (pure)
  def unpack
    Optional.new @container.container
  end
end

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