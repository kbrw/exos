defmodule Exos.Proc do
  use GenServer
  alias :erlang, as: Erl

  @doc """
  Launch a GenServer which starts a port and proxify cast and call to
  it using a port protocol with `packet: 4`, (32bits-length+data)
  messages are transmitted throught stdin/out. Input terms are
  encoded using `binary_to_term` and received terms are decoded using
  `term_to_binary`.

  - `cmd` is the shell command to launch the port
  - when the port starts, it automatically receives as first message the `init`
    term if `init !== :no_init`
  - `port_opts` are options for `Port.open` (for instance `[cd: "/path/"]`)
  - `gen_server_opts` are options for `GenServer.start_link` (for instance `[name: :servername]`)
  - messages received from the port outside of a `GenServer.call`
    context trigger a `event_fun.(event)` call if `event_fun` is not `nil` (default)
  - `etf_opts` are options for `:erlang.term_to_binary` and `:erlang.binary_to_term`
  - to allow easy supervision, if the port die with a return code == 0, then
    the GenServer die with the reason `:normal`, else with the reason `:port_terminated`
  """
  @deprecated "Use #{__MODULE__}.start_link/3 instead"
  def start_link(cmd, init, port_opts, gen_server_opts, event_fun) do
    start_link(cmd, init, [
      port_opts: port_opts,
      gen_server_opts: gen_server_opts,
      event_fun: event_fun,
    ])
  end

  @deprecated "Use #{__MODULE__}.start_link/3 instead"
  def start_link(cmd, init, port_opts, gen_server_opts) do
    start_link(cmd, init, [
      port_opts: port_opts,
      gen_server_opts: gen_server_opts,
    ])
  end

  def start_link(cmd, init, opts \\ []) do
    known_opts = [:port_opts, :gen_server_opts, :event_fun, :etf_opts]
    case Keyword.keyword?(opts) and match?({:ok, _}, Keyword.validate(opts, known_opts)) do
      true ->
        port_opts = Keyword.get(opts, :port_opts, [])
        gen_server_opts = Keyword.get(opts, :gen_server_opts, [])
        event_fun = Keyword.get(opts, :event_fun)
        etf_opts = Keyword.get(opts, :etf_opts, [])
        GenServer.start_link(Exos.Proc, {cmd, init, port_opts, event_fun, etf_opts}, gen_server_opts)

      false ->
        # If no key matches with our opts, then it means it is the old API being used.
        IO.warn("You are using the old API of #{__MODULE__}.start_link/3 that takes Port.open/2
          options as 3rd parameter. The new API takes a Keyword list instead to handle options of
          the old API.")
        start_link(cmd, init, [port_opts: opts])
    end
  end

  def init({cmd,initarg,opts,etf_opts}), do: init({cmd,initarg,opts,nil,etf_opts})
  def init({cmd,initarg,opts,event_fun,etf_opts}) do
    port = Port.open({:spawn,~c'#{cmd}'}, [:binary,:exit_status, packet: 4] ++ opts)
    if initarg !== :no_init, do:
      send(port,{self(),{:command,Erl.term_to_binary(initarg,etf_opts)}})
    {:ok, {port, event_fun, etf_opts}}
  end

  def handle_info({port,{:exit_status,0}},{port,_,_}=state), do: {:stop,:normal,state}
  def handle_info({port,{:exit_status,_}},{port,_,_}=state), do: {:stop,:port_terminated,state}
  def handle_info({port,{:data,b}},{port,event_fun,_}=state) do
    if event_fun do event_fun.(Erl.binary_to_term(b)) end
    {:noreply,state}
  end

  def handle_cast(term,{port,_,etf_opts}=state) do
    send(port,{self(),{:command,Erl.term_to_binary(term,etf_opts)}})
    {:noreply,state}
  end

  def handle_call(term,_reply_to,{port,_,etf_opts}=state) do
    send(port,{self(),{:command,Erl.term_to_binary(term,etf_opts)}})
    res = receive do 
      {^port,{:data,b}}->Erl.binary_to_term(b)
      {^port,{:exit_status,_}}=exit_msg->send(self(),exit_msg);{:error,:port_terminated} # catch exit msg and resend it
    end
    {:reply,res,state}
  end
end
