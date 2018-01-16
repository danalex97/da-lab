
# distributed algorithms, n.dulay, 4 jan 18
# simple client-server, v1

defmodule Server do
 
def start do 
  IO.puts ["      Server at ", DNS.my_ip_addr()]
  receive do
  { :bind, client } -> next(client) 
  end
end # start
 
def next(client) do
  receive do
  { :circle, radius } -> 
    send client, { :result, 3.14159 * radius * radius }
  { :square, side } -> 
    send client, { :result, side * side }
  end
  next(client)
end # next

end # module -----------------------

