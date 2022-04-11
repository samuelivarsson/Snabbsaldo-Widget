//
//  SaldoData.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2022-04-11.
//  Copyright © 2022 Samuel Ivarsson. All rights reserved.
//

import Foundation

var saldoData = SaldoData(
    lastUpdate: Date(),
    dispBelopp: "Disponibelt Belopp",
    belopp: "1234,56 SEK",
    expMessage: "",
    waitText: "",
    info: ""
)

var secSaldoData = SecSaldoData (
    lastUpdate: Date(),
    belopp2: "1234,78 SEK",
    belopp3: "1111,33 SEK",
    belopp4: "1087,12 SEK",
    name2: "Fasta",
    name3: "Res",
    name4: "Spar",
    expMessage: "",
    waitText: "",
    info: ""
)

struct SaldoData {
    var lastUpdate: Date
    var dispBelopp: String
    var belopp: String
    var expMessage: String
    var waitText: String
    var info: String
}

struct SecSaldoData {
    var lastUpdate: Date
    var belopp2: String
    var belopp3: String
    var belopp4: String
    var name2: String
    var name3: String
    var name4: String
    var expMessage: String
    var waitText: String
    var info: String
}
