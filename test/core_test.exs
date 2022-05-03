# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
defmodule CoreTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Core.Router.init([])

  # TODO change it with proper response
  test "returns 404 with wrong request" do
    # Create a test connection
    conn = conn(:get, "/badrequest")

    # Invoke the plug
    conn = Core.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "oops"
  end

  describe "when receiving invoke request" do
    test "if _/fn/:name invoke :name on _ namespace" do
      # Create a test connection
      conn = conn(:get, "/_/fn/hello")

      # Invoke the plug
      conn = Core.Router.call(conn, @opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "hello invoked"
    end

    # TODO test e.g. with 1 worker available -> invoke chooses that worker.
  end
end
