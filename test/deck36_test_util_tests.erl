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

-module(deck36_test_util_tests).

-include_lib("eunit/include/eunit.hrl").

-export([]).

%% Test unmock/1
%% ====================================================================
unmock_1_test_() ->
	R0 = deck36_test_util:unmock(deck36_time),
	ok = meck:new(deck36_time, []),
	ok = meck:expect(deck36_time, readable, fun(_) -> "Nope" end),
	R1 = deck36_time:readable({{2000,1,2},{3,4,5}}),
	deck36_test_util:unmock(deck36_time),
	R2 = deck36_time:readable({{2000,1,2},{3,4,5}}),
	[
	 {"Unmocked before", ?_assertEqual(ok, R0)},
	 {"Mocked", ?_assertEqual("Nope", R1)},
	 {"Unmocked", ?_assertEqual("2000-01-02 03:04:05", R2)}
	].


%% Test rcv/1
%% ====================================================================
rcv_1_test_() ->
	R1 = deck36_test_util:rcv(10),
	self() ! test,
	R2 = deck36_test_util:rcv(10),
	R3 = deck36_test_util:rcv(10),
	[
	 {"Before sending", ?_assertEqual({error, timeout}, R1)},
	 {"After sending", ?_assertEqual(test, R2)},
	 {"After receiving", ?_assertEqual({error, timeout}, R3)}
	].

%% Test wait_for_stop/2
%% ====================================================================
wait_for_stop_2_unnamed_ok_test() ->
	Pid = proc_lib:spawn(fun() -> timer:sleep(10) end),
	?assertEqual(ok, deck36_test_util:wait_for_stop(Pid, 20)).

wait_for_stop_2_unnamed_timeout_test() ->
	Pid = proc_lib:spawn(fun() -> timer:sleep(20) end),
	?assertEqual({error, timeout}, deck36_test_util:wait_for_stop(Pid, 5)).
	
wait_for_stop_2_named_ok_test() ->
	Pid = proc_lib:spawn(fun() -> timer:sleep(10) end),
	Name = deck36_test_util_proc_1,
	register(Name, Pid),
	?assertEqual(ok, deck36_test_util:wait_for_stop(Name, 20)).

wait_for_stop_2_named_timeout_test() ->
	Pid = proc_lib:spawn(fun() -> timer:sleep(20) end),
	Name = deck36_test_util_proc_2,
	register(Name, Pid),
	?assertEqual({error, timeout}, deck36_test_util:wait_for_stop(Name, 5)).

wait_for_stop_2_named_not_started_test() ->
	Name = deck36_test_util_proc_3,
	?assertEqual(ok, deck36_test_util:wait_for_stop(Name, 5)).


%% Test fetch_ets/3
%% ====================================================================
fetch_ets_3_test_() ->
	{setup,
	 fun() ->
			 Tab = ets:new(deck36_test_util_test_fetch_ets, [public, named_table]),
			 ets:insert(Tab, {test_2, test_value}),
			 Tab
	 end,
	 fun(Tab) ->
			 ets:delete(Tab)
	 end,
	 fun(Tab) ->
			 [
			  {"timeout", ?_assertEqual({error, timeout}, deck36_test_util:fetch_ets(Tab, test_1, 5))},
			  {"found", ?_assertEqual({ok, {test_2, test_value}}, deck36_test_util:fetch_ets(Tab, test_2, 10))}
			 ]
	 end}.
			 

%% Test expect_ets/4
%% ====================================================================
expect_ets_4_test_() ->
	{setup,
	 fun() ->
			 Tab = ets:new(deck36_test_util_test_ets, [public, named_table]),
			 Tab
	 end,
	 fun(Tab) ->
			 ets:delete(Tab)
	 end,
	 fun(Tab) ->
			 [
			  {"timeout", ?_assertEqual({error, timeout}, deck36_test_util:expect_ets(Tab, test_1, test_2, 5))},
			  {"ok with fun", fun() -> test_expect_ets_4_match_fun_ok(Tab) end},
			  {"unexpected with fun", fun() -> test_expect_ets_4_match_fun_unexpected(Tab) end},
			  {"ok with term", fun() -> test_expect_ets_4_match_term_ok(Tab) end},
			  {"unexpected with term", fun() -> test_expect_ets_4_match_term_unexpected(Tab) end}
			 ]
	 end}.

test_expect_ets_4_match_fun_ok(Tab) ->
	ets:insert(Tab, {test_3, test_4}),
	Fun = fun(test_4) -> true;
			 (_) -> false end,
	?assertEqual(ok, deck36_test_util:expect_ets(Tab, test_3, Fun, 10)).
	
test_expect_ets_4_match_fun_unexpected(Tab) ->
	ets:insert(Tab, {test_5, test_6}),
	Fun = fun(test_4) -> true;
			 (_) -> false end,
	?assertEqual({unexpected, {test_5, test_6}}, deck36_test_util:expect_ets(Tab, test_5, Fun, 10)).

test_expect_ets_4_match_term_ok(Tab) ->
	ets:insert(Tab, {test_7, test_8}),
	?assertEqual(ok, deck36_test_util:expect_ets(Tab, test_7, test_8, 10)).

test_expect_ets_4_match_term_unexpected(Tab) ->
	ets:insert(Tab, {test_9, test_10}),
	?assertEqual({unexpected, {test_9, test_10}}, deck36_test_util:expect_ets(Tab, test_9, test_8, 10)).

%% ====================================================================
%% Internal functions
%% ====================================================================


