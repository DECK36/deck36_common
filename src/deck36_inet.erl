%% ====================================================================
%%
%% Copyright (c) DECK36 GmbH & Co. KG, Valentinskamp 18, 20354 Hamburg/Germany and individual contributors.
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
%% @doc inet helpers
%%
%% Validators: is_ip_address_str/1     -- Is valid IP address string?
%%             is_ip_address_tuple/1   -- Is valid inet:ip_address()?
%%             is_ip_address/1         -- Is valid IP address string or inet:ip_address()?
%%             is_port_number/1        -- Is valid inet:port_number()?
%%
%% Converters: ntoa/1                  -- inet:ntoa/1 with validation
%%
%% See function description for further information.

-module(deck36_inet).

%% ====================================================================
%% API functions
%% ====================================================================
-export([ntoa/1,
		 is_ip_address_str/1,
		 is_ip_address_tuple/1,
		 is_ip_address/1,
		 is_port_number/1]).

%% ntoa/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/inet.html#ntoa-1">inet:ntoa/1</a> with result validation.
%%
%% Don't rely on inet:ntoa/1 not giving {error,einval} as it will also accept
%% {256,512,-1, -1} returning "256.512.-1.-1".
-spec ntoa(Addr :: inet:ip_address()) -> string() | {error, einval}.
%% ====================================================================
ntoa(Addr) ->
	R = inet:ntoa(Addr),
	case is_ip_address_str(R) of
		true -> R;
		false -> {error, einval}
	end.


%% is_ip_address_str/1
%% ====================================================================
%% @doc Is given Addr a valid IP address string?
-spec is_ip_address_str(Addr :: string()) -> boolean().
%% ====================================================================
is_ip_address_str(Addr) when is_binary(Addr) ->
	is_ip_address_str(erlang:binary_to_list(Addr));
is_ip_address_str(Addr) ->
	case inet:parse_address(Addr) of
		{ok, _} -> true;
		_ -> false
	end.


%% is_ip_address_tuple/1
%% ====================================================================
%% @doc Is given Addr a valid ip_address() tuple?
%%
%% Don't rely on inet:ntoa/1 not giving {error,einval} as it will also accept
%% {256,512,-1, -1} returning "256.512.-1.-1".
-spec is_ip_address_tuple(Addr :: inet:ip_address()) -> boolean().
%% ====================================================================
is_ip_address_tuple(Addr) ->
	try
		is_ip_address_str(inet:ntoa(Addr))
	catch
		error:badarg -> false
	end.
		  

%% is_ip_address/1
%% ====================================================================
%% @doc Is given Addr a valid IP address tuple/string?
-spec is_ip_address(Addr :: string() | inet:ip_address()) -> boolean().
%% ====================================================================
is_ip_address(Addr) when is_tuple(Addr) ->
	is_ip_address_tuple(Addr);
is_ip_address(Addr) ->
	is_ip_address_str(Addr).
	

%% is_port_number/1
%% ====================================================================
%% @doc Is given Port a valid inet:port_number()?
-spec is_port_number(Port :: term()) -> boolean().
%% ====================================================================
is_port_number(Port) when is_integer(Port), Port >= 0, Port < 65536 ->
	true;
is_port_number(_) ->
	false.
	

%% ====================================================================
%% Internal functions
%% ====================================================================


