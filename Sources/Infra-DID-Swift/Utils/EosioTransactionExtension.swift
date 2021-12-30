//
//  EosioTransactionExtension.swift
//  
//
//  Created by CentLee on 2021/12/22.
//

import Foundation
import EosioSwift
import EosioSwiftSoftkeySignatureProvider


// MARK: extension EosioTransaction
  /**
   
   This is an extended version of transaction to make a transaction using the getblock api.
   
   */
extension EosioTransaction {
  
  
  public func signBroadCastWithGetBlock(completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    signWithGetBlock { [weak self] (result) in
      guard let strongSelf = self else {
        return completion(.failure(EosioError(.unexpectedError, reason: "self does not exist")))
      }
      guard let _ = strongSelf.rpcProvider else {
        return completion(.failure(EosioError(.unexpectedError, reason: "rpcProvider does not exist")))
      }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success:
        strongSelf.broadcast(completion: completion)
      }
    }
  }
  
  fileprivate func signWithGetBlock(prompt: String = "Sign Transaction", completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    guard let signatureProvider = signatureProvider else {
      return completion(.failure(EosioError(.signatureProviderError, reason: "No signature provider available")))
    }
    signatureProvider.getAvailableKeys { [weak self] (response) in
      guard let availableKeys = response.keys else {
        return completion(.failure(response.error ?? EosioError(.signatureProviderError, reason: "Unable to get available keys from signature provider")))
      }
      guard let strongSelf = self else {
        return completion(.failure(EosioError(.unexpectedError, reason: "self does not exist")))
      }
      strongSelf.signWithGetBlock(availableKeys: availableKeys, prompt: prompt, completion: completion)
    }
  }
  
  fileprivate func signWithGetBlock(availableKeys: [String], prompt: String = "Sign Transaction", completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    
    prepareWithGetBlock{ [weak self] (result) in
      guard let strongSelf = self else {
        return completion(.failure(EosioError(.unexpectedError, reason: "self does not exist")))
      }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success:
        strongSelf.signPreparedTransactionWithGetBlock(availableKeys: availableKeys, prompt: prompt, completion: completion)
      }
    }
  }
  
  fileprivate func signPreparedTransactionWithGetBlock(availableKeys: [String], prompt: String, completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    guard let rpcProvider = rpcProvider else {
      return completion(.failure(EosioError(.signatureProviderError, reason: "No rpc provider available")))
    }
    
    let requiredKeysRequest = EosioRpcRequiredKeysRequest(availableKeys: availableKeys, transaction: self)
    rpcProvider.getRequiredKeysBase(requestParameters: requiredKeysRequest) { (response) in
      switch response {
      case .failure(let error):
        completion(.failure(error))
      case .success(let requiredKeys):
        self.sign(publicKeys: requiredKeys.requiredKeys, prompt: prompt, completion: completion)
      }
    }
  }
  
  fileprivate func prepareWithGetBlock(completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    getInfoAndSetValuesWithGetBlock{ [weak self] (taposResult) in
      switch taposResult {
      case .failure(let error):
        completion(.failure(error))
      case .success:
        guard let strongSelf = self else {
          return completion(.failure(EosioError(.unexpectedError, reason: "self does not exist")))
        }
        strongSelf.serializeActionData(completion: completion)
      }
    }
  }
  
  fileprivate func getInfoAndSetValuesWithGetBlock(completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    // if all the data is set, just return true
    if refBlockNum > 0 && refBlockPrefix > 0  && chainId != "" && expiration > Date(timeIntervalSince1970: 0) {
      return completion(.success(true))
    }
    
    // if no rpcProvider available, return error
    guard let rpcProvider = rpcProvider else {
      return completion(.failure(EosioError(.eosioTransactionError, reason: "No rpc provider available")))
    }
    
    // get chain info
    rpcProvider.getInfoBase { [weak self] (infoResponse) in
      guard let strongSelf = self else {
        return completion(.failure(EosioError(.getInfoError, reason: "self does not exist")))
      }
      switch infoResponse {
      case .failure(let error):
        completion(.failure(error))
      case .success(let info):
        if strongSelf.chainId == "" {
          strongSelf.chainId = info.chainId
        }
        // return an error if provided chainId does not match info chainId
        guard strongSelf.chainId == info.chainId else {
          return completion(.failure(EosioError(.eosioTransactionError, reason: "Provided chain id \(strongSelf.chainId) does not match chain id \(info.chainId)")))
        }
        
        // if expiration not set, set by adding config.expireSeconds to head block time
        if strongSelf.expiration <= Date(timeIntervalSince1970: 0) {
          guard let headBlockTime = Date(yyyyMMddTHHmmss: info.headBlockTime) else {
            return completion(.failure(EosioError(.eosioTransactionError, reason: "Invalid head block time \(info.headBlockTime)")))
          }
          strongSelf.expiration = headBlockTime.addingTimeInterval(TimeInterval(strongSelf.config.expireSeconds))
        }
        
        // Default to using last irreversiable block
        var blockNum = info.lastIrreversibleBlockNum.value
        
        if strongSelf.config.useLastIrreversible == false {
          let blocksBehind = UInt64(strongSelf.config.blocksBehind)
          blockNum = info.headBlockNum.value - blocksBehind
          if blockNum <= 0 {
            blockNum = 1
          }
        }
        strongSelf.getBlockAndSetTaposWithGetBlock(rpcProvider: (rpcProvider as! EosioRpcProvider), blockNum: blockNum, completion: completion)
      }
    }
  }
  
  fileprivate func getBlockAndSetTaposWithGetBlock(rpcProvider: EosioRpcProvider?, blockNum: UInt64, completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    
    // if the only data needed was the chainId, return now
    if self.refBlockPrefix > 0 && self.refBlockNum > 0 {
      return completion(.success(true))
    }

    guard let rpcProvider = rpcProvider else {
      return completion(.failure(EosioError(.unexpectedError, reason: "rpcProvider does not exist")))
    }
    
    rpcProvider.getBlock(requestParameters: EosioRpcBlockRequest(blockNumOrId: blockNum), completion: { [weak self] (blockResponse) in
      guard let strongSelf = self else {
        return completion(.failure(EosioError(.getBlockError, reason: "self does not exist")))
      }
      switch blockResponse {
      case .failure(let error):
        completion(.failure(error))
      case .success(let block):
        // set tapos fields and return
        strongSelf.refBlockNum = UInt16(block.blockNum.value & 0xffff)
        strongSelf.refBlockPrefix = block.refBlockPrefix.value
        return completion(.success(true))
      }
    })
  }
  
  
}
