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
defmodule Worker.Adapters.Requests.Cluster do
  @moduledoc """
  Contains functions exposing the Worker API to other processes/nodes in the cluster.
  """
  alias Worker.Domain.Api

  @doc """
    Creates a container for the given `function`, using the underlying Api.prepare_container(). The result is forwarded to the original sender.

    ## Parameters
      - function: struct containing function information; no specific struct is required, but it should contain all fields defined in Worker.Domain.Function
      - from: (sender, ref) couple, generally obtained in GenServer.call(), where this function is normally spawned
  """
  def prepare(function, from) do
    result = Api.prepare_container(function)
    GenServer.reply(from, result)
  end

  @doc """
    Runs the given `function` using the underlying Api.run_function(), if an associated container exists;
    if no container is found, creates the required container and runs the function.
    Any error encountered by the API calls is forwarded to the sender.

    ## Parameters
      - function: struct containing function information; no specific struct is required, but it should contain all fields defined in Worker.Domain.Function
      - args: arguments passed to the function
      - from: (sender, ref) couple, generally obtained in GenServer.call(), where this function is normally spawned
  """
  def invoke(function, args, from) do
    result =
      if Api.function_has_container?(function) do
        Api.run_function(function, args)
      else
        case Api.prepare_container(function) do
          {:ok, _} -> Api.run_function(function, args)
          {:error, err} -> {:error, err}
        end
      end

    GenServer.reply(from, result)
  end

  @doc """
    Deletes the first container wrapping `function`, calling the underlying Api.cleanup(). The result is forwarded to the original sender.

    ## Parameters
      - function: struct containing function information; no specific struct is required, but it should contain all fields defined in Worker.Domain.Function
      - from: (sender, ref) couple, generally obtained in GenServer.call(), where this function is normally spawned
  """
  def cleanup(function, from) do
    result = Api.cleanup(function)
    GenServer.reply(from, result)
  end
end
