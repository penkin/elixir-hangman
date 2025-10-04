defmodule TextClient.Runtime.RemoteHangman do
  @remote_server :"hangman@Christophers-MacBook-Pro"

  def connect() do
    :rpc.call(@remote_server, Engine, :new_game, [])
  end
end
