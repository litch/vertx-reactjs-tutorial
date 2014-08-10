require "vertx"
require 'benchmark'

include Vertx

logger = Vertx.logger
port_number = 8080

logger.info "Webapp loading, port #{port_number}..."

server = Vertx::HttpServer.new

server.request_handler do |req|
  file = ''
  logger.debug(req)
  if req.path == '/'
    file = 'index.html'
  elsif !req.path.include?('..')
    file = req.path
  end
  req.response.send_file('./web/' + file)
end

sockJSServer = Vertx::SockJSServer.new(server)

sockJSServer.bridge({'prefix' => '/eventbus'},
  [
    { address: 'orders.place_a_bunch_of_orders'},
    { address: 'orders.get_order_book'}
  ],
  [
    { address: 'orders.order_book_summary'},
    { address: 'orders.fill_summary'}
  ])

server.listen(port_number, 'localhost')
