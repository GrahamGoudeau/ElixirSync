# ElixirSync
**Concurrently sync the contents of two or more system directories, in the style of a tool like Dropbox**
***
## Compilation
    mix escript.build
    
## Usage
    ./esync [dir1] [dir2] [...]
    
## Explanation
The script spawns two threads per directory:
* one thread to handle detecting and serving changes in the files (server threads), and
* one thread to handle fetching the changes to the files (fetcher threads)
 
The first class of thread maintains an internal state of md5 digests of the contents of the files of their respective directories.  This is done with  

    new_digests = build_digests_map new_files_list
    ...
    defp build_digests_map(files) do
      Enum.map(files, &({&1, get_digest(&1)})) |> Enum.into %{}
    end

    defp get_digest(file) do
      {:ok, contents} = File.read file
      :crypto.hash(:md5, contents)
    end


Then the server threads compute which files have changed:
    
    updated_files = for file <- new_files_list,
          Map.get(new_digests, file, nil) != Map.get(old_file_digests, file, nil),
          do: file

The fetcher threads simply receive messages and write or delete files as necessary:

    defp fetch_loop(dir, time_delay) do
      receive do
        {:update, filename, contents} -> spawn_link(__MODULE__, :handle_fetch_update, [dir, filename, contents])
        {:delete, filename} -> spawn_link(__MODULE__, :handle_fetch_delete, [dir, filename])
      end
      :timer.sleep(time_delay)
      fetch_loop(dir, time_delay)
    end

## Challenges
Some of the challenges inherent in a problem like this:
* avoiding having theads serve changes to the directory where those changes originated from, which would result in an infinite loop of changing and serving
* communicating across concurrent processes

And how these challenges were solved:
* The fetching threads are stored initially with a string containing the name of the directory that they are updating.  Then when the server threads are started, they are given a list of all the existing fetch threads, and select only those directory/PID pairs where the directory does not match the server thread's respective directory.  Then they serve their changes only to those fetch threads.
* Elixir's `send/2` function allows for easy communication across processes.  Since the server threads have a list of all the acceptable fetch threads to serve to, they call my module's function `broadcast/2` with their list of threads to serve the updated content:


    
        defp broadcast([], _) do end
        defp broadcast([recipient | recipients], message) do
          send recipient, message
          broadcast(recipients, message)
        end
