//
//  File.swift
//  
//
//  Created by Matic Zavadlal on 10/10/2020.
//

import Foundation


/* Schema Introspection */


let introspectionQuery: Data = """
{
  __schema {
    # Operations
    queryType {
      ...Type
    }
    mutationType {
      ...Type
    }
    subscriptionType {
      ...Type
    }
    # Objects
    types {
      ...Type
    }
  }
}

fragment Type on __Type {
  kind
  name
  description
  fields(includeDeprecated: false) {
      ...Field
  }
  enumValues {
    ...EnumValue
  }
}

fragment Field on __Field {
  name
  description
  args {
    ...InputValue
  }
  # type {
  #   ...Type
  # }
  isDeprecated
  deprecationReason
}

fragment InputValue on __InputValue {
  name
  description
  type {
    kind
    name
    description
  }
  defaultValue
}

fragment EnumValue on __EnumValue {
  name
  description
  isDeprecated
  deprecationReason
}
"""
    .data(using: .utf8)!


/* Methods **/


public func downloadFrom(_ endpoint: URL, to: URL) -> Void {
    /* Compose a request. */
    var request = URLRequest(url: endpoint)
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = introspectionQuery
    
    /* Load the schema. */
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        /* Check for errors. */
        if let _ = error {
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return
        }
        
        /* Save JSON to file. */
        if let data = data {
            save(data: data)
        }
    }
    
    /* Save the schema. */
    
    /// Saves the data to the filesystem.
    func save(data: Data) -> Void {
        try! data.write(to: to)
    }
}

