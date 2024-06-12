//
//  CalendarDB.swift
//  HaruSijak
//
//  Created by 신나라 on 6/10/24.
//
/*
    Description
        - 2024.06.11 snr : queryDB() 값조회가 잘되는지 print 확인 후 삭제.
                            queryDB() View단에서 하나씩만 조회되도록 taskList리스트 초기화 처리
        - 2024.06.12 snr : updateDB() => return값 없앰, errMsg 추가
                            update 시 id가 달라 update에 문제가 있어서 print()로 찍어보는 주석 처리함.
                    
 */

import Foundation
import SQLite3

class CalendarDB: ObservableObject {
    var db: OpaquePointer?
    var taskList : [TaskMetaData] = []
    
    //DateFormatter 전역 변수 설정
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 문자열의 날짜 형식에 맞게 설정
        return formatter
    }
    
    
    // DateFormatter for displaying time only
    var timeFormatter: DateFormatter {
       let formatter = DateFormatter()
       formatter.dateStyle = .none
       formatter.timeStyle = .short
       return formatter
   }
    
    
    init() {
        //DB 경로
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true ).appending(path: "HaruStart.sqlite")
        
        // DB 열기
        if sqlite3_open(fileURL.path(percentEncoded: true), &db) != SQLITE_OK{
            print("error opening database")
            return
        }
        
        // Table 만들기
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS task(id TEXT PRIMARY KEY, title TEXT, time TEXT, taskdate TEXT)", nil, nil, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table : \(errMsg)")
            return
        }
        
        print("Database and table created successfully")
    }//init()
    
    
    // SQLite3에서 문자열을 가져와 Date로 변환하는 함수
    func dateFromSQLite(stmt: OpaquePointer, column: Int32) -> Date? {
        if let cString = sqlite3_column_text(stmt, column) {
            let dateString = String(cString: cString)
            return dateFormatter.date(from: dateString) ?? timeFormatter.date(from: dateString)
        }
        return nil
    }
    
    
    // 조회
    func queryDB() -> [TaskMetaData] {
        taskList = []
        var stmt: OpaquePointer?
        let queryString = "SELECT * FROM task"
        
        // 예외 처리
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select : \(errMsg)")
        }
        
        // DB에 값 넣기
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = String(cString: sqlite3_column_text(stmt, 0))
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let time = dateFromSQLite(stmt: stmt!, column: 2)
            let taskDate = dateFromSQLite(stmt: stmt!, column: 3)
            
//            print("select id", id)
            
            // Model에 넣기
            let task = Task(id: id, title: title, time: time!)
            
//            print("task in id : ", task.id)
            
            if let index = taskList.firstIndex(where: { $0.taskDate == taskDate }) {
                taskList[index].task.append(task)
            } else {
                taskList.append(TaskMetaData(id: UUID().uuidString, task: [task], taskDate: taskDate!))
            }
        }
        
        return taskList
    }
    
    // 할일 추가
    func insertDB(task: Task, taskDate: Date) {
        print("1")
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "INSERT INTO task (id, title, time, taskDate) VALUES (?,?,?,?)"
        
        let timeString = timeFormatter.string(from: task.time)
        let taskDateString = dateFormatter.string(from: taskDate)
        
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        sqlite3_bind_text(stmt, 1, task.id, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, task.title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, timeString, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, taskDateString, -1, SQLITE_TRANSIENT)
        print("insertID : ", task.id)
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("insert 성공!!!")
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Insert 실패: \(errmsg)")
        }
        
    }
    
    // 할일 수정
    func updateDB(title: String, time: Date, taskDate: Date, id: String) -> Bool{
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "UPDATE task SET title=?, time=?, taskDate=? WHERE id=?"
        
        let timeString = timeFormatter.string(from: time)
        let taskDateString = dateFormatter.string(from: taskDate)
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
//        print("=======updateDB=======")
//        print("title : ", title)
//        print("timeString : ", timeString)
//        print("taskDateString : ", taskDateString)
//        print("id : ", id)
//        print("=======updateDB=======")
        
        sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, timeString, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, taskDateString, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, id, -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("update 성공")
            return true
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("update 실패: \(errmsg)")
            return false
        }
        
    }
}
