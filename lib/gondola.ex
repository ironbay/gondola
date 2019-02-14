alias Gondola.Token
alias Gondola.Config

defmodule Gondola do
  def for_scope(scope) do
    Token.from_method(scope, Config.method())
  end

  def from_cache(scope) do
  end
end
