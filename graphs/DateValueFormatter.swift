import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "MMM-YY"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

public class DateValueFormatterNew: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()

    override init() {
        super.init()
        dateFormatter.dateFormat = "MMM-YY"
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let formatter = DateFormatter()
		var dateComponents = DateComponents()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		var start = formatter.date(from: "2019-01-01T00:00:01")
		dateComponents.month = Int(value)
		let newdate = Calendar.current.date(byAdding: dateComponents, to: start!)!
        return dateFormatter.string(from: newdate)
    }
}
