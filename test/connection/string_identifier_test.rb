require 'test_helper'
require 'stubs/test_server'

class ActionCable::Connection::StringIdentifierTest < ActiveSupport::TestCase
  class Connection < ActionCable::Connection::Base
    identified_by :current_token

    def connect
      self.current_token = "random-string"
    end
  end

  setup do
    @server = TestServer.new

    env = Rack::MockRequest.env_for "/test", 'HTTP_CONNECTION' => 'upgrade', 'HTTP_UPGRADE' => 'websocket'
    @connection = Connection.new(@server, env)
  end

  test "connection identifier" do
    open_connection_with_stubbed_pubsub
    assert_equal "random-string", @connection.connection_identifier
  end

  protected
    def open_connection_with_stubbed_pubsub
      @server.stubs(:pubsub_pool).returns(stub_everything('pubsub'))
      open_connection
    end

    def open_connection
      @connection.process
      @connection.send :on_open
    end

    def close_connection
      @connection.send :on_close
    end
end
