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
%% @doc Configure the current node.
%%
%% configure/0, configure/1 configure the current node according to an app environment
%% or agiven proplist. They currently only set the cookie.
%%
%% set_cookie/1, set_cookie/2 allow setting of cookies by atom, list, binary or file.
%%
%% See function description for further information.

-module(deck36_node).

%% ====================================================================
%% Types
%% ====================================================================
-type cookie() :: atom()
				| binary()
				| list()
				| {file, file:name_all()}.
-type node_opt() :: {cookie, cookie()}.


%% ====================================================================
%% API functions
%% ====================================================================
-export([configure/0, configure/1,
		 set_cookie/1, set_cookie/2]).

-include("deck36_common.hrl").
-define(APP, deck36_common).


%% configure/0
%% ====================================================================
%% @doc Configure node according to app config of deck36_common app
-spec configure() -> ok.
%% ====================================================================
configure() ->
	application:load(?APP),
	configure(?APP).


%% configure/1
%% ====================================================================
%% @doc Configure node according to app config of App or by proplist
-spec configure(Input) -> ok when
	Input :: atom()
		   | [node_opt()].
%% ====================================================================
configure(App) when is_atom(App) ->
	configure([
			   {cookie, application:get_env(App, cookie)}
			 ]);
configure(Config) ->
	case ?GV(cookie, Config) of
		undefined -> ok;
		Cookie -> set_cookie(Cookie)
	end,
	ok.


%% set_cookie/1
%% ====================================================================
%% @doc Set cookie of this node
-spec set_cookie(cookie()) -> true.
%% ====================================================================
set_cookie(Cookie) ->
	set_cookie(node(), Cookie).


%% set_cookie/2
%% ====================================================================
%% @doc Wrapper for erlang:set_cookie/2, allowing atom, list, binary
%% and file as input
-spec set_cookie(node(), cookie()) -> true.
%% ====================================================================
set_cookie(Node, {file, Fn}) ->
	{ok, C} = file:read_file(Fn),
	set_cookie(Node, C);
set_cookie(Node, C) when is_list(C) ->
	set_cookie(Node, erlang:list_to_atom(C));
set_cookie(Node, C) when is_binary(C) ->
	set_cookie(Node, erlang:binary_to_list(C));
set_cookie(Node, C) when is_atom(C) ->
	true =:= erlang:set_cookie(Node, C).
	
