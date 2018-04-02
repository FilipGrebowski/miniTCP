-module(server).
-export([serverEstablished/5]).

-spec serverEstablished(pid(), integer(), integer(), string(), integer()) -> integer().

serverEstablished(Client, ServerSeq, ClientSeq, CollectedData, NumPackets) ->
	io:fwrite("You reached the function.~n"),
    receive
        {Client, {fin, ClientSeq, ServerSeq}} ->
            % received a 'fin' packet
            % response with an 'ack' (passive close)
            Client ! {self(), {ack, ServerSeq, ClientSeq}},
            % Output the data
            io:fwrite("Data: ~p~n", [CollectedData]),
            % Output a debug message
            io:fwrite("Dbg: Server seq: ~w, Client seq: ~w~n", [ServerSeq, ClientSeq]),
            io:fwrite("Dbg: Num packets received by the server: ~w~n", [NumPackets]),
            % Return the final server sequence number
            ServerSeq;

        {Client, {ack, ClientSeq, ServerSeq, Data}} ->
        	f:write("KEEP GOING FILIP YOU ARE THE FUCKING BEST!"),
            % Received an 'ack' packet with data
            Client ! {self(), {ack, ServerSeq, ClientSeq + length(Data)}},
            % Send an 'ack' packet (no data)
            % Go back to the main loop
            serverEstablished(Client, ServerSeq, ClientSeq + length(Data), CollectedData ++ Data, NumPackets + 1)
    end.

