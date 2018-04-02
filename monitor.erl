-module(monitor).
-export([tcpMonitorStart/0, debug/3]).

tcpMonitorStart() ->
    % Wait to be sent the address of the client and the address 
    % of the server that I will be monitoring traffice between.
    receive 
        {Client, Server} -> tcpMonitor(Client, Server)
    end.

tcpMonitor(Client, Server) ->
    receive 
        {Client, TCP} -> Server!{self(), TCP}, debug(Client, Client, TCP);
        {Server, TCP} -> Client!{self(), TCP}, debug(Client, Server, TCP)
    end,
    tcpMonitor(Client, Server).

debug(Client, P, TCP) ->
    case P == Client of
        true -> io:fwrite("---> {Client, ~p}~n", [TCP]);
        false -> io:fwrite("<--- {Server, ~p)~n", [TCP])
    end.