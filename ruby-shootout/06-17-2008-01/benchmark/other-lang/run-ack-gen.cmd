@echo off

SET PYTHONPATH=c:\python25;
python -m cProfile -s cumulative ack_generator.py > profile-ack-gen.txt
