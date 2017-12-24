defmodule BSB.StoryController do
  import Ecto.Query, only: [from: 2]

  use BSB.Web, :controller
  alias BSB.Story

  def index(conn, params) do
    ps = params
    IO.inspect(ps)

    qry =
      from(
        s in Story,
        select: s,
        order_by: [desc: :score, desc: :updated],
        where: s.read == false,
        limit: 20
      )

    stories = Repo.all(qry)

    render(conn, "index.json", stories: stories)
  end

  def create(conn, %{"story" => story_params}) do
    changeset = Story.changeset(%Story{}, story_params)

    case Repo.insert(changeset) do
      {:ok, story} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", story_path(conn, :show, story))
        |> render("show.json", story: story)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BSB.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    story = Repo.get!(Story, id)
    render(conn, "show.json", story: story)
  end

  def update(conn, %{"id" => id, "story" => story_params}) do
    story = Repo.get!(Story, id)
    changeset = Story.changeset(story, story_params)

    case Repo.update(changeset) do
      {:ok, story} ->
        render(conn, "show.json", story: story)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BSB.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    story = Repo.get!(Story, id)

    Repo.delete!(story)

    send_resp(conn, :no_content, "")
  end
end
