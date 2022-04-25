//
//  CombineManager.swift
//  CombineTtype
//
//  Created by mehmet karanlık on 25.04.2022.
//

import Foundation
import Combine



struct CombineManager {

 let defaultTimeout : TimeInterval = TimeInterval(15)



 func send<T:Codable>( modelToDecode model : T.Type,    cancellableSet :inout Set<AnyCancellable>,url :URL, body : [String:Any]? , requestType : RequestType, completion : @escaping (T?) -> Void) throws  {

  var urlRequest = URLRequest(url: url,timeoutInterval: defaultTimeout)
  urlRequest.httpMethod = requestType.rawValue

  var data : T?

  // handle body if there is
  if let body = body {
   do {
    let decodedData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
    urlRequest.httpBody = decodedData
   } catch let e {
    throw e
   }
  }

  URLSession.shared.dataTaskPublisher(for: urlRequest)
   .tryMap(handleOutput)
   .decode(type: T.self, decoder: JSONDecoder())
   .sink { sinkCompletion  in
    handleSink(sinkCompletion)
   } receiveValue: { receivedData in
    data = receivedData
    if let decodedData = data { completion(decodedData) }
   }
   // define cancellabel either on where you call or either via DI
   .store(in: &cancellableSet)






  func handleOutput(output: URLSession.DataTaskPublisher.Output) throws  -> Data {
   guard
    let response = output.response as? HTTPURLResponse,
    response.statusCode >= 200 && response.statusCode < 300 else {
    throw URLError(.serverCertificateUntrusted)
   }
   return output.data
  }

   func handleSink(_ sinkCompletion: Subscribers.Completion<Error>) {
   switch sinkCompletion{
    case .finished:
     break
    case .failure(_):
     break
   }
  }
 }
}

enum RequestType : String {
 case GET,POST,PUT,DELETE
}


