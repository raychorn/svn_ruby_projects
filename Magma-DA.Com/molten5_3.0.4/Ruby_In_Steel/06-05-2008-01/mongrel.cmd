SET MONGREL_IP=127.0.0.1
SET MONGREL_PORT=8000
SET MONGREL_ENV=development
SET MONGREL_PATH=Z:/Ruby Projects/molten5/

REM mongrel_rails mongrel::start -e %MONGREL_ENV% -a %MONGREL_IP% -p %MONGREL_PORT% -n 1024 -P %MONGREL_PATH%tmp/pids/mongrel_%MONGREL_PORT%.pid -l %MONGREL_PATH%log/mongrel_%MONGREL_PORT%.log

mongrel_rails mongrel::start -a %MONGREL_IP% -p %MONGREL_PORT% -n 1024 -P %MONGREL_PATH%tmp/pids/mongrel_%MONGREL_PORT%.pid -l %MONGREL_PATH%log/mongrel_%MONGREL_PORT%.log
