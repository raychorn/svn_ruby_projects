def ack(m, n)
    if m == 0 then
        n + 1
    elsif n == 0 then
        ack(m - 1, 1)
    else
        ack(m - 1, ack(m, n - 1))
    end
end

NUM = 9

require 'benchmark'

Benchmark.bm(8) do |x|
  n   = 1

  x.report('ack:') { n.times { ack(3, NUM) } }

end
