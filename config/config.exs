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

import Config

config :worker, Worker.Domain.Ports.Runtime.Provisioner,
  adapter: Worker.Adapters.Runtime.Wasm.Provisioner

config :worker, Worker.Domain.Ports.Runtime.Runner, adapter: Worker.Adapters.Runtime.Wasm.Runner
config :worker, Worker.Domain.Ports.Runtime.Cleaner, adapter: Worker.Adapters.Runtime.Wasm.Cleaner

config :worker, Worker.Domain.Ports.Runtime.Supervisor,
  adapter: Worker.Adapters.Runtime.Wasm.Supervisor

config :worker, Worker.Domain.Ports.ResourceCache, adapter: Worker.Adapters.ResourceCache

config :logger, :console,
  format: "\n#####[$level] $time $metadata $message\n",
  metadata: [:file, :line]

config :libcluster,
  topologies: [
    funless: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Gossip
    ]
  ]

config :os_mon,
  start_cpu_sup: true,
  start_memsup: true,
  start_disksup: false,
  start_os_sup: false,
  memsup_system_only: true

config :worker, Worker.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: [
    port: 4021,
    # This is an optional setting and will default to `"/metrics"`
    path: "/metrics",
    # This is an optional setting and will default to `:http`
    protocol: :http,
    # This is an optional setting and will default to `5`
    pool_size: 5,
    # This is an optional setting and will default to `[]`
    cowboy_opts: [],
    # This is an optional and will default to `:none`
    auth_strategy: :none
  ]

import_config "#{Mix.env()}.exs"
