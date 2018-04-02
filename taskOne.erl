-module(taskOne).
-export([serverStart/0, clientStart/2, clientStart/4, increment/1]).


increment(X) ->
	X + 1.


serverStart() -> 
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
		         	server:serverEstablished(Client, IncServerSeq, IncClientSeq, String, 0),
		         	serverStart()
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
	if (length(String) > 7) ->
		Server ! {self(), {ack, IncClientSeq, IncServerSeq, string:sub_string(String, 1, 7)}},
		receive
			{Server, {ack, IncServerSeq, NewClientSeq}} ->
				clientStart(Server, string:sub_string(String, 8), NewClientSeq, IncServerSeq)
		end;
	true ->
		clientStart(Server, [], IncClientSeq, IncServerSeq)
	end.







