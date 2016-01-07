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
    #{:ok, files} = File.ls directory
    files = get_files (File.ls directory)
    IO.inspect files
    :timer.sleep(1000)
    manage(directory)
  end

  defp get_files({:ok, contents}) do
    for item <- contents, not (File.dir?(item)), do: item
  end

  defp wait_forever() do
    wait_forever
  end
end
