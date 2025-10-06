defmodule B2Web.Live.Game.WordSoFar do
  use B2Web, :live_component

  @states %{
    already_used: "You already picked that letter",
    bad_guess: "That's not in the word",
    good_guess: "Good guess!",
    initialising: "Type or click on your first guess",
    lost: "Sorry, you lost...",
    won: "You won!"
  }

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="divider"></div>
      <div class="state">
        {state_name(@tally.game_state)}
      </div>
      <div class="divider"></div>
      <div class="flex gap-1">
        <%= for letter <- @tally.letters do %>
          <div class={["badge badge-xl", if(letter != "_", do: "badge-success", else: "badge-ghost")]}>
            <%= letter %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp state_name(state) do
    @states[state] || "Unknown game state."
  end
end
