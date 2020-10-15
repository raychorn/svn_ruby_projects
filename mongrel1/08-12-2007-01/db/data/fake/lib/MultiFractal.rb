module MultiFractal
  class MultiPointLine
    def initialize(array)
      @points = array
    end
    
    def scale(factor)
      self.class.new(@points.map { |i| i * factor })
    end
    
    def to_a(nPoints = nil)
      nPoints ||= @points.length
      nPoints -= 1
      (0..nPoints).map { |i| self[Float(i) / nPoints]}
    end
    
    def [](position)
      raise RangeError.new('Index must be a value between 0.0 and 1.0, inclusive.') \
        unless position >= 0.0 && position <= 1.0
      
      return @points[0] if position == 0.0
      return @points[@points.length - 1] if position == 1.0
      
      count = @points.length - 1
      
      pos = position * count
      idx = pos.floor
      left = @points[idx]
      right = @points[idx + 1]
      slope = right - left
      
      left + (pos - idx) * slope
    end
    
    def integral
      (0..@points.length-2).inject { |sum, i| sum + @points[i] + (@points[i + 1] - @points[i]) / 2 }
    end
  end
  
  class Generator
    attr_reader :series, :line
    
    def initialize(count, start_value, end_value, max_value, min_value)
      yMiniSeries = makeMiniSeries(8, 0.0, 0.0, -0.2, 0.2)
      xMiniSeries = makeMiniSeries(8, 1.0, 1.0, 0.3, 1.7)
      startSeries = makeMiniSeries(5, start_value, end_value, max_value, min_value)
      n = 5
      while n < count
        n = [count, n * 5].min
        series = makeFractalSeries(n, startSeries, yMiniSeries, 5, 5.0 / n)
      end
      #series = makeFractalSeries(125, series, yMiniSeries, 5, 0.2)
      #series = makeFractalSeries(625, series, yMiniSeries, 5, 0.02)

      # Should fractal-expand xMiniSeries
      series = fractalTimeScale(count, series, xMiniSeries)
      
      #puts startSeries.inspect
      #puts yMiniSeries.inspect
      @line = series
      @series = series.to_a
    end
    
    def makeMiniSeries(count, start_value, end_value, min, max)
      MultiPointLine.new([start_value] + ((1..count-1).map { min + rand * (max-min) }) + [end_value])
    end
    
    def makeFractalSeries(count, protoLine, fractalLine, multiplier, fracScale=1.0,
                          min=0, max=100)
      MultiPointLine.new((0..count-1).map do |i|
        frac_pos = i % multiplier / Float(multiplier)
        [min, [max, protoLine[Float(i) / count] * (1.0 + fracScale * fractalLine[frac_pos])].min].max
      end)
    end
    
    def fractalTimeScale(count, line, fractalLine)
      xScale = fractalLine.integral * count
      pos = 0.0
      MultiPointLine.new((0..count-1).map do |i|
        p = pos
        pos += fractalLine[Float(i) / count] / xScale
        line[p]
      end)
    end
  end
end

def test
  s = MultiFractal::Generator.new(625, 50+rand*50, 50+rand*50, 0, 100).series
  puts s.inspect
end
