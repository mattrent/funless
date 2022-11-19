# Copyright 2022 Giuseppe De Palma, Matteo Trentin
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

defmodule Core.Domain.Api.FunctionRepo do
  @moduledoc """
  Provides functions to interact with creation and deletion of FunctionStruct on FunctionStore.
  """

  require Logger
  alias Core.Domain.Api.Utils
  alias Core.Domain.FunctionStruct
  alias Core.Domain.Ports.FunctionStore

  @doc """
  Stores a new function in the FunctionStore.

  ## Parameters
  - `function`: FunctionStruct to be stored.

  ## Returns
  - `{:ok, function_name}`: if the function was successfully stored.
  - `{:error, :bad_params}`: if the function is not a valid FunctionStruct.
  - `{:error, {:aborted, reason}}`: if the function could not be stored.
  """
  @spec new(FunctionStruct.t()) ::
          {:ok, String.t()} | {:error, :bad_params} | {:error, {:bad_insert, any}}
  def new(%{"name" => name, "code" => code} = raw_params) do
    namespace = Map.get(raw_params, "namespace") |> Utils.validate_namespace()

    function = %FunctionStruct{
      name: name,
      namespace: namespace,
      code: code
    }

    Logger.info("API: create request for function #{name} in namespace #{function.namespace}")

    function
    |> FunctionStore.insert_function()
    |> parse_create_result(name)
  end

  def new(_), do: {:error, :bad_params}

  @doc """
  Deletes a function from the FunctionStore.

  ## Parameters
  - function: The function struct with the name and namespace of the function to delete.

  ## Returns
  - `{:ok, function_name}`: if the function was successfully deleted.
  - `{:error, :bad_params}`: if the function is not a valid FunctionStruct.
  - `{:error, {:bad_delete, reason}}`: if the function could not be deleted.
  """
  @spec delete(FunctionStruct.t()) ::
          {:ok, String.t()} | {:error, :bad_params} | {:error, {:bad_delete, any}}
  def delete(%{"name" => name} = raw_params) do
    namespace = Map.get(raw_params, "namespace") |> Utils.validate_namespace()

    Logger.info("API: delete request for function #{name} in namespace #{namespace}")

    case FunctionStore.exists?(name, namespace) do
      true ->
        FunctionStore.delete_function(name, namespace)
        |> parse_delete_result(name)

      false ->
        {:error, {:bad_delete, :not_found}}
    end
  end

  def delete(_), do: {:error, :bad_params}

  @spec parse_create_result({:ok, String.t()} | {:error, {:aborted, any}}, String.t()) ::
          {:ok, String.t()} | {:error, {:bad_insert, any}}
  defp parse_create_result({:error, {:aborted, reason}}, f_name) do
    Logger.error("API: create request for function #{f_name} failed: #{inspect(reason)}")
    {:error, {:bad_insert, reason}}
  end

  defp parse_create_result(result, f_name) do
    Logger.info("API: create returned #{inspect(result)} for function #{f_name}")
    result
  end

  @spec parse_delete_result({:ok, String.t()} | {:error, {:aborted, any}}, String.t()) ::
          {:ok, String.t()} | {:error, {:bad_delete, any}}
  def parse_delete_result({:error, {:aborted, reason}}, f_name) do
    Logger.error("API: delete request for function #{f_name} failed: #{inspect(reason)}")
    {:error, {:bad_delete, reason}}
  end

  def parse_delete_result(result, f_name) do
    Logger.info("API: delete returned #{inspect(result)} for function #{f_name}")
    result
  end

  @spec list(map) :: {:ok, [String.t()]} | {:error, {:bad_list, any}} | {:error, :bad_params}
  def list(%{"namespace" => namespace}) do
    namespace
    |> FunctionStore.list_functions()
    |> parse_list_result
  end

  def list(_) do
    {:error, :bad_params}
  end

  @spec parse_list_result({:ok, [String.t()]} | {:error, {:aborted, any}}) ::
          {:ok, [String.t()]} | {:error, {:bad_list, any}}
  def parse_list_result({:ok, l}) do
    {:ok, l}
  end

  def parse_list_result({:error, {:aborted, reason}}) do
    {:error, {:bad_list, reason}}
  end
end
