import sys

def Ack(M, N):
    if (not M):
        return N+1
    if (not N):
        return Ack(M-1, 1)
    return Ack(M-1, Ack(M, N-1))

# 3, 9
# 2, 3,8
# 1, 3,7
# 
# M-1, M,N-1

def fib(m):
    a, b = 0, 1
    while b < m:
        yield b
        a, b = b, a+b

def main():
    NUM = 9
    Ack(3, NUM)
        
def main2():
    for num in fib(1000000):
        print num

main()
