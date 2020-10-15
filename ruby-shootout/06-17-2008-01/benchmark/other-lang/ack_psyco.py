import ack
from vyperlogix import _psyco

def main():
    ack.main()
    
if (__name__ == '__main__'):
    _psyco.importPsycoIfPossible()
    main()
    