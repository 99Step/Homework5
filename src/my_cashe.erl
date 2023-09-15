-module(my_cashe).

-export([create/1, insert/3, insert/4, lookup/2, delete_obsolete/1]).

create(TableName) ->
  ets:new(TableName, [named_table, public]),
  ok.

insert(TableName, Key, Value) ->
  ets:insert(TableName, {Key, Value}).

insert(TableName, Key, Value, Timer) ->
 NewTimer = erlang:system_time() + 1000000000 * Timer,
  ets:insert(TableName, {Key, Value, NewTimer}).

lookup(TableName, Key) ->
  case ets:lookup(TableName, Key) of
    [{Key, Value}] -> Value;
    [{Key, Value, Timer}] -> check(TableName, Key, Value, Timer);
    _ -> undefined
  end.

delete_obsolete(TableName) ->
  case ets:first(TableName) of
    end_of_table -> ok;
    Key -> delete(TableName, Key)
  end.

check(TableName, Key, Value, Timer) ->
  case Timer >= erlang:system_time() of
    true -> Value;
    _ -> ets:delete(TableName, Key),
      undefined
  end.

delete(_, '$end_of_table') ->
  ok;
delete(TableName, Key) ->
  NewKey = ets:next(TableName, Key),
  lookup(TableName, Key),
  delete(TableName, NewKey).