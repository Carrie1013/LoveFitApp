//
//  HealthKitManager.swift
//  LoveFit
//
//  Created by 乔初逢 on 10/16/25.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    // 授权请求函数
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // 判断 HealthKit 是否可用
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit not available")
            completion(false)
            return
        }
        
        // 请求读取权限
        let readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        // 请求写入权限（你如果不写入，可以留空）
        let shareTypes: Set<HKSampleType> = []
        
        // 发起授权请求（第一次会弹出 HealthKit 授权对话框）
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            if let error = error {
                print("❌ Request Authorization failed：\(error.localizedDescription)")
                completion(false)
            } else {
                print(success ? "✅ HealthKit Authorized." : "⚠️ HealthKit Authorization Denied.")
                completion(success)
            }
        }
    }
    
    // 读取最近的运动记录
    func fetchRecentWorkouts(completion: @escaping ([HKWorkout]?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: workoutType,
                                  predicate: nil,
                                  limit: 10,
                                  sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard error == nil else {
                print("❌ Fetching workouts data failed: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            let workouts = samples as? [HKWorkout]
            completion(workouts)
        }
        healthStore.execute(query)
    }
}
