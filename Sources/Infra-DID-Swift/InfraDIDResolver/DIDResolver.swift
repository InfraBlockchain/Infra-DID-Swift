//
//  File.swift
//
//
//  Created by SatGatLee on 2021/11/19.
//

import Foundation
import PromiseKit

public protocol Resolvable {
  func resolve(didUrl: String, options: DIDResolutionOptions?) async -> Promise<DIDResolutionResult>
}


public class Resolver: Resolvable {
  
  private var resolverRegistry: ResolverRegistry?
  private var cache: DidCacheType?
  
  public func resolve(didUrl: String, options: DIDResolutionOptions?) async -> Promise<DIDResolutionResult> {
    let parsed = parse(didUrl: didUrl)
    
    guard let registry = self.resolverRegistry, let parsed = parsed, let cached = self.cache else { return emptyResult }
    
    guard let resolver = registry.methodName[parsed.method] else { return emptyResult }
    
    return await cached(parsed, {
      let result = await resolver(parsed.did, parsed, self, options ?? DIDResolutionOptions())
      return result
    })
  }
  
  public init(registry: ResolverRegistry, options: ResolverOptions = ResolverOptions(cache: nil, legacyResolver: nil)) {
    self.resolverRegistry = registry
    
    guard let optionCache = options.cache else { return }

    self.cache = options.cache != nil ? inMemoryCache() : noCache
    
    guard var registry = self.resolverRegistry else { return }
    
    if options.legacyResolver != nil {
      options.legacyResolver?.keys.forEach { methodName in
        if registry.methodName[methodName] != nil {
          if let resolver = options.legacyResolver, let method = resolver[methodName] {
            registry.methodName[methodName] = wrapLegacyResolver(resolve: method)
          }
        }
      }
    }
  }
  
}

private func noCache(parsed: ParsedDID, resolve: wrappedResolverType) async -> Promise<DIDResolutionResult> {
  return await resolve()  //Promise<DIDResolutionResult>.value(currentParsedDIDDocument)
}
