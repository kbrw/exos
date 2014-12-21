defmodule Exos.Proc do
  use GenServer

  def start_link(cmd,init,opts \\ [],link_opts \\ []), do:
    GenServer.start_link(Exos.Proc,{cmd,init,opts},link_opts)

  def init({cmd,initarg,opts}) do
    port = Port.open({:spawn,'#{cmd}'}, [:binary,:exit_status, packet: 4] ++ opts)
    send(port,{self,{:command,:erlang.term_to_binary(initarg)}})
    {:ok,port}
  end

  def handle_info({port,{:exit_status,0}},port), do: {:stop,:normal,port}
  def handle_info({port,{:exit_status,_}},port), do: {:stop,:port_terminated,port}
  def handle_info(_,port), do: {:noreply,port}

  def handle_cast(term,port) do
    send(port,{self,{:command,:erlang.term_to_binary(term)}})
    {:noreply,port}
  end

  def handle_call(term,_reply_to,port) do
    send(port,{self,{:command,:erlang.term_to_binary(term)}})
    res = receive do 
      {^port,{:data,b}}->:erlang.binary_to_term(b)
      {^port,{:exit_status,_}}=exit_msg->send(self,exit_msg);{:error,:port_terminated} # catch exit msg and resend it
    end
    {:reply,res,port}
  end
end
