class BidirectionalMapping
  include Enumerable
  
  def initialize
    @forwardMap = {}
    @backwardMap = {}
  end
  
  def add(a, b)
    @backwardMap.delete @forwardMap[a] if @forwardMap.has_key?(a)
    @forwardMap[a] = b
    @backwardMap[b] = a
  end
  
  def forward_lookup(a)
    @forwardMap[a]
  end
  
  def backward_lookup(b)
    @backwardMap[b]
  end
  
  def [](x)
    @forwardMap.has_key?(x) ? @forwardMap[x] : @backwardMap[x]
  end
  
  def each(&block)
    @forwardMap.each(&block)
  end
end
