-module(test).
-export([starter/0]).

starter() ->
    Server = spawn(taskOne, serverStart, []),
    _Client1 = spawn(taskOne, clientStart, 
                [Server, "The quick brown fox jumped over the lazy dog."]),
    _Client2 = spawn(taskOne, clientStart, 
                [Server, "Contrary to popular belief, Lorem Ipsum is not simply random text."]).