//
//  MAllocation+Normies.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public extension BaseModel {
    func getAllocationIndexes(for strategyKey: StrategyKey) -> IndexSet {
        IndexSet(
            self.allocations.enumerated().compactMap { n, allocation in
                guard allocation.strategyKey == strategyKey else { return nil }
                return n
            }
        )
    }
}

public extension MAllocation {
    static func normies(_ allocs: inout [MAllocation], indexSet: IndexSet? = nil, controlIndex: Int? = nil) throws {
        // when used with model, extract the indexes for the current strategy
        let indexSet_ = indexSet ?? IndexSet(allocs.indices)

        try indexSet_.forEach {
            guard (0.0 ... 1.0).contains(allocs[$0].targetPct)
            else { throw FlowBaseError.invalidPercent(allocs[$0].targetPct, allocs[$0].assetKey.assetNormID) }
        }

        if let controlIndex_ = controlIndex {
            guard indexSet_.contains(controlIndex_) else {
                throw FlowBaseError.invalidControlIndex
            }
        }

        // collect non-prioritized indexes
        var locked = [Int]()
        var unlocked = [Int]()
        indexSet_.forEach {
            if $0 == controlIndex { return }
            if allocs[$0].isLocked {
                locked.append($0)
            } else {
                unlocked.append($0)
            }
        }

        // helper funcs
        func lockedSum() -> Double {
            locked.reduce(0.0) { $0 + allocs[$1].targetPct }
        }
        func unlockedSum() -> Double {
            unlocked.reduce(0.0) { $0 + allocs[$1].targetPct }
        }
        func nonPrioritizedSum() -> Double {
            (locked + unlocked).reduce(0.0) { $0 + allocs[$1].targetPct }
        }

        // case where the fixedAlloc is the only alloc
        if let controlIndex_ = controlIndex,
           allocs.count == 1
        {
            allocs[controlIndex_].targetPct = 1.0
            return
        }

        // fixed, if locked, gets first bite of apple
        // (if not locked, it's subject to snapback)
        var available: Double = {
            if let controlIndex_ = controlIndex {
                let fixedAlloc = allocs[controlIndex_]
                if fixedAlloc.isLocked {
                    return 1.0 - fixedAlloc.targetPct
                }
            }
            return 1.0
        }()

        // next, locked gets their bite of the apple
        let lockSumRaw = lockedSum() // may exceed 1.0!

        // begin by normalizing the (non-prioritized) locked allocs (to a sum of 0...1)
        if locked.count > 0 {
            var remaining = lockSumRaw - available
            if remaining > 0 {
                for n in locked {
                    let capacity = allocs[n].targetPct
                    let deducting = min(capacity, remaining)
                    allocs[n].targetPct -= deducting
                    remaining -= deducting
                }
            }
        }

        let lockedSumNorm = lockedSum()

        // give unlocked active as much as it needs after locked had their bite
        if let controlIndex_ = controlIndex {
            let fixedAlloc = allocs[controlIndex_]
            if !fixedAlloc.isLocked {
                let remaining = 1.0 - lockedSumNorm
                allocs[controlIndex_].targetPct = min(remaining, allocs[controlIndex_].targetPct)
                available -= allocs[controlIndex_].targetPct
            }
        }

        // next normalize the open (unlocked) allocs
        if unlocked.count > 0 {
            let allocateToUnlock = available - lockedSumNorm
            if allocateToUnlock == 0.0 {
                for n in unlocked {
                    allocs[n].targetPct = 0.0
                }
            } else {
                let unlockSumRaw = unlockedSum()
                if unlockSumRaw > allocateToUnlock {
                    for n in unlocked {
                        allocs[n].targetPct /= unlockSumRaw / allocateToUnlock
                    }
                }
                let totalSum = nonPrioritizedSum()
                let remaining = available - totalSum
                let share = remaining / Double(unlocked.count)
                for n in unlocked {
                    allocs[n].targetPct += share
                }
            }
        }

        // as a last resort, force locked to adjust if needed
        if locked.count > 0 {
            let totalSum = nonPrioritizedSum()
            let allocateToLocked = max(0, available - totalSum)
            if allocateToLocked > 0 {
                let share = allocateToLocked / Double(locked.count)
                for n in locked {
                    allocs[n].targetPct += share
                }
            }
        }
    }
}
