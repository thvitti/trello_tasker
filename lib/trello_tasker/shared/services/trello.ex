defmodule TrelloTasker.Shared.Services.Trello do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.trello.com/1/cards"
  plug Tesla.Middleware.Headers, [{"User-Agent", "request"}]
  plug Tesla.Middleware.JSON



  @token Application.get_env(:trello_tasker, :trello)[:token]
  @key Application.get_env(:trello_tasker, :trello)[:key]

  def get_comments(card_id) do
    {:ok, response} = card_id
                      |> get_url_comment()
                      |> get()

    case response do
      %Tesla.Env{status: 200, body: body} ->
        data = body
               |> Enum.map( &%{
                                text: &1["data"]["text"],
                                user: &1["memberCreator"]["username"]
                                } )
      %Tesla.Env{status: 404 } ->
        {:error, "erro ao buscar comments"}

    end

  end

  def get_card(card_id) do
    {:ok, response} = card_id
                      |> get_url_card()
                      |> get()

      case response do
        %Tesla.Env{status: 200, body: body} ->
          name        = body["name"]
          description = body["desc"]
          image       = body["cover"]["sharedSourceUrl"]
          card_id     = body["shortLink"]
          completed   = body["dueComplete"]
          delivery_date = get_date( body["due"] )


          data = %{
            name: name,
            description: description,
            image: image,
            card_id: card_id,
            completed: completed,
            delivery_date: delivery_date
          }

          # {:ok, data}

        %Tesla.Env{status: _ } ->
          {:error, "erro ao buscar info"}

      end
  end

  defp get_date(nil),  do: nil

  defp get_date(due)  do
    result = due
             |> DateTime.from_iso8601()

    case result do
      {:ok, delivery_date, _} ->
        delivery_date
        |> DateTime.to_date()
      {:error, _} ->
        nil
    end

  end

  def get_url_card(card_id) do
    "#{card_id}" <> "?list=true"
    |> put_token
  end

  def get_url_comment(card_id) do
    "#{card_id}" <> "/actions?commentCard"
    |> put_token
  end

  def put_token(url) do
    url <> "&key=#{@key}" <> "&token=#{@token}"
  end

end
