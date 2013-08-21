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
      	new_record = case all_by_key(module,key,val) do
      	[] -> 
      		Amnesia.transaction do
            	new_record = apply(module,:new,[attributes])
            	IO.puts "NOORM Created New record: #{inspect new_record}"
      			new_record.write	
      			new_record
      		end
      	[record] -> 
      		Amnesia.transaction do
            	new_record = record.update(attributes)
      			new_record.write
      			IO.puts "NOORM updated \n\trecord #{inspect record}\n\tnew_record #{inspect new_record}"
      			new_record
      		end
      	list -> 
      		IO.puts "NOORM Warning: multiple records, you should ensure key is unique\n#{inspect list}"
          	#throw("DISASTER #{inspect list}")
      		:error
      end
      new_record
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
