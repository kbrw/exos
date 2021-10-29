Exos
====

Exos is a simple Port Wrapper : a GenServer which forwards cast and call to a
linked Port. Requests and responses are converted using binary erlang term
external representation.

You can use it to create a GenServer for Python, Clojure, NodeJS with :
- [clojure-erlastic](http://github.com/awetzel/clojure-erlastic)
- [python-erlastic](http://github.com/awetzel/python-erlastic)
- [node-erlastic](http://github.com/kbrw/node_erlastic)

## Launching a Clojure/Python/NodeJS GenServer and use it in Elixir ##

Usage : `Exos.Proc.start_link` (see function documentation), then the resulting
process is a GenServer where cast and call are binary encoded through stdio to
the underlying process. If the GenServer receive messages outside of a call, an
anonymous function can be attached to be called on each message.

See `test/port_example.exs` for a reference implementation of a server that can
be launched in a port with `Exos.Proc`, and `test/exos_test.exs` for its use.
`clojure/python/node_erlastic` projects can be used to launch a
java/python/javascript GenServer.

See above an example of an account manager server developped in
python/nodejs/clojure.

```elixir
defmodule Account do
  def cmd do
    case Application.get_env(:account_impl) do
      :python-> "venv/bin/python -u account.py"
      :node-> "node account.js"
      :clojure-> "java -cp 'target/*' clojure.main account.clj"
    end
  end
  def start_link(ini), do: Exos.Proc.start_link(cmd,ini,[cd: "#{:code.priv_dir(:myproj)}/account"],name: __MODULE__)
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
      worker(Account,[0])
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

Finally just implement your account server in any language as describe below,
and use it as a standard GenServer.

> iex -S mix

```elixir
Account.add(5)
Account.rem(1)
4 == Account.get
```

## Account Server Implementation in clojure ##

```bash
mix new myproj
cd myproj ; mkdir -p priv/account; cd priv/account
vim project.clj
```

```clojure
(defproject account "0.0.1" 
  :dependencies [[clojure-erlastic "0.2.3"]
                 [org.clojure/core.match "0.2.1"]])
```

```bash
lein uberjar
vim account.clj
```

```clojure
(require '[clojure-erlastic.core :refer [run-server]])
(use '[clojure.core.match :only (match)])
(run-server
  (fn [term count] (match term
    [:add n] [:noreply (+ count n)]
    [:rem n] [:noreply (- count n)]
    :get [:reply count count])))
```

## Account Server Implementation in Python >3.4 ##

```bash
mix new myproj
cd myproj ; mkdir -p priv/account; cd priv/account
echo "git://github.com/awetzel/python-erlastic.git#egg=erlastic" > requirements.txt
pyvenv venv
./venv/bin/pip install -r requirements.txt
vim account.py
```

```python
mailbox,port = port_connection()
account = next(mailbox) #first msg is initial state
for req in mailbox:
  if req == "get": port.send(account)
  else:
    (op,amount) = req
    account = (account+amount) if op=="add" else (account-amount)
```

## Account Server Implementation in NodeJS ##

```bash
mix new myproj
cd myproj ; mkdir -p priv/account; cd priv/account
npm init
npm install node_erlastic --save
vim account.js
```

```javascript
require('node_erlastic').server(function(term,from,current_amount,done){
  if (term == "get") return done("reply",current_amount);
  if (term[0] == "add") return done("noreply",current_amount+term[1]);
  if (term[0] == "rem") return done("noreply",current_amount-term[1]);
  throw new Error("unexpected request")
});
```

# CONTRIBUTING

Hi, and thank you for wanting to contribute.
Please refer to the centralized informations available at: https://github.com/kbrw#contributing

