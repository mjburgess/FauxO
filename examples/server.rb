require 'socket'
require_relative '../action'



class HttpServer
  attr_accessor :headers

  HDR_NL = "\r\n"

  def initialize(host = 'localhost', port = 8080)
    @server  = TCPServer.new host, port
    @headers = ['HTTP/1.1 200 OK', 'Content-Type: text/plain', 'Content-Length: ']
  end

  def serve(len, &app)
    loop do
      Thread.start(@server.accept) do |client|
        client.write headers.join(HDR_NL) + len.to_s + HDR_NL + HDR_NL
        app.call(client)
        client.close
      end
    end
  end
end


class HttpServerGraft < HttpServer
  def serve(len, &action_aware_app)
    super.serve(len) do |client|
      action_aware_app.call(WriteAction.from_writable client)
    end
  end
end

class Greetings
  def hello
    'Hello!'
  end
end


svr = HttpServerGraft.new
gg = Greetings.new

svr.serve(gg.hello.length) do |writer|
  writer.write(gg.hello)
end


