defmodule Sync.Sync_Manager do
  def sync(dirs) do
    spawn_threads(dirs)
    wait_forever
  end

  defp spawn_threads([]) do
  end

  defp spawn_threads([dir | dirs]) do
    pid = spawn(__MODULE__, :manage, [dir])
    spawn_threads dirs
  end

  def manage(directory) do
    files = get_files directory
    IO.inspect files
    :timer.sleep(1000)
    manage(directory)
  end

  defp get_files(dir) do
    dir |> get_dir_contents |> Enum.filter &(not File.dir?(&1))
  end

  defp get_dir_contents(dir) do
    {:ok, content} = File.ls dir
    full_path = dir |> Path.absname |> Path.expand

    # return the contens with their full paths
    for item <- content, do: full_path <> "/" <> item
  end

  defp wait_forever() do
    wait_forever
  end
end
