@echo off

SET PYTHONPATH=c:\python25;
python -m cProfile -s cumulative ack.py > profile-ack.txt
