defmodule Exos.Mixfile do
  use Mix.Project

  def project do
    [app: :exos,
     version: "1.0.1",
     elixir: ">= 1.0.0",
     description: description(),
     package: package(),
     deps: [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false}]]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [ maintainers: ["Arnaud Wetzel"],
      licenses: ["MIT"],
      links: %{ "GitHub"=>"https://github.com/kbrw/exos" } ]
  end

  defp description do
    """
    Create a GenServer in any language.

    Exos contains a very simple GenServer which proxy calls and casts to a given
    port command, encoding and decoding the message to the port using erlang
    external binary term format. (see related projects : 
    clojure|python|node_erlastic on https://github.com/kbrw)
    """
  end
end
