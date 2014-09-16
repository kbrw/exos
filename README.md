Exos
====

Exos is a simple Port Wrapper : a GenServer which forwards cast and call to a
linked Port. Requests and responses are converted using binary erlang term
external representation.

You can use [clojure-erlastic](http://github.com/awetzel/clojure-erlastic),
[python-erlastic](http://github.com/awetzel/python-erlastic), etc.

## Exemple usage : a clojure calculator ##

Using [clojure-erlastic](http://github.com/awetzel/clojure-erlastic), your can easily create
a port and communicate with it.

> mix new myproj

> cd myproj ; mkdir -p priv/calculator

> vim project.clj

```clojure
(defproject calculator "0.0.1" 
  :dependencies [[clojure-erlastic "0.2.3"]
                 [org.clojure/core.match "0.2.1"]])
```

> lein uberjar

> vim calculator.clj

```clojure
(require '[clojure-erlastic.core :refer [run-server]])
(use '[clojure.core.match :only (match)])
(run-server
  (fn [term count] (match term
    [:add n] [:noreply (+ count n)]
    [:rem n] [:noreply (- count n)]
    :get [:reply count count])))
```

Then in your project, you can use Exos.Proc GenServer as a proxy to the clojure
port.

```elixir
defmodule Calculator do
  def start_link(ini), do: GenServer.start_link(Exos.Proc,{"#{:code.priv_dir(:myproj)}/calculator","java -cp 'target/*' clojure.main calculator.clj",ini},name: __MODULE__)
  def add(v), do: GenServer.cast(__MODULE__,{:add,v})
  def rem(v), do: GenServer.cast(__MODULE__,{:rem,v})
  def get, do: GenServer.call(__MODULE__,:get,:infinity)
end

defmodule MyProj.App do
  use Application
  def start(_,_), do: MyProj.App.Sup.start_link

  defmodule Sup do
    use Supervisor
    def start_link, do: Supervisor.start_link(__MODULE__,[])
    def init([]), do: supervise([
      worker(Calculator,0)
    ], strategy: :one_for_one)
  end
end
```

> vim mix.exs

```elixir
def application do
  [mod: { MyProj.App, [] }]
end
```

Then you can use the calculator 

> iex -S mix

```elixir
Calculator.add(5)
Calculator.rem(1)
4 == Calculator.get
```
