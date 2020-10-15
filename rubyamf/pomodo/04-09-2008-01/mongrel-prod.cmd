REM %1 is the IP
REM %2 is the port

setlocal

if %1. == . goto error1
if %2. == . goto error2
goto okay
:error1
:error2
mongrel_rails start -e production -a localhost -p 3000 -P tmp/pids/mongrel_3000.pid -l log/mongrel_3000.log

goto exit

:okay
mongrel_rails start -e production -a %1 -p %2 -P tmp/pids/mongrel_%2.pid -l log/mongrel_%2.log

goto exit

:exit

endlocal