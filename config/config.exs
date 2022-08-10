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

import Config

config :worker, Worker.Domain.Ports.Runtime, adapter: Worker.Adapters.Runtime.OpenWhisk
config :worker, Worker.Domain.Ports.RuntimeTracker, adapter: Worker.Adapters.RuntimeTracker.ETS

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

import_config "#{Mix.env()}.exs"
