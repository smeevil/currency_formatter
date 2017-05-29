-module(idna_unicode_data).
-export([lookup/1]).
-export([decomposition/1]).

-include("idna_unicode_data.hrl").

lookup("") -> false;
lookup(Codepoint) ->
	maps:get(Codepoint, ?BY_CODE, false).

decomposition("") -> false;
decomposition(Key) ->
	maps:get(Key, ?BY_KEY, false).
