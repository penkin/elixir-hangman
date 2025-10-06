defmodule MemoryWeb.Live.MemoryDisplay do
  use MemoryWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, schedule_tick(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, schedule_tick(socket)}
  end

  def render(assigns) do
    ~H"""
    <.table id="memory" rows={@memory}>
      <:col :let={item} label="id">{elem(item, 0)}</:col>
      <:col :let={item} label="username">{elem(item, 1)}</:col>
    </.table>
    """
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 1000)
    assign(socket, :memory, :erlang.memory())
  end
end
