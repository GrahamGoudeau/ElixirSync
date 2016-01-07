defmodule Sync do
  #use OptionParser

  def main(args) do
    args |> parse_args |> Sync.Sync_Manager.sync
  end

  def parse_args(args) do
    {_, dirs, _} = OptionParser.parse(args)
    #IO.puts(options)
    dirs
  end
end
