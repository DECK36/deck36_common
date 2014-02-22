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
%% @doc Time measurement and conversion functions.
%%
%% Function names should speak for themselves.

-module(deck36_time).

%% ====================================================================
%% API functions
%% ====================================================================
%% Conversion
-export([readable/1,
		 format/2,
		 timestamp_to_ms/1,
		 timestamp_to_micros/1,
		 ms_to_timestamp/1,
		 micros_to_timestamp/1]).
%% Measurements
-export([now_localtime_readable/0,
		 now_localtime_format/1,
		 now_utc_readable/0,
		 now_utc_format/1,
		 now_timestamp_ms/0,
		 now_timestamp_micros/0
		 ]).


%% readable/1
%% ====================================================================
%% @doc Convert DateTime to readable string
-spec readable(calendar:datetime() | erlang:timestamp()) -> string(). 
%% ====================================================================
readable({{Year,Month,Day},{Hour,Min,Sec}}) ->
	lists:flatten(
	  io_lib:format(
		"~4.10.0B-~2.10.0B-~2.10.0B ~2.10.0B:~2.10.0B:~2.10.0B",
		[Year, Month, Day, Hour, Min, Sec]));
readable({_,_,_}=Timestamp) ->
	readable(calendar:now_to_datetime(Timestamp)).


%% format/2
%% ====================================================================
%% @doc Convert DateTime to string formatted with Format
%%
%% Format according to <a href="https://github.com/daleharvey/dh_date">https://github.com/daleharvey/dh_date</a>
-spec format(Format :: io:format(), calendar:datetime()) -> string().
%% ====================================================================
format(Format, DateTime) ->
	dh_date:format(Format, DateTime).


%% timestamp_to_ms/1
%% ====================================================================
%% @doc Convert erlang:timestamp() to milliseconds
-spec timestamp_to_ms(erlang:timestamp()) -> non_neg_integer().
%% ====================================================================
timestamp_to_ms({MegaSecs, Secs, MicroSecs}) ->
	((MegaSecs * 1000000 + Secs) * 1000) + (MicroSecs div 1000).


%% timestamp_to_micros/1
%% ====================================================================
%% @doc Convert erlang:timestamp() to microseconds
-spec timestamp_to_micros(erlang:timestamp()) -> non_neg_integer().
%% ====================================================================
timestamp_to_micros({MegaSecs, Secs, MicroSecs}) ->
	((MegaSecs * 1000000 + Secs) * 1000000) + MicroSecs.


%% ms_to_timestamp/1
%% ====================================================================
%% @doc Convert timestamp in milliseconds to erlang:timestamp()
-spec ms_to_timestamp(non_neg_integer()) -> erlang:timestamp().
%% ====================================================================
ms_to_timestamp(MilliSecs) when MilliSecs >= 0 ->
	MicroSecs = (MilliSecs rem 1000) * 1000,
	TSecs = (MilliSecs div 1000),
	Secs = (TSecs rem 1000000),
	MegaSecs = (TSecs div 1000000),
	{MegaSecs, Secs, MicroSecs}.


%% micros_to_timestamp/1
%% ====================================================================
%% @doc Convert timestamp in microseconds to erlang:timestamp()
-spec micros_to_timestamp(non_neg_integer()) -> erlang:timestamp().
%% ====================================================================
micros_to_timestamp(MicroSecs) when MicroSecs >= 0 ->
	RMicroSecs = (MicroSecs rem 1000000),
	TSecs = (MicroSecs div 1000000),
	RSecs = (TSecs rem 1000000),
	RMegaSecs = (TSecs div 1000000),
	{RMegaSecs, RSecs, RMicroSecs}.


%% now_localtime_readable/0
%% ====================================================================
%% @doc Get current localtime in readable format
-spec now_localtime_readable() -> string().
%% ====================================================================
now_localtime_readable() ->
	readable(erlang:localtime()).


%% now_localtime_format/1
%% ====================================================================
%% @doc Get current localtime in Format 
-spec now_localtime_format(Format :: string()) -> string().
%% ====================================================================
now_localtime_format(Format) ->
	format(Format, erlang:localtime()).


%% now_utc_readable/0
%% ====================================================================
%% @doc Get current universal time in readable format 
-spec now_utc_readable() -> string().
%% ====================================================================
now_utc_readable() ->
	readable(erlang:universaltime()).


%% now_utc_format/1
%% ====================================================================
%% @doc Get current universal time in Format 
-spec now_utc_format(Format :: string()) -> string().
%% ====================================================================
now_utc_format(Format) ->
	format(Format, erlang:universaltime()).


%% now_timestamp_ms/0
%% ====================================================================
%% @doc Get current timestamp in milliseconds
-spec now_timestamp_ms() -> non_neg_integer().
%% ====================================================================
now_timestamp_ms() ->
	timestamp_to_ms(os:timestamp()).


%% now_timestamp_micros/0
%% ====================================================================
%% @doc Get current timestamp in microseconds
-spec now_timestamp_micros() -> non_neg_integer().
%% ====================================================================
now_timestamp_micros() ->
	timestamp_to_micros(os:timestamp()).
