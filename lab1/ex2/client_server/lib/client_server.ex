
# distributed algorithms, n.dulay, 4 jan 18
# simple client-server, v1

defmodule ClientServer do

def main do 
  IO.puts ["ClientServer at ", DNS.my_ip_addr()]
  client = Node.spawn(:'node1@container1.localdomain', Client, :start, [])
  server = Node.spawn(:'node2@container2.localdomain', Server, :start, [])
  
  send client, { :bind, server }
  send server, { :bind, client }
end

end # module -----------------------


