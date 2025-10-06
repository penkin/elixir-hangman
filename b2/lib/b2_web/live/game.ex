defmodule B2Web.Live.Game do
  use B2Web, :live_view

  def mount(_params, _session, socket) do
    game = Engine.new_game()
    tally = Engine.tally(game)

    socket =
      socket
      |> assign(%{game: game, tally: tally})

    {:ok, socket}
  end

  def handle_event("make-move", %{"key" => key}, socket) do
    tally = Engine.make_move(socket.assigns.game, key)
    {:noreply, assign(socket, :tally, tally)}
  end

  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 sm:py-28 lg:px-8 xl:px-28 xl:py-32">
      <div class="mx-auto max-w-xl lg:mx-0">
        <div class="mt-10 flex justify-between items-center">
          <div class="flex gap-4" phx-window-keyup="make-move">
            <div class="flex-1">
              <.live_component module={B2Web.Live.Game.Figure} id="hangman-figure" tally={@tally} />
            </div>
            <div class="flex flex-1 flex-col justify-center">
              <.live_component module={B2Web.Live.Game.Alphabet} id="hangman-alphabet" tally={@tally} />
              <.live_component module={B2Web.Live.Game.WordSoFar} id="hangman-word-so-far" tally={@tally} />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
