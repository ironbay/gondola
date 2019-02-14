defmodule Gondola.Config do
  def method() do
    case Application.get_env(:gondola, :method) do
      nil ->
        compute_method()

      method ->
        method
    end
  end

  def compute_method() do
    method =
      cond do
        from_env() != nil ->
          data =
            from_env()
            |> File.read!()
            |> Jason.decode!(keys: :atoms)

          Application.put_env(:gondola, :credentials, data)
          :credentials

        credentials() != nil ->
          :credentials

        true ->
          :metadata
      end

    Application.put_env(:gondola, :method, method)
    method
  end

  def from_env() do
    System.get_env("GOOGLE_APPLICATION_CREDENTIALS")
  end

  def credentials() do
    Application.get_env(:gondola, :credentials)
  end
end
