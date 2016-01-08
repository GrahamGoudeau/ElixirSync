defmodule Sync do
  def main(args) do
    args |> parse_args |> process_args
  end

  defp process_args(:help) do
    IO.puts """
      Usage:
      ./sync [dir1] [dir2] [...]

      Description:
      Concurrently synchronize the contents of two or more directories
      """
  end

  defp process_args(dirs) do
    Sync.Sync_Manager.sync dirs
  end

  defp parse_args(args) do
    #{_, dirs, _} = OptionParser.parse(args)
    case OptionParser.parse(args) do
      {_, [], _} -> :help
      {[], [dir1 | [dir2 | dirs]], []} -> [dir1 | [dir2 | dirs]]
      _ -> :help
    end
  end
end
