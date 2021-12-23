//
//  EosioTransactionExtension.swift
//  
//
//  Created by CentLee on 2021/12/22.
//

import Foundation
import EosioSwift



extension EosioTransaction {
  
  public func broadcastWithGetBlock(rpcProvider: EosioRpcProvider?, completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    guard let serializedTransaction = serializedTransaction, let signatures = signatures, signatures.count > 0 else {
      return completion(.failure(EosioError(.eosioTransactionError, reason: "Transaction must be signed before broadcast")))
    }
    guard let rpcProvider = rpcProvider else {
      return completion(.failure(EosioError(.eosioTransactionError, reason: "No rpc provider available")))
    }
    var sendTransactionRequest = EosioRpcSendTransactionRequest()
    
    sendTransactionRequest.packedTrx = serializedTransaction.hex
    sendTransactionRequest.signatures = signatures
    sendTransactionRequest.packedContextFreeData = serializedContextFreeData.hex
    //sendTransactionRequest.compression = 
    rpcProvider.sendTransaction(requestParameters: sendTransactionRequest) { [weak self] (response) in
      guard let strongSelf = self else {
        return completion(.failure(EosioError(.unexpectedError, reason: "self does not exist")))
      }
      switch response {
      case .failure(let error):
        completion(.failure(error))
      case .success(let pushTransactionResponse):
        //strongSelf.transactionId = pushTransactionResponse.transactionId
        let returnActionValues = pushTransactionResponse.returnActionValues()
        print("Action Return Values: \(String(describing: returnActionValues))")
        strongSelf.actions.enumerated().forEach { (index, action) in
          if returnActionValues.indices.contains(index) {
            //action.returnValue = returnActionValues[index]
          }
        }
        return completion(.success(true))
      }
    }
  }
  
  public func signBroadCastWithGetBlock(rpcProvider: EosioRpcProvider?, completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    //    guard let rpcProvider = rpcProvider else {
    //      return completion(.failure(EosioError(.unexpectedError, reason: "rpcProvider does not exist")))
    //    }
    signWithGetBlock { [weak self] (result) in
      guard let strongSelf = self else {
        return completion(.failure(EosioError(.unexpectedError, reason: "self does not exist")))
      }
      //      guard let rpcProvider = rpcProvider else {
      //        return completion(.failure(EosioError(.unexpectedError, reason: "rpcProvider does not exist")))
      //      }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success:
        strongSelf.broadcastWithGetBlock(rpcProvider: rpcProvider, completion: completion)
      }
    }
  }
  
  public func signWithGetBlock(prompt: String = "Sign Transaction", completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
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
  
  public func signWithGetBlock(availableKeys: [String], prompt: String = "Sign Transaction", completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    
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
  
  private func signPreparedTransactionWithGetBlock(availableKeys: [String], prompt: String, completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
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
  
  private func prepareWithGetBlock(completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
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
  
  private func getInfoAndSetValuesWithGetBlock(completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    //    guard let rpcProvider = rpcProvider else {
    //      return completion(.failure(EosioError(.unexpectedError, reason: "rpcProvider does not exist")))
    //    }
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
        strongSelf.getBlockAndSetTaposWithGetBlock(rpcProvider: rpcProvider as! EosioRpcProvider, blockNum: blockNum, completion: completion)
      }
    }
  }
  
  public func getBlockAndSetTaposWithGetBlock(rpcProvider: EosioRpcProvider?, blockNum: UInt64, completion: @escaping (EosioResult<Bool, EosioError>) -> Void) {
    
    // if the only data needed was the chainId, return now
    if self.refBlockPrefix > 0 && self.refBlockNum > 0 {
      return completion(.success(true))
    }
    // if no rpcProvider available, return error
    //      guard let rpcProvider = rpcProviderWithoutProtocol else {
    //          return completion(.failure(EosioError(.eosioTransactionError, reason: "No rpc provider available")))
    //      }
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

//extension EosioRpcProviderProtocol  {
//
//
//  func getBlocks(requestParameters: EosioRpcBlockRequest, completion: @escaping (EosioResult<EosioRpcBlockResponse, EosioError>) -> Void) {
//    getResource(rpc: "chain/get_block", requestParameters: requestParameters) {(result: EosioRpcBlockInfoResponse?, error: EosioError?) in
//      completion(EosioResult(success: result, failure: error)!)
//    }
//  }
//
//}
//
//extension EosioRpcProvider: EosioRpcProviderProtocol {
//  func getBlocks(requestParameters: EosioRpcBlockRequest, completion: @escaping (EosioResult<EosioRpcBlockResponse, EosioError>) -> Void) {
//    getResource(rpc: "chain/get_block", requestParameters: requestParameters) {(result: EosioRpcBlockInfoResponse?, error: EosioError?) in
//        completion(EosioResult(success: result, failure: error)!)
//    }
//  }
//}
