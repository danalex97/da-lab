
# distributed algorithms, n.dulay, 4 jan 18
# time how long it takes to create N processes and recieve an :ok reply 

defmodule Processes do

def main do
  create(100_000)
end 

defp create(n) do
  parent = self()
  start  = Time.utc_now()

  # spawn n processes - each sends an :ok message back
  Enum.map(1..n, fn(_) -> spawn(fn -> send parent, :ok end) end)

  # receive :ok messages from spawned processes
  Enum.each(1..n, &get_ok_reply/1)

  finish = Time.utc_now()
  
  duration = Time.diff(finish, start, :millisecond)

  IO.puts "Processes     = #{n}"
  IO.puts "Max processes = #{:erlang.system_info(:process_limit)}"
  IO.puts "Total time    = #{duration} milliseconds"
  IO.puts "Process time  = #{duration * 1000 /n} microseconds"
end

defp get_ok_reply(_) do
  receive do
  :ok -> :ok
  end
end

end # ---------------------------


