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
	            io:fwrite("Second stage complete.~n"),
	            server:serverEstablished(Client, IncServerSeq, IncClientSeq, "", 0),
		    receive
		    	{Client, {ack, IncServerSeq, IncClientSeq, String}} ->
		        	io:fwrite("DID IT MATCH?~n"),
		         	server:serverEstablished(Client, IncServerSeq, IncClientSeq, String, 0),
		         	io:fwrite("Final stage complete.~n"),
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
    		io:fwrite("Sent Ack Message.~n"),
    		clientStart(Server, String, IncClientSeq, IncServerSeq)
    end.


clientStart(Server, [], IncClientSeq, IncServerSeq) ->
	io:fwrite("GOT ONTO SECOND PART HELLL YEAAAAA!!!!~n"),
	Server ! {self(), {fin, IncClientSeq, IncServerSeq}},
	io:fwrite("Client done.~n");
clientStart(Server, String, IncClientSeq, IncServerSeq) ->
	Server ! {self(), {ack, IncClientSeq, IncServerSeq, string:sub_string(String, 1, 7)}},
	% io:fwrite(string:sub_string(String, 1, 7)),
	io:fwrite("IS THIS WORKING?~n"),
	io:format("Client: ~p, Server: ~p~n", [IncClientSeq, IncServerSeq]),
	receive
		{Server, {ack, NewClientSeq, IncServerSeq}} ->
			clientStart(Server, string:sub_string(String, 8), NewClientSeq, IncServerSeq)
	end.

