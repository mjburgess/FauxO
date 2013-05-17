# T
class Action
  attr_reader :applicable

  # a -> T a
  def initialize(action)
    @applicable = action
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
    a_to_tb.call(@applicable)
  end


  # (a -> b) -> <T a> -> T b
  # get the action's action (pure)
  def get(&a_to_b)
    Action.new a_to_b.call(@applicable)
  end

  # <T a> -> <T b>
  # change the action's action (impure)
  def update!(&a_to_b)
    @applicable = a_to_b.call(@applicable)
    self
  end

  # <T T a> -> T a
  # if the action's action is itself a action
  # this will unpack the innter action and use its action (impure)
  def unpack!
    @applicable = @applicable.container
  end

  #if the action's action is itself a action
  #this will unpack the inner action and use its action (pure)
  def unpack
    Action.new @applicable.container
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

class ActionList < Action
  def initialize(actions, dependencies = nil)
    @applicable = actions.map { |m|
      if m.is_a? Symbol
        method(m)
      else
        m
      end
    }

    @applicable = @applicable.zip(dependencies) unless dependencies.nil?
    @dependent  = !dependencies.nil?
  end

  def dependent?
    @dependent
  end
end

class Complect < ActionList
  def run(input)
    if dependent?
      simplex(input) { |state, action|
        action, dep = action
        action.call *dep, state
      }
    else
      simplex(input) { |state, action|
        action.call state
      }
    end
  end

  def run_with(input, &strand)
    if dependent?
      simplex(input) { |state, action|
        action, dep = action
        action.call *d, (strand.call state, action, dep)
      }
    else
      simplex(input) { |state, action|
        action.call (strand.call state, action)
      }
    end
  end

  def weave(input, couple)
    case [self.dependent?, couple.dependent?]
      when [true, true] then complex(input, couple) { |state, actions|
        f, fd, g, gd = actions.flatten
        f.call *(g.call state, *gd), *fd
      }

      when [false, true] then complex(input, couple) { |state, actions|
        f, g, gd = actions.flatten
        f.call *(g.call state, *gd)
      }

      when [true, false] then complex(input, couple) { |state, actions|
        f, g, gd = actions.flatten
        f.call *(g.call state, *gd)
      }
      when [false, false] then complex(input, couple)  { |state, actions|
        f, g = actions
        f.call *(g.call state)
      }
    end
  end

  def weave_with(input, couple, &strand)
    case [self.dependent?, couple.dependent?]
      when [true, true] then complex(input, couple) { |state, actions|
        f, fd, g, gd = actions.flatten
        f.call *(g.call (strand.call(state, g, gd, f, fd)), *gd) *fd
      }

      when [false, true] then complex(input, couple) { |state, actions|
        f, g, gd = actions.flatten
        f.call *(g.call (strand.call(state, g, f, gd))), *fd
      }

      when [true, false] then complex(input, couple) { |state, actions|
        f, g, gd = actions.flatten
        f.call *(g.call (strand.call(state, g, f, gd))), *fd
      }
      when [false, false] then complex(input, couple)  { |state, actions|
        f, g = actions
        f.call *(g.call (strand.call(state, g, f)))
      }
    end
  end

  def complex(state, couple, &combination)
    couple.applicable.zip(@applicable).inject(state, &combination)
  end

  def simplex(state, &combination)
    @applicable.inject(state, &combination)
  end
end

class Couple < ActionList
  def self.weave(list_one, list_two)
    (Couple.new list_one).weave(Couple.new list_two)
  end

  def self.repeating(action, deps)
    Couple.new Array.new(deps.length, action), deps
  end

  def run
    if dependent?
      apply() { |action|
        action, dep = action
        action.call *dep
      }
    else
      apply() { |action|
        action.call
      }
    end
  end

  def run_with(&strand)
    if dependent?
      apply { |action|
        action, dep = action
        action.call *d, (strand.call action, dep)
      }
    else
      apply { |action|
        action.call (strand.call state, action)
      }
    end
  end


  def weave(couple)
    case [self.dependent?, couple.dependent?]
      when [true, true] then coapply(couple) { |actions|
        f, fd, g, gd = actions.flatten
        f.call *(g.call *gd), *fd
      }

      when [false, true] then coapply(couple) { |actions|
        f, g, gd = actions.flatten
        f.call *(g.call *gd)
      }

      when [true, false] then coapply(couple) { |actions|
        f, g, gd = actions.flatten
        f.call *(g.call *gd)
      }
      when [false, false] then coapply(couple)  { |actions|
        f, g = actions.flatten
        f.call *(g.call)
      }
    end
  end

  def weave_with(couple, &strand)
    case [self.dependent?, couple.dependent?]
      when [true, true] then coapply(couple) { |actions|
        f, fd, g, gd = actions.flatten
        f.call *(g.call (strand.call(g, gd, f, fd)), *gd, *fd)
      }

      when [false, true] then coapply(couple) { |actions|
        f, g, gd = actions.flatten
        f.call *(g.call (strand.call(g, f, gd)), *fd)
      }

      when [true, false] then coapply(couple) { |actions|
        f, g, gd = actions.flatten
        f.call *(g.call (strand.call(g, f, gd)), *fd)
      }
      when [false, false] then coapply(couple)  { |actions|
        f, g = actions.flatten
        f.call *(g.call (strand.call(g, f)))
      }
    end
  end

  def coapply(couple, &combination)
    couple.applicable.zip(@applicable).map(&combination)
  end

  def apply(&combination)
    @applicable.map(&combination)
  end
end

