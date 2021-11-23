//
//  File.swift
//
//
//  Created by SatGatLee on 2021/11/19.
//

import Foundation
import PromiseKit

public protocol Resolvable {
  func resolve(didUrl: String, options: DIDResolutionOptions?) -> Promise<DIDResolutionResult>
}


public class Resolver {
  
  private var resolverRegistry: ResolverRegistry = ResolverRegistry()
  private var cache: DidCacheType?
  
  public func resolve(didUrl: String, options: DIDResolutionOptions?) -> Promise<DIDResolutionResult> {
    let parsed = parse(didUrl: didUrl)
    
    var emptyResult = DIDResolutionResult()
    
    return Promise { seal -> Void in
      if (parsed == nil) {
        emptyResult.didResolutionMetadata.errorDescription = .invalidDid
        seal.fulfill(emptyResult)
      }
      //guard let registry = self.resolverRegistry
      let resolver = self.resolverRegistry.methodName[parsed?.method ?? ""]
      
      
      var _ : DidCacheType = { did, wrapped  in
        var _ : wrappedResolverType = wrapped
        return DIDResolve(did: did.did, parsed: did, resolver: self, options: options ?? DIDResolutionOptions())
      }
    }
  }
  
  init(regstry: ResolverRegistry, options: ResolverOptions = ResolverOptions(cache: nil, legacyResolver: nil)) {
    self.resolverRegistry = regstry
    
    guard let optionCache = options.cache else { return }
    
    self.cache = optionCache != nil ? inMemoryCache() : noCache
    
    if options.legacyResolver != nil {
      options.legacyResolver?.keys.forEach { methodName in
        if let value = self.resolverRegistry.methodName[methodName] {
          if let resolver = options.legacyResolver, let method = resolver[methodName] {
            self.resolverRegistry.methodName[methodName] = wrapLegacyResolver(resolve: method)
          }
        }
      }
    }
  }
  
}

func noCache(parsed: ParsedDID, resolve: wrappedResolverType) -> Promise<DIDResolutionResult> {
  return resolve()  //Promise<DIDResolutionResult>.value(currentParsedDIDDocument)
}
