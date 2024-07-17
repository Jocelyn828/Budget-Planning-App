//
//  CurrencyData.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 03/05/2024.
//

import UIKit

class CurrencyData: NSObject, Decodable {
    var conversion_rates: [String:Double]?
    var updated_date: String?
    
    private enum CodingKeys: String, CodingKey {
        case conversion_rates
        case updated_date = "time_last_update_utc"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        conversion_rates = try container.decode([String:Double].self,forKey: .conversion_rates)
        updated_date = try container.decode(String.self,forKey: .updated_date)
    }
}







//
//var AUD_rates: Double?
//var USD_rates: Double?
//var GBP_rates: Double?
//var EUR_rates: Double?
//var CNY_rates: Double?
//var THB_rates: Double?
//var SGD_rates: Double?
//var KRW_rates: Double?
//var JPY_rates: Double?
//var MYR_rates: Double?
//
//private enum CodingKeys: String, CodingKey {
//    case AUD
//    case USD
//    case GBP
//    case EUR
//    case CNY
//    case THB
//    case SGD
//    case KRW
//    case JPY
//    case MYR
//}
//
//required init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    AUD_rates = try container.decode(Double.self, forKey: .AUD)
//    USD_rates = try container.decode(Double.self, forKey: .USD)
//    GBP_rates = try container.decode(Double.self, forKey: .GBP)
//    EUR_rates = try container.decode(Double.self, forKey: .EUR)
//    CNY_rates = try container.decode(Double.self, forKey: .CNY)
//    THB_rates = try container.decode(Double.self, forKey: .THB)
//    SGD_rates = try container.decode(Double.self, forKey: .SGD)
//    KRW_rates = try container.decode(Double.self, forKey: .KRW)
//    JPY_rates = try container.decode(Double.self, forKey: .JPY)
//    MYR_rates = try container.decode(Double.self, forKey: .MYR)
//}
