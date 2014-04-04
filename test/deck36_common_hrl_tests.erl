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

-module(deck36_common_hrl_tests).

-include_lib("eunit/include/eunit.hrl").

%% Include twice to check ifndef
%% ====================================================================
-include("deck36_common.hrl").
-include("deck36_common.hrl").

%% Export types to test if properly defined
-export_type([reason/0,
			  void/0,
			  ignored/0,
			  server_ref/0,
			  from/0,
			  regexp/0,
			  key/0,
			  proplist/0,
			  function/0,
			  argument/0,
			  fun_opt/0]).

%% ====================================================================
%% Tests
%% ====================================================================

%% Test GV/2 macro
%% ====================================================================
gv_2_test_() ->
	L = [{1,2}, {a,b}, {"c", d}, {<<"e">>, f}, {{g,h}, i}, {[j,k], l}, {m, fun() -> n end}],
	[{lists:flatten(io_lib:format("~p", [X])),
	  ?_assertEqual(proplists:get_value(X, L), ?GV(X, L))}
	|| {X, _} <- L].


%% Test GV/3 macro
%% ====================================================================
gv_3_test_() ->
	[{"value", ?_assertEqual(value, ?GV(key1, [{key1, value}], default))},
	 {"default", ?_assertEqual(default, ?GV(key2, [{key1, value}], default))}
	].


%% Test GA/2 macro
%% ====================================================================
ga_test_() ->
	L = [{a,b}, {c,d}, {a,e}, {a,f}, {g, k}],
	?_assertEqual(proplists:get_all_values(a, L), ?GA(a, L)).


%% Test GB/2 macro
%% ====================================================================
gb_test_() ->
	L = [{a, true}, b, {c, false}],
	[{"+ a", ?_assert(?GB(a, L))},
	 {"+ b", ?_assert(?GB(b, L))},
	 {"- c", ?_assertNot(?GB(c, L))},
	 {"- undef", ?_assertNot(?GB(d, L))}
	].
