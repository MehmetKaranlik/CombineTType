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
 let url : URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!

 @Published var posts : [Post?] = []

 var cancellabels = Set<AnyCancellable>()

 init() {

 }

 func fetchPosts() {
  service.getPosts(modelToDecode: [Post].self, cancellableSet: &cancellabels, url: url) { [weak self] data in
   self?.posts = data ?? []
  }

 }


}


struct CombineTTypeService : CombineTTypeServiceProtocol {


 var manager: CombineManager = CombineManager()


 func getPosts< R : Codable >(modelToDecode model : R.Type,cancellableSet :inout Set<AnyCancellable>,url :URL,completion : @escaping (R?) -> Void) {

  do {
   try manager.send(modelToDecode: model,
                    cancellableSet: &cancellableSet,
                    url: url, body: nil,
                    requestType: .GET) { response in  completion(response) }
  } catch let e {
   print(e)
  }
 }
}


protocol CombineTTypeServiceProtocol {

 func getPosts<R: Codable>(
  modelToDecode model : R.Type,
  cancellableSet :inout Set<AnyCancellable>,
  url :URL,
  completion : @escaping (R?) -> Void
 )

 var manager : CombineManager { get }

}


struct Post:  Codable, Hashable {
 let userId,id : Int?
 let title,body : String?
}
