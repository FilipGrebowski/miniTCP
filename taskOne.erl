-module(taskOne).
-export([serverStart/0, clientStart/2, clientStart/4, increment/1, testOne/0]).


increment(X) -> X + 1.

serverStart() -> serverStart(0).
serverStart(ServerSeq) -> 
    receive
        {Client, {syn, ServerSeq, ClientSeq}} -> 
        	IncClientSeq = increment(ClientSeq),
            Client ! {self(), {synack, ServerSeq, IncClientSeq}},
        receive
	        {Client, {ack, IncServerSeq, IncClientSeq}} -> 
	            server:serverEstablished(Client, IncServerSeq, IncClientSeq, "", 0),
	            serverStart(),
		    receive
		    	{Client, {ack, IncServerSeq, IncClientSeq, String}} ->
		         	server:serverEstablished(Client, IncServerSeq, IncClientSeq, String, 0)
		    end
		end
    end.

clientStart(Server, String) ->
	ClientSeq = 0,
	ServerSeq = 0,
    Server ! {self(), {syn, ClientSeq, ServerSeq}},
    receive
    	{Server, {synack, ServerSeq, IncClientSeq}} ->
    		IncServerSeq = increment(ServerSeq),
    		Server ! {self(), {ack, IncClientSeq, IncServerSeq}},
    		clientStart(Server, String, IncClientSeq, IncServerSeq)
    end.


clientStart(Server, [], IncClientSeq, IncServerSeq) ->
	Server ! {self(), {fin, IncClientSeq, IncServerSeq}},
	io:fwrite("Client done.~n");

clientStart(Server, String, IncClientSeq, IncServerSeq) ->
	if (length(String) == 0) ->
		String = [],
		clientStart(Server, [], IncClientSeq, IncServerSeq);
	true ->
		Substring = string:sub_string(String, 1, 7),
		RestOfString = string:sub_string(String, (length(Substring) + 1)),
		Server ! {self(), {ack, IncClientSeq, IncServerSeq, Substring}},
		receive
			{Server, {ack, IncServerSeq, NewClientSeq}} ->
					clientStart(Server, RestOfString, NewClientSeq, IncServerSeq)
		end
	end.

% Questions 3:
% The way the tcpMonitorStart forwards packets between the Server and the Client
% is by checking the process id of the sender, making sure the connection has been acknowledged,
% and then proceeding to sending the packet to the destination where that current
% process id exists.

% Question 4:
testOne() ->
  	Monitor = spawn(monitor, tcpMonitorStart, []),
  	Server = spawn(taskOne, serverStart, []),
  	Client = spawn(taskOne, clientStart, [Monitor, "Small piece of text"]),
  	Monitor ! {Client, Server}.


