//
//  ViewController.swift
//  taskapp
//
//  Created by 今冨友裕 on 2019/03/02.
//  Copyright © 2019年 yasainojikan. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    //  データが入った状態でプロパティ追加すると、migrationされる仕様
    let realm = try! Realm(configuration:Realm.Configuration(deleteRealmIfMigrationNeeded: true))
    
    var searchBar = UISearchBar()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    var filteredCategory = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.showsSearchResultsButton = false
        searchBar.placeholder = "カテゴリ検索"
        searchBar.setValue("キャンセル", forKey: "_cancelButtonText")
        searchBar.tintColor = UIColor.red
        
        tableView.tableHeaderView = searchBar
    }
    
    //    画面遷移時に送るデータ定義のメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let inputViewController: inputViewController = segue.destination as! inputViewController
        //       セルなら詳細画面へ。+は新規作成画面へ。
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            if searchBar.text != "" {
                inputViewController.task = filteredCategory[indexPath!.row]
            }else{
                inputViewController.task = taskArray[indexPath!.row]
            }
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //    セルの個数を定義
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" {
            return filteredCategory.count
        }else {
            return taskArray.count
        }
    }
    
    //    セルの内容を定義
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        let filteredTask = filteredCategory[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        if searchBar.text != "" {
            // もしサーチコントローラーが動いているなら、検索Taskを並べる
            cell.textLabel?.text = filteredTask.title
        } else {
            cell.textLabel?.text = task.title
        }        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------")
                    print(request)
                    print("----------/")
                }
            }
        }
    }
    
    //    検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        
        //    searchBarに打ち込まれた文字を変数として定義し、それで検索をかける
        let searchCategory = searchBar.text!
        filteredCategory = try! Realm().objects(Task.self).filter("category == %@", searchCategory)
        
        self.tableView.reloadData()
    }
    
    //    キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
        
        //        検索ボタンが押されているので、filteredCategoryを初期化する
        filteredCategory = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        self.tableView.reloadData()
    }
    
    //    テキストフィールド入力開始前に呼ばれる
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
}
