alias Gondola.Token
alias Gondola.Config

defmodule Gondola do
  def for_scope(scope) do
    case cache_get(scope) do
      nil ->
        {:ok, token} = Token.from_method(scope, Config.method())
        :ok = cache_put(scope, token.expires_in + :os.system_time(:second) - 30, token)
        {:ok, token}

      token ->
        {:ok, token}
    end
  end

  def cache_get(scope) do
    now = :os.system_time(:second)

    :gondola
    |> Application.get_env(scope)
    |> case do
      {expires, token} when expires > now -> token
      _ -> nil
    end
  end

  def cache_put(scope, expires, token) do
    Application.put_env(:gondola, scope, {expires, token})
  end
end
