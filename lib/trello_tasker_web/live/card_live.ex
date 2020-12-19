defmodule TrelloTaskerWeb.CardLive do
  use TrelloTaskerWeb, :live_view

  alias Phoenix.View
  alias TrelloTasker.Cards.Card
  alias TrelloTasker.Cards
  alias TrelloTaskerWeb.CardView
  alias TrelloTasker.Shared.Services.Trello

  @impl true
  def mount(_params, _session, socket) do

    changeset =
        %Card{}
        |> Card.changeset()

    cards =
      Cards.list_cards()
      |> Enum.map( &Trello.get_card(&1.path) )

    params = %{
        changeset: changeset,
        cards: cards
    }

    {:ok, assign(socket,params) }



  end

  @impl true
  def render(assigns) do
    View.render(CardView, "index.html", assigns)
  end

  def handle_event("create", %{"card" => card} , socket) do

    changeset =
      %Ecto.Changeset{Card.changeset( %Card{}, card ) | action: :insert}

      case changeset.valid? do
        false ->
          socket =
              socket
              |> clear_flash()
              |> assign(changeset: changeset)

          {:noreply, socket}

        true ->
          result = card["path"]
                    |> Trello.get_card


          case result do
            {:error, msg} ->

              socket =
                socket
                |> clear_flash()
                |> put_flash(:error, msg)
                |> assign(changeset: changeset)
                |> push_redirect(to: "/")

              {:noreply, socket}

            card_info ->
              card
              |> Cards.create_card()
              |> response(socket)
          end
      end
  end

  defp response({:ok, _card}, socket) do
    socket =
      socket
      |> put_flash(:info, "Card gravado com sucesso!")
      |> push_redirect(to: "/")

    {:noreply, socket}
  end

  defp response({:error, changeset}, socket) do
    socket =
      socket
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

end
