alias Gondola.Config

defmodule Gondola.Token do
  use Tesla

  plug(Tesla.Middleware.DecodeJson, engine_opts: [keys: :atoms])

  def from_method(scope, method) do
    case method do
      :credentials -> from_credentials(scope, Config.credentials())
      :metadata -> from_metadata()
      :invalid -> {:error, :missing_credentials}
    end
  end

  def from_metadata(account \\ "default") do
    with {:ok, result} <-
           Tesla.client([
             {Tesla.Middleware.Headers, [{"Metadata-Flavor", "Google"}]}
           ])
           |> get(
             "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/#{
               account
             }/token"
           ) do
      {:ok, result.body}
    end
  end

  def from_credentials(_scope, %{client_id: client, client_secret: secret, refresh_token: refresh}) do
    {:ok, result} =
      Tesla.client([
        {Tesla.Middleware.FormUrlencoded, []}
      ])
      |> post("https://www.googleapis.com/oauth2/v4/token",
        grant_type: "refresh_token",
        refresh_token: refresh,
        client_id: client,
        client_secret: secret
      )

    {:ok, result.body}
  end

  def from_credentials(scope, credentials) do
    signer = Joken.Signer.create("RS256", %{"pem" => credentials.private_key})

    {:ok, jwt} =
      %{
        "iss" => credentials.client_email,
        "scope" => scope,
        "aud" => "https://www.googleapis.com/oauth2/v4/token",
        "iat" => :os.system_time(:seconds),
        "exp" => :os.system_time(:seconds) + 10
      }
      |> Joken.Signer.sign(signer)

    {:ok, result} =
      Tesla.client([
        {Tesla.Middleware.FormUrlencoded, []}
      ])
      |> post("https://www.googleapis.com/oauth2/v4/token",
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt
      )

    {:ok, result.body}
  end
end
