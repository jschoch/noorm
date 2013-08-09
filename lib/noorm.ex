defmodule NoOrm do
  defmacro __using__(_opts) do
    quote do
      require Amnesia
      require Amnesia.Fragment
      require NoOrm
      import NoOrm
      def all_by_key(key,val) do
     		all_by_key(__MODULE__,key,val) 
      end
      def first_by_key(key,val) do
     		Enum.first(all_by_key(key,val)) 
      end
      def aou(key,attributes) do
     		add_or_update(__MODULE__,key,attributes) 
      end
      def all do
        keys = Amnesia.transaction do
          __MODULE__.keys
        end
        Enum.map(keys,fn(k) -> 
          Amnesia.transaction do
            __MODULE__.read(k)
          end 
        end) 
      end
    end
  end
  defmacro all_by_key(module,key,val) do
  	#IO.puts "out of quote #{__MODULE__}"

    quote do
    	#IO.puts "in quote #{__MODULE__}"
      name = __MODULE__
      key = unquote(key)
      val = unquote(val)
      #IO.puts "create record: #{inspect __MODULE__[_: :_] }"
      #IO.puts "update record: #{inspect __MODULE__[_: :_].update([{key,val}])}"
      match = __MODULE__[_: :_].update([{key,val}])
      Amnesia.transaction do
     		case Amnesia.Table.match(name,match) do
          nil -> []
          res -> 
          	#IO.puts "WOOT: #{inspect res.values}"
          	res.values
        end
      end 
    end
  end
 	 
  defmacro add_or_update(module,key,attributes) do
    quote do
    	module = unquote(module)
    	key = unquote(key)
    	attributes = unquote(attributes) 
    	val = attributes[key]
    	IO.puts " add_or_update module: #{module} key: #{key} val: #{val} \n\tAttributes: #{inspect attributes}"
      record = nil
      record = case all_by_key(module,key,val) do
      	[] -> 
      		IO.puts "Need to create a new thing here"
      		Amnesia.transaction do
            last = apply(module,:last,[])
            IO.puts "last was: #{inspect last}"
            id_ = 1
            if (is_record(last)) do
              id_ = last.id + 1
              IO.puts "Update ID to: #{id_}"
            end
            IO.puts "Setting id to: #{id_} was #{attributes[:id]} for key: #{key} with val: #{val}"
            attributes = ListDict.put(attributes,:id,id_)
            record = apply(module,:new,[attributes])
            IO.puts "New record: #{inspect record}"
      			record.write	
            record
      		end
      	[record] -> 
      		IO.puts "need to update this #{inspect record}"
      		id = record.id
      		IO.puts "updated record: #{inspect record}"
      		Amnesia.transaction do
            record = __MODULE__.read(id)
            record = record.update(attributes)
      			record.write
      		end
      		record
      	list -> 
      		IO.puts "Warning: multiple records, you should ensure key is unique\n#{inspect list}"
          throw("DISASTER")
      		:error
      end
      IO.puts "RECORD was: #{inspect record}"
      record
    end
  end
end
defmodule THIS_IS_A_Tst do
	defrecord TT,[:id,:foo] do
		use NoOrm
  end
  defrecord BB,[:id,:bar] do
 		use NoOrm 
  end
end
