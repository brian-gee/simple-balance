import SwiftUI
import Foundation

class ViewModel: ObservableObject {
    @Published var balance: String?
    
    func getApi() {
        let url = URL(string: "https://api.teller.io/accounts/acc_odbahfmgob0etkrmbq000/balances")!
        let username = "test_token_c4ssr3yuk7cni"
        let password = ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? ""
        request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let available = json["available"] as? String {
                    DispatchQueue.main.async {
                        self.balance = available
                    }
                } else {
                    print("Invalid JSON response")
                }
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text("Available balance:")
                    Spacer()
                    if let balance = viewModel.balance {
                        Text(balance)
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Simple Balance")
            .onAppear {
                viewModel.getApi()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
