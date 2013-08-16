Code.require_file "test_helper.exs", __DIR__
use Amnesia
defdatabase Tst do
	deftable Rec,[:id,:foo],type: :set do
    use NoOrm
  end
end
defmodule NoormTest do
  use ExUnit.Case
  
  test "the truth" do
  	Amnesia.Schema.create
  	Amnesia.start
  	Tst.create
  	Tst.wait
  	
    res = Amnesia.transaction do
      Tst.Rec.last
    end	
    IO.puts "res: #{inspect res}"	



    rec = Tst.Rec[id: 1,foo: :bar].write!
    res = Tst.Rec.all_by_key(:foo,:bar)
    IO.puts inspect Tst.Rec.last!
    assert(res == [Tst.Rec[id: 1, foo: :bar]])
    rec = Tst.Rec[id: 2,foo: :baz].write!
    res = Tst.Rec.all_by_key(:id,2)
    assert(res == [Tst.Rec[id: 2, foo: :baz]])


    res = Amnesia.transaction do
      Tst.Rec.last
    end
    IO.puts "res: #{inspect res}"
   
   	### first by key
   	rec = Tst.Rec[id: 2,foo: :baz].write!
    res = Tst.Rec.first_by_key(:foo,:baz)
    assert(res == Tst.Rec[id: 2, foo: :baz])
   	 
    
    ### test add new
    res = Tst.Rec.aou(:foo, [foo: "DOH",id: 22])
    assert(res == Tst.Rec[id: 22, foo: "DOH"])
    
    ### test update
  	res = Tst.Rec.aou(:foo, [foo: "DOH",id: 23])  
  	assert(res == Tst.Rec[id: 23,foo: "DOH"])  

    ### test auto_increment works 
    
    res = Tst.Rec.aou(:foo, [foo: "Hoo"])
    assert(res == Tst.Rec[id: nil,foo: "Hoo"])
  	
  	### test how it handles bad attributes
  	###### no key
  	res = Tst.Rec.aou(:unf,[foo: "DOH"])
  	assert res == :error
  
  	### no attribute key
  	res = Tst.Rec.aou(:foo,[foo: "DOH",unf: "BAHHHHH"]) 
    
   	### test multiple matches on get_by_key
   	res = Tst.Rec.all_by_key(:foo, "DOH") 
   	IO.puts "DOH records: #{inspect res}"
   	assert(Enum.count(res) == 2)
  
    ### test all 
    all = Tst.Rec.all 
    assert(5 == Enum.count(all)) 
    Tst.destroy
    Amnesia.stop
    Amnesia.Schema.destroy
  end
end
