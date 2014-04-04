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

-module(deck36_time_tests).

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).

-include_lib("eunit/include/eunit.hrl").

-define(SHORT_FMT, "YmdHis").
-define(SHORT_FMT_PAT, [_,_,_,_,_,_,_,_,_,_,_,_,_,_]).
-define(DEFAULT_FMT_PAT, [_,_,_,_,$-,_,_,$-,_,_,32,_,_,$:,_,_,$:,_,_]).

-define(TIMESTAMP, {1379,10071,320124}).
-define(DATETIME, {{2013,9,12},{18,21,11}}).
-define(SHORT, "20130912182111"). 
-define(READABLE, "2013-09-12 18:21:11"). 

readable_default_test_() ->
	[
	 {"datetime", ?_assertEqual(?READABLE, deck36_time:readable(?DATETIME))},
	 {"timestamp", ?_assertEqual(?READABLE, deck36_time:readable(?TIMESTAMP))}
	].


format_test_() ->
	[
	 {"datetime", ?_assertEqual(?SHORT, deck36_time:format(?SHORT_FMT, ?DATETIME))},
	 {"timestamp", ?_assertEqual(?SHORT, deck36_time:format(?SHORT_FMT, ?TIMESTAMP))}
	].


timestamp_to_ms_test_() ->
	Ts = {1379,6570,325955},
	?_assertEqual(1379006570325, deck36_time:timestamp_to_ms(Ts)).

timestamp_to_micros_test_() ->
	Ts = {1379,6570,325955},
	?_assertEqual(1379006570325955, deck36_time:timestamp_to_micros(Ts)).

ms_to_timestamp_test_() ->
	Ms = 1379006570325,
	[
	 {"is expected", ?_assertEqual({1379,6570,325000}, deck36_time:ms_to_timestamp(Ms))},
	 {"Arg < 0 is invalid", ?_assertError(function_clause, deck36_time:ms_to_timestamp(-1))}
	].

micros_to_timestamp_test_() ->
	Micros = 1379006570325123,
	[
	 {"is expected", ?_assertEqual({1379,6570,325123}, deck36_time:micros_to_timestamp(Micros))},
	 {"Arg < 0 is invalid", ?_assertError(function_clause, deck36_time:micros_to_timestamp(-1))}
	].

now_localtime_readable_test_() ->
	?_assertMatch(?DEFAULT_FMT_PAT, deck36_time:now_localtime_readable()).

now_localtime_format_test_() ->
	?_assertMatch(?SHORT_FMT_PAT, deck36_time:now_localtime_format(?SHORT_FMT)).


now_utc_readable_test_() ->
	?_assertMatch(?DEFAULT_FMT_PAT, deck36_time:now_utc_readable()).

now_utc_format_test_() ->
	?_assertMatch(?SHORT_FMT_PAT, deck36_time:now_utc_format(?SHORT_FMT)).

now_timestamp_ms_test_() ->
	Now = deck36_time:now_timestamp_ms(),
	[
	 {"is integer", ?_assertMatch(X when is_integer(X), Now)},
	 {"is >= 0", ?_assertMatch(X when X >= 0, Now)}
	].

now_timestamp_micros_test_() ->
	Now = deck36_time:now_timestamp_micros(),
	[
	 {"is integer", ?_assertMatch(X when is_integer(X), Now)},
	 {"is >= 0", ?_assertMatch(X when X >= 0, Now)}
	].

%% ====================================================================
%% Internal functions
%% ====================================================================

