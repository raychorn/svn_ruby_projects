class Array
  def random
    at(rand(length))
  end
  
  def randomize
    tmp = clone
    returning randomized_array = [] do
      until tmp.empty?
        randomized_array << tmp.delete_at(rand(tmp.length))
      end
    end
  end
end

class Hash
  def map_values
    returning h = {} do
      each do |k, v|
        h[k] = yield k, v
      end
    end
  end
end

class Range
  def random
    first + rand(last - first)
  end
end

class Symbol
  def to_proc 
    Proc.new { |*args| args.shift.__send__(self, *args) } 
  end
end

module Enumerable
  def sum
    inject(0) { |sum, value| sum + value }
  end

  def to_h
    returning h = {} do
      each do |v|
        h[v] = yield v
      end
    end
  end
end

def returning(value)
  yield value
  value
end
