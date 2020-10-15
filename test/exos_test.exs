defmodule ExosTest do
  use ExUnit.Case, async: false

  @dispatch_key :events
  def dispatch_event(event) do
    Registry.dispatch(TestEvents, @dispatch_key, fn entries ->
      for {pid, nil} <- entries, do: send(pid,{:event,event})
    end)
  end
  def register! do
    {:ok, _} = Registry.register(TestEvents,@dispatch_key,nil)
  end

  setup_all do
    Registry.start_link(keys: :duplicate, name: TestEvents)
    Exos.Proc.start_link("elixir --erl -noinput #{__DIR__}/port_example.exs",0,[],[name: EchoAndAccount],&dispatch_event/1)
    :ok
  end

  test "Echo call to port" do
    assert {:foo,:bar} = GenServer.call(EchoAndAccount,{:echo,{:foo,:bar}})
  end

  test "Account state management, cast and call" do
    GenServer.cast(EchoAndAccount,{:add,2})
    GenServer.cast(EchoAndAccount,{:add,4})
    GenServer.cast(EchoAndAccount,{:rem,1})
    assert 5 = GenServer.call(EchoAndAccount,:counter)
  end

  test "Test event management" do
    defmodule TestHandler do #put last event in state
      use GenServer
      def init(_) do ExosTest.register!(); {:ok,[]} end
      def handle_info({:event,event},_) do {:noreply, event} end
      def handle_call(:last,_,last) do {:reply,last,last} end
    end
    GenServer.start_link(TestHandler,[], name: TestHandler)
    GenServer.cast(EchoAndAccount,{:echo,{:hello,:world}})
    receive do after 1000->:ok end
    assert {:hello,:world} = GenServer.call(TestHandler,:last)
    GenServer.cast(EchoAndAccount,{:echo,{:hello,:arnaud}})
    receive do after 1000->:ok end
    assert {:hello,:arnaud} = GenServer.call(TestHandler,:last)
  end
end
