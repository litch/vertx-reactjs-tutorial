require "vertx"

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
    { address: 'comments.create_comment'},
    { address: 'comments.get_comments'}
  ],
  [
    { address: 'comments.all_comments' }
  ]
)

server.listen(port_number, 'localhost')

@comments = [{author: 'Sam Sneed', text: 'An example comment' }]

Vertx::EventBus.register_handler('comments.get_comments') do |message|
  message.reply({comments: @comments})
end

Vertx::EventBus.register_handler('comments.create_comment') do |message|
  @comments.push(message.body)
  Vertx::EventBus.publish('comments.all_comments', {comments: @comments})
end
