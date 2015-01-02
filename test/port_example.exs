## reference implementation of a port
defmodule ErlPort do
  alias :erlang, as: Erl

  def server(stdio,handler,state,bin \\ "") do
    receive do
      {_,{:data,data}}-> read(stdio,bin<>data,state,handler)
    end
  end
  def read(stdio,<<len::32,term::size(len)-binary,rest::binary>>,state,handler), do:
    read(stdio,rest,handler.(Erl.binary_to_term(term),state),handler)
  def read(stdio,other,state,handler), do:
    server(stdio,handler,state,other)
  def send(stdio,term) do
    bin = Erl.term_to_binary(term)
    Port.command(stdio,<<byte_size(bin)::32,bin::binary>>)
  end
end

stdio = Port.open({:fd,0,1}, [:stream,:binary])
ErlPort.server(stdio,fn
  (init_term,:not_initialized)-> init_term #first message is state
  ({:echo, term},counter)-> ErlPort.send(stdio,term); counter
  ({:add,int},counter)-> counter+int
  ({:rem,int},counter)-> counter-int
  (:counter,counter)-> ErlPort.send(stdio,counter); counter
end,:not_initialized)
