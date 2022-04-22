//
//  ContentView.swift
//  CombineTtype
//
//  Created by mehmet karanlık on 22.04.2022.
//

import SwiftUI
import Combine

struct ContentView: View {
 @ObservedObject var vm = CombineTTypeViewModel()

    var body: some View {

     ScrollView {
      VStack(alignment:.leading) {

       ForEach(vm.posts, id: \.self) { post in
        VStack(alignment:.leading) {
         Text(post?.title ?? "")
          .font(.title)
          .foregroundColor(.black)
         // .multilineTextAlignment(.center)
         Text(post?.body ?? "")
          .font(.body)
          .foregroundColor(.gray)
        }
       }
      }
     }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class CombineTTypeViewModel : ObservableObject {

 let service = CombineTTypeService()

 @Published var posts : [Post?] = []

 var cancellabels = Set<AnyCancellable>()

 init() {
  service.getPosts(modelToDecode: [Post].self, completion: { [weak self] data in
   self?.posts = data ?? []
  }, cancellableSet: &cancellabels)
 }


}


struct CombineTTypeService : CombineTTypeServiceProtocol {

 func getPosts< R : Codable >(
  modelToDecode model : R.Type,
  completion : @escaping (R?) -> Void,
  cancellableSet :inout Set<AnyCancellable>
 ) {
  var data : R?
  let url = URL(string:"https://jsonplaceholder.typicode.com/posts")!

   URLSession.shared.dataTaskPublisher(for: url)
    .receive(on: DispatchQueue.main)
    .tryMap(handleOutput)
    .decode(type: R.self , decoder: JSONDecoder())
    .sink { (completion) in
     print("DEBUG: Completion is \(completion)")
    } receiveValue: { returnedPosts in
     data = returnedPosts
     if let decodedData = data {
      print(decodedData)
      completion(decodedData)
     }
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
}


protocol CombineTTypeServiceProtocol {

 func getPosts<R: Codable>(modelToDecode model : R.Type, completion :  @escaping (R?) -> Void, cancellableSet :inout Set<AnyCancellable>)

}


struct Post: Identifiable, Codable, Hashable {
 let userId,id : Int?
 let title,body : String?
}
