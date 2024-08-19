//
//  TimeSettingDB.swift
//  HaruSijak
//
//  Created by 신나라 on 6/12/24.
//
/*
    Description : 2024.06.12 snr : 시간대 설정 DB 생성
                  2024.06.17 snr : 출발역 DB에 저장하기 위해서 model 수정
 */

import Foundation
import SQLite3

class TimeSettingDB: ObservableObject {
    var db: OpaquePointer?
    var settingList: [Time] = []
    
    
    init() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true ).appending(path: "HaruSetting.sqlite")
        
        // DB 열기
        if sqlite3_open(fileURL.path(percentEncoded: true), &db) != SQLITE_OK{
            print("error opening database")
            return
        }
        // Table 만들기
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS timeset (id INTEGER PRIMARY KEY AUTOINCREMENT, time INTEGER, station TEXT, line INTEGER)", nil, nil, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table : \(errMsg)")
            return
        }
        print("Database and table created successfully")
    }
    
    // 시간대 조회 쿼리
    func queryDB() -> [Time] {
        
        settingList = []
        
        var stmt: OpaquePointer?
        let queryString = "select * from timeset"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select : \(errMsg)")
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = Int(sqlite3_column_int(stmt, 0))
            let time = Int(sqlite3_column_int(stmt, 1))
            let station = String(cString: sqlite3_column_text(stmt, 2))
            let line = Int(sqlite3_column_int(stmt, 3))
            
            settingList.append(Time(id: id, time: time, line: line, station: station))
        }
        
        return settingList
    }// queryDB
    
    
    // 시간대 입력 쿼리
    func insertDB(time: Int, station: String, line: Int) {
        
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "INSERT INTO timeset (time, station, line) VALUES (?,?, ?)"
        
        print("-------------")
        print("time : ", time)
        print("station : ", station)
        print("line : ", line)
        print("-------------")
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_int(stmt, 1, Int32(time))
        sqlite3_bind_text(stmt, 2, station, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 3, Int32(line))
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            print("insert 성공")
        } else {
            print("insert 실패!")
        }
    }
    
    // 시간대 수정 쿼리
    func updateDB(time: Int, station: String, line: Int ,id: Int) {
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "UPDATE timeset SET time=? , station = ?, line = ? where id = ?"
        
        print("-------------")
        print("time : ", time)
        print("station : ", station)
        print("line : ", line)
        print("id : ", id)
        print("-------------")
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_int(stmt, 1, Int32(time))
        sqlite3_bind_text(stmt, 2, station, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 3, Int32(line))
        sqlite3_bind_int(stmt, 4, Int32(id))
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            print("update 성공")
        } else {
            print("update 실패!")
        }
    }
}
