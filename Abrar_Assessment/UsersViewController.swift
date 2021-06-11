//
//  UsersViewController.swift
//  Abrar-Assessment
//
//  Created by ابرار on 24/10/1442 AH.
//



import UIKit
import Foundation
import CoreData


struct JSONFromWeb: Codable {
  let news: [JsonStruct]

  enum CodingKeys: String, CodingKey {
      case news = "data"
  }
}
struct FetchedUsers {
    var reference: NSManagedObjectID! // ID on the other-hand is thread safe.

    var name: String
    var  email : String
    var  gender : String
    var  status : String
    //and the rest of your properties
}
struct JsonStruct: Codable {
  let intID: Int
  let nameU, email, gender,status: String

  enum CodingKeys: String, CodingKey {
      case intID = "id"
      case nameU = "name"
      case email = "email"
    case gender = "gender"
    case status = "status"
  }
}

class UsersViewController: UIViewController {
   // let NetworkingService = DatabaseHandler.shared
    @IBOutlet var loading: UIView!
    var activityView: UIActivityIndicatorView?
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    var loadingView: UIView = UIView()
    var arradata = [JsonStruct]()
    @IBOutlet weak var TableViewUsers: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
        var context:NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityIndicator()
        
        if InternetConnectionManager.isConnectedToNetwork(){
            print("Connected")
            getdata()
            whereIsMySQLite()
        }else{
            print("Not Connected")
            let alert = UIAlertController(title: "Connection error", message: "Connection error: please check that you are connected to the internet! or try again", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    

                    // show the alert
                   
          
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
                    
            }))
            self.present(alert, animated: true, completion: nil)
        }
      
       
   //callAPI()
     //   NetworkingService.request1()
        // Do any additional setup after loading the view.
    }
    
    //func callAPI(){
        
        func getdata() {
            // function getData to load the Api
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async
              {
                let url = URL(string : "https://gorest.co.in/public-api/users")
                URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    do {
                        let jsonFromWeb = try JSONDecoder().decode(JSONFromWeb.self, from: data!)
                        print(jsonFromWeb.news , "test6")
                        //This web call is asynchronous, so you'll have to reload the table view
                        self.arradata = jsonFromWeb.news

                        self.openDatabse()
                        DispatchQueue.main.async {
                                                        self.TableViewUsers.reloadData()
                            self.hideActivityIndicator()
                        }
                    } catch {
                        print(error)
                    }
                }.resume()
            }
            }
        //let urlpath = "https://gorest.co.in/public-api/users"
        //NetworkingService.request(urlpath)//{(result)in
           // print(result)
        //}
        
   // }
  
    func whereIsMySQLite() {
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding

        print(path ?? "Not found")
    }
    func openDatabse()
       {
           context = appDelegate.persistentContainer.viewContext
           let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
           let newUser = NSManagedObject(entity: entity!, insertInto: context)
           saveData(UserDBObj:newUser)
       }
    func saveData(UserDBObj:NSManagedObject)
       {
        for element in arradata {
            UserDBObj.setValue(element.email, forKey: "email")
            UserDBObj.setValue(element.gender, forKey: "gender")
            UserDBObj.setValue(element.nameU, forKey: "name")
           
        }
           print("Storing Data..")
           do {
               try context.save()
           } catch {
               print("Storing data Failed")
           }

           fetchData()
       }
    func fetchData()
       {
           print("Fetching Data..")
           let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
           request.returnsObjectsAsFaults = false
           do {
               let result = try context.fetch(request)
               for data in result as! [NSManagedObject] {
                   let userName = data.value(forKey: "name") as! String
                   let gender = data.value(forKey: "gender") as! String
                let email = data.value(forKey: "email") as! String
                
                   print("User Name is : "+userName+" and gender is : " + gender + " and email is : " + email )
               }
           } catch {
               print("Fetching data Failed")
           }
       }
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }

    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }
}

extension UsersViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arradata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableViewUsers.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.UserName.text = arradata[indexPath.row].nameU
        cell.Email.text =  arradata[indexPath.row].email
        if (arradata[indexPath.row].gender == "Male"){
            cell.gender.textColor = .blue
        }
        else{
            cell.gender.textColor = .red
        }
        cell.gender.text =  arradata[indexPath.row].gender
        cell.status.text =  arradata[indexPath.row].status
        return cell
    }
    
        
   /* func saveUserData(_ users: [User]) {
        let context = appDelegate.persistentContainer.viewContext
        for user in users {
            let newUser = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
            newUser.setValue(user.id, forKey: "id")
            newUser.setValue(user.name, forKey: "name")
            newUser.setValue(user.email, forKey: "email")
            newUser.setValue(user.phone, forKey: "phone")
            newUser.setValue(user.website, forKey: "website")
            newUser.setValue(user.city, forKey: "city")
            newUser.setValue(user.lat, forKey: "lat")
            newUser.setValue(user.long, forKey: "long")
        }
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error saving: \(error)")
        }
    }*/
        
    }


