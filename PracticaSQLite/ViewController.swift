//
//  ViewController.swift
//  PracticaSQLite
//
//  Created by Juan Gerardo Cruz on 1/9/20.
//  Copyright © 2020 inventaapps. All rights reserved.
//

import UIKit
import SQLite3


class Hero {
    
    var id: Int
    var name: String?
    var powerRanking: Int
    
    init(id: Int, name: String?, powerRanking: Int){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}

class ViewController: UIViewController {

    private var db: OpaquePointer?
    private var heroList = [Hero]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        openDatabase()
    }
    
    private func openDatabase() {
        //Crear archivo
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("HeroesDatabase.sqlite")
        
        //Abrir una base de datos
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error openning database")
        }
    }
    
    private func createTable() {
        //Crear una tabla
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }

    private func insertValues(name: String, powerRanking: String ) {
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, Int32(powerRanking) ?? 0) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
    }
    
    private func update() {
        let updateStatementString = "UPDATE Heroes SET Name = 'Chris' WHERE Id = 1;"
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    private func delete() {
        let deleteStatementStirng = "DELETE FROM Heroes WHERE Id = 1;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    private func readValues(){
       heroList.removeAll()

       let queryString = "SELECT * FROM Heroes"
       
       var stmt:OpaquePointer?
       
       if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
           let errmsg = String(cString: sqlite3_errmsg(db)!)
           print("error preparing insert: \(errmsg)")
           return
       }
       
       while(sqlite3_step(stmt) == SQLITE_ROW){
           let id = sqlite3_column_int(stmt, 0)
           let name = String(cString: sqlite3_column_text(stmt, 1))
           let powerrank = sqlite3_column_int(stmt, 2)
           
           heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
       }
        
        printer()
    }
    
    private func printer() {
        heroList.forEach { (hero) in
            print("id:\(hero.id) name: \(hero.name ?? "") powerrank: \(hero.powerRanking)")
        }
    }
    
    @IBAction func insertAction(_ sender: UIButton) {
        let name = "Name \(Int.random(in: 0 ..< 100))"
        let powerRanking = "\(Int.random(in: 0 ..< 100))"
        
        insertValues(name: name, powerRanking: powerRanking)
    }
    
    @IBAction func queryAction(_ sender: UIButton) {
        readValues()
    }
    
    @IBAction func createAction(_ sender: UIButton) {
        createTable()
    }
    
    @IBAction func updateAction(_ sender: Any) {
        update()
    }
    
    
}

