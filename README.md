# CombineTType

Networkign solution to handle T type where T: Codable. 
proccessing in background via Combine Framework.


````swift
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
 
 ````
 
 
 Usage
 
 ````swift
 
 struct CombineTTypeService : CombineTTypeServiceProtocol {

 var manager: CombineManager = CombineManager()
 func getPosts< R : Codable >(modelToDecode model : R.Type, cancellableSet :inout Set<AnyCancellable>, url :URL,completion : @escaping (R?) -> Void) {
  do {
   try manager.send(modelToDecode: model,cancellableSet: &cancellableSet,url: url, body: nil, requestType: .GET) { response in  completion(response) }
  } catch let e {
   print(e)
  }
 }
}
}


class CombineTTypeViewModel : ObservableObject {

 let service = CombineTTypeService()
 
 let url : URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
 
 @Published var posts : [Post?] = []
 
 var cancellabels = Set<AnyCancellable>()
 
 func fetchPosts() {
  service.getPosts(modelToDecode: [Post].self, cancellableSet: &cancellabels, url: url) { [weak self] data in
   self?.posts = data ?? []
  }
 }
 
}



 
 ````
 

 
 



