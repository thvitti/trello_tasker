defmodule TrelloTaskerWeb.CardInfoLive do
  use TrelloTaskerWeb, :live_view

  alias Phoenix.View
  alias TrelloTaskerWeb.CardView
  alias TrelloTasker.Shared.Services.Trello

  @impl true
  def mount(%{"id" => id}, _session, socket) do

    info      = Trello.get_card(id)
    comments  = Trello.get_comments(id)

    params = %{
      comments: comments,
      info: info
    }

    {:ok, assign(socket, params)}
  end

  @impl true
  def render(assigns) do
    View.render(CardView, "info.html", assigns)
  end

end
