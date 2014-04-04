%% ====================================================================
%%
%% Copyright (c) DECK36 GmbH & Co. KG, Burchardstraße 21, 20095 Hamburg/Germany and individual contributors.
%% All rights reserved.
%% 
%% Redistribution and use in source and binary forms, with or without modification,
%% are permitted provided that the following conditions are met:
%% 
%%     1. Redistributions of source code must retain the above copyright notice,
%%        this list of conditions and the following disclaimer.
%% 
%%     2. Redistributions in binary form must reproduce the above copyright
%%        notice, this list of conditions and the following disclaimer in the
%%        documentation and/or other materials provided with the distribution.
%% 
%%     3. Neither the name of DECK36 GmbH & Co. KG nor the names of its contributors may be used
%%        to endorse or promote products derived from this software without
%%        specific prior written permission.
%% 
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
%% ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
%% ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%
%% ====================================================================
%%
%% @author Bjoern Kortuemm (@uuid0) <bjoern.kortuemm@deck36.de>

-module(deck36_inet_tests).

-include_lib("eunit/include/eunit.hrl").
-include("deck36_common.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).

-define(N(X), lists:flatten(io_lib:format("~p", [X]))).


%% Test deck36_inet:ntoa/1
%% ====================================================================
ntoa_test_() ->
	OK = fun(X) -> deck36_inet:is_ip_address_str(X) end,
	[
	 [{"ok " ++ ?N(X), ?_assert(OK(deck36_inet:ntoa(X)))} || X <- addrs(tuple, valid)],
	 [{"error " ++ ?N(X), ?_assertEqual({error, einval}, deck36_inet:ntoa(X))} || X <- addrs(tuple, invalid)]
	].
	 

%% Test deck36_inet:port_number/1
%% ====================================================================
port_number_test_() ->
	OK = [{0,0}, {1,1}, {65535,65535},
		  {"0",0}, {"1",1}, {"65535",65535},
		  {<<"0">>,0}, {<<"1">>,1}, {<<"65535">>,65535}],
	Einval = [-1, 65536, <<"-1">>, "-1"],
	EFC = ['1', {1}],
	Ebadarg = [[1]],
	[
	 [{"ok " ++ ?N(X), ?_assertEqual(E, deck36_inet:port_number(X))} || {X,E} <- OK],
	 [{"error einval " ++ ?N(X), ?_assertError(einval, deck36_inet:port_number(X))} || X <- Einval],
	 [{"error function_clause" ++ ?N(X), ?_assertException(error, function_clause, deck36_inet:port_number(X))} || X <- EFC],
	 [{"error badarg" ++ ?N(X), ?_assertException(error, badarg, deck36_inet:port_number(X))} || X <- Ebadarg]
	].


%% Test deck36_inet:is_ip_address_str/1
%% ====================================================================
is_ip_address_str_test_() ->
	[
	 {"+ <<\"1.2.3.4\">>", ?_assertEqual(true, deck36_inet:is_ip_address_str(<<"1.2.3.4">>))},
	 [{"+ \"" ++ X ++ "\"", ?_assertEqual(true, deck36_inet:is_ip_address_str(X))} || X <- addrs(str, valid)],
	 [{"- \"" ++ X ++ "\"", ?_assertEqual(false, deck36_inet:is_ip_address_str(X))} || X <- addrs(str, invalid)],
	 {"- 123", ?_assertEqual(false, deck36_inet:is_ip_address_str(123))},
	 {"- '123'", ?_assertEqual(false, deck36_inet:is_ip_address_str('123'))}
	].


%% Test deck36_inet:is_ip_address_tuple/1
%% ====================================================================
is_ip_address_tuple_test_() ->
	[
	 [{"+ " ++ ?N(X), ?_assertEqual(true, deck36_inet:is_ip_address_tuple(X))} || X <- addrs(tuple, valid)],
	 [{"- " ++ ?N(X), ?_assertEqual(false, deck36_inet:is_ip_address_tuple(X))} || X <- addrs(tuple, invalid)],
	 {"- 'ip'", ?_assertEqual(false, deck36_inet:is_ip_address_tuple(ip))},
	 {"- \"0.0.0.0\"", ?_assertEqual(false, deck36_inet:is_ip_address_tuple("0.0.0.0"))},
	 {"- badarg {1,2,3,4.0}}", ?_assertEqual(false, deck36_inet:is_ip_address_tuple({1,2,3,4.0}))}
	].


%% Test deck36_inet:is_ip_address/1
%% ====================================================================
is_ip_address_test_() ->
	[
	 {"+ <<\"1.2.3.4\">>", ?_assertEqual(true, deck36_inet:is_ip_address(<<"1.2.3.4">>))},
	 [{"+ \"" ++ X ++ "\"", ?_assertEqual(true, deck36_inet:is_ip_address(X))} || X <- addrs(str, valid)],
	 [{"+ " ++ ?N(X), ?_assertEqual(true, deck36_inet:is_ip_address(X))} || X <- addrs(tuple, valid)],
	 [{"- \"" ++ X ++ "\"", ?_assertEqual(false, deck36_inet:is_ip_address(X))} || X <- addrs(str, invalid)],
	 [{"- " ++ ?N(X), ?_assertEqual(false, deck36_inet:is_ip_address(X))} || X <- addrs(tuple, invalid)],
	 {"- 123", ?_assertEqual(false, deck36_inet:is_ip_address(123))},
	 {"- '123'", ?_assertEqual(false, deck36_inet:is_ip_address('123'))}
	].


%% Test deck36_inet:is_port_number/1
%% ====================================================================
is_port_number_test_() ->
	True = [0, 1, 65535],
	False = [-1, '1', "1", <<"1">>, {1}, [1]],
	[
	 [{"+ " ++ ?N(X), ?_assertEqual(true, deck36_inet:is_port_number(X))} || X <- True],  
	 [{"- " ++ ?N(X), ?_assertEqual(false, deck36_inet:is_port_number(X))} || X <- False]
	].

%% ====================================================================
%% Internal functions
%% ====================================================================

%% addrs/2
%% ====================================================================
%% @doc Return IP addresses in string or tuple format, valid or invalid.
%% ====================================================================
addrs(str, valid) ->
	["1.2.3.4", "0.0.0.0", "255.255.255.255", "256", "1.2.3", "1.2", "0x256", "0x10.2.3.4",
	 "::1", "::", "beef::15de:adca:7f00:d700", "c01d:c0ff:eeb0:0575:ca7f:ace5:a5ef:fec7"];
addrs(str, invalid) ->
	["-1.2.3.4", "256.255.255.255", "::-1", "c0ds:a1ad",
	 "5ca1:ab1e:8a77:1eca:75ac:edee:17ac::71c5"];
addrs(tuple, valid) ->
	[{0,0,0,0}, {1,2,3,4}, {255,255,255,255}, {0,0,0,0,0,0,0,0}, {65535,1,2,3,4,5,6,7}];
addrs(tuple, invalid) ->
	[{-1,0,0,0}, {1,2,3,4,5}, {256,0,0,0}, {65536,1,2,3,4,5,6,7}].



