module Enumerable
  # [{ :a => 1, :b => 2, :c => 3}, { :a => 1, :b => 2, :c => 4}].group_to_hash do |x|
  #   [x[:a], x[:b], x[:c]]
  # end
  #
  # => { 1 => { 2 => [3, 4] } }
  def group_to_hash
    r = {}
    each do |item|
      target = r
      keys = yield item
      keys[0..-3].each do |key|
        target = (target[key] ||= {})
      end
      target[keys[-2]] ||= []
      target[keys[-2]] << keys[-1]
    end
    r
  end
  
  def each_page(page_size)
    page = []
    each do |item|
      page << item
      if page.size == page_size
        yield page
        page = []
      end
    end
    yield page unless page.empty?
    self
  end
end
