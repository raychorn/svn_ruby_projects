@echo off

SET PYTHONPATH=c:\python25;Z:\python projects\@lib;
python -m cProfile -s cumulative ack_tail.py > profile-ack_tail.txt
