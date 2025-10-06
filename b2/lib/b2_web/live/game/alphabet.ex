defmodule B2Web.Live.Game.Alphabet do
  use B2Web, :live_component

  def mount(socket) do
    letters =
      ?a..?z
      |> Enum.map(&<< &1 :: utf8 >>)

    {:ok, assign(socket, letters: letters)}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-wrap gap-2">
      <%= for letter <- @letters do %>
        <div class={["badge badge-xl", classOf(letter, @tally)]}
             phx-click="make-move"
             phx-value-key={letter}>
          <%= letter %>
        </div>
      <% end %>
    </div>
    """
  end

  defp classOf(letter, tally) do
    cond do
      Enum.member?(tally.letters, letter) -> "badge-success"
      Enum.member?(tally.used, letter) -> "badge-error"
      true -> "badge-ghost"
    end
  end
end
