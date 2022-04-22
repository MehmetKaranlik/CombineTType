# CombineTType

Networkign solution to handle T type where T: Codable. 
proccessing in background via Combine Framework.


````
func getPosts< R : Codable >(
  modelToDecode model : R.Type,
  completion : @escaping (R?) -> Void,
  cancellableSet :inout Set<AnyCancellable>,
  url :URL
 ) {

  var data : R?

  let url = url

  URLSession.shared.dataTaskPublisher(for: url)
   .receive(on: DispatchQueue.main)
   .tryMap(handleOutput)
   .decode(type: R.self , decoder: JSONDecoder())
   .sink { (completion) in
    print("DEBUG: Completion is \(completion)")
   } receiveValue: { returnedPosts in
    data = returnedPosts
    if let decodedData = data { completion(decodedData) }
   }.store(in: &cancellableSet)
 }
 
  func handleOutput(output: URLSession.DataTaskPublisher.Output) throws  -> Data {
  guard
   let response = output.response as? HTTPURLResponse,
   response.statusCode >= 200 && response.statusCode < 300 else {
   throw URLError(.serverCertificateUntrusted)
  }
  return output.data
 }
 
 ````
 
 
 Usage
 
 ````
   var posts : [Post?] = []

   var cancellabels = Set<AnyCancellable>()
 
   service.getPosts(modelToDecode: [Post].self, completion: { [weak self] data in
   self?.posts = data ?? []
  }, cancellableSet: &cancellabels, url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
 
 ````
 

 
 



