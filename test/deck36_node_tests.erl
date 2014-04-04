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

-module(deck36_node_tests).

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).

-include_lib("eunit/include/eunit.hrl").
-include("deck36_common.hrl").

%% ====================================================================
%% Tests
%% ====================================================================

%% set_cookie_test_/0
%% ====================================================================
%% @doc Test set_cookie/1 with atom, list, binary and {file, X}.
%% ====================================================================
set_cookie_test_() ->
	{setup,
	 fun() -> start_node() end,
	 fun(_) -> stop_node() end,
	 fun(_) ->
			 [
			  {"atom", fun set_cookie_atom/0},
			  {"list", fun set_cookie_list/0},
			  {"binary", fun set_cookie_binary/0},
 			  {"file", fun set_cookie_file/0}
			 ]
	 end}.


%% set_cookie_test_/0 workers
%% ====================================================================
set_cookie_atom() ->
	deck36_node:set_cookie('cookie atom'),
	?assertEqual('cookie atom', erlang:get_cookie()).


set_cookie_list() ->
	deck36_node:set_cookie("cookie list"),
	?assertEqual('cookie list', erlang:get_cookie()).


set_cookie_binary() ->
	deck36_node:set_cookie(<<"cookie binary">>),
	?assertEqual('cookie binary', erlang:get_cookie()).


set_cookie_file() ->
	Fn = "test_cookie",
	Cookie = <<"cookie file">>,
	mock_file([{Fn, Cookie}]),
	deck36_node:set_cookie({file, Fn}),
	unmock(file),
	?assertEqual('cookie file', erlang:get_cookie()).


%% configure_test_/0
%% ====================================================================
%% @doc Test configure/0, configure/1 with app and config 
%% ====================================================================
configure_test_() ->
	Envs = [
			{deck36_common, [{cookie, deck36_cookie}]},
			{other_app, [{cookie, other_cookie}]}
		   ],
	{setup,
	 fun() -> start_node(), mock_application(Envs) end,
	 fun(_) -> stop_node(), unmock(application) end,
	 fun(_) ->
			 [
			  {"/0", fun configure_own/0},
			  {"/1 app", fun configure_app/0},
			  {"/1 proplist", fun configure_proplist/0},
			  {"/1 undefined", fun configure_undefined/0}
			 ]
	 end}.

configure_own() ->
	deck36_node:configure(),
	?assertEqual(deck36_cookie, erlang:get_cookie()).

configure_app() ->
	deck36_node:configure(other_app),
	?assertEqual(other_cookie, erlang:get_cookie()).

configure_proplist() ->
	deck36_node:configure([{cookie, proplist_cookie}]),
	?assertEqual(proplist_cookie, erlang:get_cookie()).

configure_undefined() ->
	erlang:set_cookie(node(), undefined_cookie),
	deck36_node:configure([]),
	?assertEqual(undefined_cookie, erlang:get_cookie()).

%% ====================================================================
%% Internal functions
%% ====================================================================
start_node() ->
	net_kernel:start(
	  [
	   erlang:list_to_atom(
		 "deck36_node_tests_" ++ erlang:integer_to_list(
		   crypto:rand_uniform(1000000, 9999999))),
	   shortnames]),
	ok.


stop_node() ->
	net_kernel:stop(),
	ok.
	

mock_file(Files) ->
	ok = meck:new(file, [unstick, passthrough]),
	ok = meck:expect(file, read_file,
					 fun(Fn) ->
							 case ?GV(Fn, Files) of
								 undefined -> meck:passthrough([Fn]);
								 Content -> {ok, Content}
							 end
					 end),
	ok.


mock_application(Envs) ->
	ok = meck:new(application, [unstick, passthrough]),
	ok = meck:expect(application, load, fun(_) -> ok end),
	ok = meck:expect(application, get_env,
					 fun(App, Key) ->
							 case ?GV(App, Envs) of
								 undefined -> undefined;
								 Env -> ?GV(Key, Env)
							 end
					 end),
	ok.
										

unmock(Mod) ->
	meck:unload(Mod).


