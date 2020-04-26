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

public class DateValueFormatter10: NSObject, IAxisValueFormatter {
	var start: Date
	private let dateFormatter = DateFormatter()

	init(start: Date) {
		dateFormatter.dateFormat = "MMM-YY"
		self.start = start
	}

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		var dateComponents = DateComponents()
		let start = self.start
		dateComponents.month = Int(value) / 10
		guard let newdate = Calendar.current.date(byAdding: dateComponents, to: start) else { return "" }
        return dateFormatter.string(from: newdate)
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
		guard let start = formatter.date(from: "2019-01-01T00:00:01") else { return "" }
		dateComponents.month = Int(value)
		guard let newdate = Calendar.current.date(byAdding: dateComponents, to: start) else { return "" }
        return dateFormatter.string(from: newdate)
    }
}
