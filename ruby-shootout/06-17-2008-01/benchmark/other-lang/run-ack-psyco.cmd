@echo off

SET PYTHONPATH=c:\python25;Z:\python projects\@lib;
python -m cProfile -s cumulative ack_psyco.py > profile-ack_psyco.txt
