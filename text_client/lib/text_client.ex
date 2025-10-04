defmodule TextClient do
  alias TextClient.Impl.Player

  @spec start() :: :ok
  def start() do
    TextClient.Runtime.RemoteHangman.connect()
    |> Player.start()
  end
end
