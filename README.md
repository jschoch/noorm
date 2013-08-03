# Noorm

** Elixir Helper Methods for Amnesia**
major alpha stuff here, 


just use NoOrm in your tables

``` elixir
defdatabase Db do
  deftable Rec,[:id,:foo,:stamp],type: :set do
    use NoOrm
  end
end
```

now you can do stuff like

```elixir

#return values matching key,val
Db.Rec.all_by_key(:foo,:bar)

```

add or update based on arbitrary key

```elixir

record = Db.Rec[id: 1].write!
Db.Rec.aou(:id,[id: 1,foo: "this was updated",stamp: :erlang.now])
```
