# Copyright 2023 Giuseppe De Palma, Matteo Trentin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule Core.Domain.Scheduler do
  @moduledoc """
  Scheduler for the funless platform. It is used to choose a worker to run a function.
  """

  alias Core.Domain.Policies.SchedulingPolicy
  alias Core.Domain.Ports.Telemetry.Metrics
  require Logger

  @type worker_atom :: atom()

  @doc """
  Receives a list of workers and chooses one which can be used for invocation.
  """
  @spec select([worker_atom()], Data.FunctionStruct.t()) ::
          {:ok, worker_atom()} | {:error, :no_workers} | {:error, :no_valid_workers}
  def select([], _) do
    Logger.warn("Scheduler: tried selection with NO workers")
    {:error, :no_workers}
  end

  def select([w], _) do
    Logger.info("Scheduler: selection with only one worker #{inspect(w)}")
    {:ok, w}
  end

  def select(workers, function) do
    Logger.info("Scheduler: selection with #{length(workers)} workers")

    # Get the resources
    resources =
      Enum.map(workers, &Metrics.resources/1)
      |> Enum.filter(&match?({:ok, _}, &1))
      |> Enum.map(&elem(&1, 1))

    case resources do
      [] ->
        # If resources are unavailable for some reason, pick a random worker
        {:ok, Enum.random(workers)}

      [_ | _] ->
        # This will be expanded to allow use of multiple policies (depending on function metadata)
        case SchedulingPolicy.select(
               %Data.Configurations.Empty{},
               resources,
               function
             ) do
          {:ok, wrk} -> {:ok, wrk.name}
          {:error, err} -> {:error, err}
        end
    end
  end
end
