defmodule ExosTest do
  use ExUnit.Case, async: false

  setup_all do
    GenEvent.start_link(name: TestEvents)
    Exos.Proc.start_link("elixir --erl -noinput #{__DIR__}/port_example.exs",0,[],[name: EchoAndAccount],TestEvents)
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
      use GenEvent
      def handle_event(term,_), do: {:ok, term}
      def handle_call(:last,last), do: {:ok,last,last}
    end
    GenEvent.add_handler(TestEvents, TestHandler, [])
    GenServer.cast(EchoAndAccount,{:echo,{:hello,:world}})
    receive do after 1000->:ok end
    assert {:hello,:world} = GenEvent.call(TestEvents,TestHandler,:last)
    GenServer.cast(EchoAndAccount,{:echo,{:hello,:arnaud}})
    receive do after 1000->:ok end
    assert {:hello,:arnaud} = GenEvent.call(TestEvents,TestHandler,:last)
  end
end
