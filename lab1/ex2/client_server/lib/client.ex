
# distributed algorithms, n.dulay, 9 jan 18
# simple client-server, v1

defmodule Client do

def start do
  IO.puts ["      Client at ", DNS.my_ip_addr()]
  receive do
  { :bind, server } -> next(server)
  end
end

defp next(server) do
  send server, { :circle, 1.0 }
  receive do
  { :result, area } -> 
    IO.puts "Area is #{area}" 
  end
  Process.sleep(5000)
  next(server)
end

end # module -----------------------

