defmodule Exos.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exos,
      version: "2.1.0",
      elixir: ">= 1.9.0",
      description: description(),
      package: package(),
      deps: [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false}],
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp docs do
    [
      api_reference: false,
      extras: [
        "CHANGELOG.md": [title: "Changelog"],
        "README.md": [title: "Overview"],
      ],
      main: "readme"
    ]
  end

  defp package do
    [ maintainers: ["Arnaud Wetzel", "Jean Parpaillon"],
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
