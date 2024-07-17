//
//  ChartUIView.swift
//  JOCELYNTANLIANSZE-A4-FinalApplication
//
//  Created by Lian Sze Jocelyn Tan on 02/05/2024.
//

import SwiftUI
import Charts

/// Represents the data structure for statistics data
struct StatisticsData: Identifiable {
    var category: String
    var amount: Double
    var id = UUID()
}

struct ChartUIView: View {
    var categoriesCost: [String: Double]
    
    /// reduce function: https://reintech.io/blog/swift-map-reduce-filter-tutorial
    
    // Total amount calculated from the sum of all category costs
    var totalAmount: Double {
            categoriesCost.values.reduce(0.0, +)
        }
    
    /// map function: https://reintech.io/blog/swift-map-reduce-filter-tutorial
    // Generates an array of StatisticsData for each category and its corresponding amount
    var data: [StatisticsData] {
        let sortedCategories = categoriesCost.keys.sorted()

        return sortedCategories.map { StatisticsData(category: $0, amount: categoriesCost[$0] ?? 0.0) }
        }

    /// Vstack online references: https://www.google.com/search?sca_esv=fbc659ff7db8699b&q=swiftui+chart+legend+custom&tbm=vid&source=lnms&prmd=isvnmbtz&sa=X&ved=2ahUKEwjblYGsu4-GAxWislYBHXTDBAgQ0pQJegQICxAB&biw=1167&bih=788&dpr=2#fpstate=ive&vld=cid:fff5982c,vid:4utsyqhnS4g,st:1175
    var body: some View {
        VStack {
            // Display the total amount at the top of the chart
            Text("Total Amount: \(String(format: "%.2f", totalAmount))")
                .fontWeight(.medium)
                .padding(.bottom,15)
            
            // Render the chart using the provided data
            Chart (data) { amountData in
                SectorMark(angle: .value("Amount", amountData.amount),
                           innerRadius: .ratio(0.618), // Create a donut chart
                           angularInset: 1 // Create gap between sector
                ).cornerRadius(2)
                    .foregroundStyle(by: .value("Category", amountData.category))
            }.chartLegend(position: .trailing) // Add a legend to the chart
        }
    }
}

