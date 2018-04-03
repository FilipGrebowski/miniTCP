-module(test).
-export([starter/0, testOne/0]).

% starter() ->
%     Server = spawn(taskOne, serverStart, []),
%     _Client1 = spawn(taskOne, clientStart, 
%                 [Server, "The quick brown fox jumped over the lazy dog."]),
%     _Client2 = spawn(taskOne, clientStart, 
%                 [Server, "Contrary to popular belief, Lorem Ipsum is not simply random text."]).

starter() ->
  Monitor1 = spawn(monitor, tcpMonitorStart, []),
  Monitor2 = spawn(monitor, tcpMonitorStart, []),
  Server = spawn(taskOne, serverStart, []),
%%  io:fwrite("SERVER CREATED"),
  _Client1 = spawn(taskOne, clientStart,
    [Monitor1, "The quick brown fox jumped over the lazy dog."]),
%%  io:fwrite("CLIENT ONE CREATED"),
  _Client2 = spawn(taskOne, clientStart,
    [Monitor2, "Contrary to popular belief, Lorem Ipsum is not simply random text."]),
  Monitor1!{_Client1,Server},
  Monitor2!{_Client2,Server}.