defmodule Exos.Mixfile do
  use Mix.Project

  defp version, do: "2.1.1"

  def project do
    [
      app: :exos,
      version: version(),
      elixir: "~> 1.9",
      description: description(),
      package: package(),
      source_url: source_url(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false, warn_if_outdated: true}]
  end

  defp docs do
    [
      api_reference: false,
      extras: [
        "README.md": [title: "Overview"],
        "CHANGELOG.md": [title: "Changelog"],
      ],
      main: "readme",
      source_ref: "v#{version()}"
    ]
  end

  defp package do
    [
      maintainers: ["Arnaud Wetzel", "Jean Parpaillon"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/exos/changelog.html",
        "GitHub" => source_url(),
      }
    ]
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

  defp source_url, do: "https://github.com/kbrw/exos"
end
