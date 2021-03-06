//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/23.
//

import Foundation
import EosioSwift

public struct NetworkConfiguration {
  var networkId: String //{get set}
  var registryContract: String //{get set}
  var rpcEndpoint: String //{get set}
  
  public init(networkId: String, registryContract: String, rpcEndpoint: String) {
    self.networkId = networkId
    self.registryContract = registryContract
    self.rpcEndpoint = rpcEndpoint
  }
}

public struct MultiNetworkConfiguration {
  var networks: [NetworkConfiguration]? //{get set}
  var noRevocationCheck: Bool //{get set}
  
  public init(networks: [NetworkConfiguration]?, noRevocationCheck: Bool) {
    self.networks = networks
    self.noRevocationCheck = noRevocationCheck
  }
}

public typealias ConfigurationOptions = MultiNetworkConfiguration

public struct ConfiguredNetwork {
  var jsonRPC: EosioRpcProvider? //{get set}
  var regisrtyContract: String //{get set}
  
  public init(jsonRpc: EosioRpcProvider?, registryContract: String) {
    self.jsonRPC = jsonRpc
    self.regisrtyContract = registryContract
  }
}

public typealias ConfiguredNetworks = [String: ConfiguredNetwork]

public func configureNetwork(net: NetworkConfiguration) -> ConfiguredNetwork {
  let registryContract = net.registryContract
  let jsonRPC = EosioRpcProvider(endpoint: URL(string:net.rpcEndpoint)!)
  
  return ConfiguredNetwork(jsonRpc: jsonRPC, registryContract: registryContract)
}

public func configureNetworks(conf: MultiNetworkConfiguration) -> ConfiguredNetworks {
  var networks: [String:ConfiguredNetwork] = [:]
  
  guard let network = conf.networks else { return [:] }
  network.enumerated().forEach { index, value in
    let net = network[index]
    networks[net.networkId] = configureNetwork(net: net)
    
    if networks[net.networkId]?.jsonRPC == nil {
      iPrint(NSError.init().localizedDescription)
    }
  }
  
  return networks
}

public func configureResolverWithNetworks(conf: ConfigurationOptions ) -> ConfiguredNetworks {
  let networks = configureNetworks(conf: conf)

  guard let network = conf.networks else { return networks }

  network.forEach {
    if networks[$0.networkId] == nil {
      iPrint(NSError.init().localizedDescription)
    }
  }
  
  if networks.keys.count == 0 {
    iPrint(NSError.init().localizedDescription)
  }
  
  return networks
}
