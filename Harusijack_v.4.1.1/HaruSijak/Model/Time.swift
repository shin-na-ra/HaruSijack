//
//  TimeModel.swift
//  HaruSijak
//
//  Created by 신나라 on 6/12/24.
//
/*
 Description : 2024.06.12 snr : 출근시간대 설정을 위한 model
               2024.06.17 snr : 출발역 설정을 위해 station 추가
               2024.07.05 snr : 호선 설정을 위해 line 추가
 */

import Foundation

struct Time {
    var id: Int
    var time: Int
    var line: Int
    var station: String
    
}
