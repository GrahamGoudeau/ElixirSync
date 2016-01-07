defmodule Sync.Sync_Manager do
  def sync(dirs) do
    spawn_threads(dirs)
    wait_forever
  end

  defp spawn_threads([]) do
    IO.puts('done spawning')
  end

  defp spawn_threads([dir | dirs]) do
    pid = spawn(__MODULE__, :manage, [dir])
    spawn_threads dirs
  end

  def manage(directory) do
    files = get_files directory
    IO.inspect files
    :timer.sleep(1000)
    IO.puts('done')
  end

  defp get_files(directory) do
    result = case File.ls directory do
      {:ok, files} -> files
      {:error, reason} -> reason
    end
    IO.inspect result
    result
  end

  defp wait_forever() do
    wait_forever
  end
end
