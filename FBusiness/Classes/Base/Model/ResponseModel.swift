//
//  BaseModel.swift
//  FBusiness
//
//

public class ResponseModel<T: Codable>: Codable {
    var total: Int = 0
    var pageNo: Int = 0
    var data: T?
    
    enum CodingKeys: String, CodingKey {
        case total
        case pageNo
        case data
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decode(Int.self, forKey: .total)
        pageNo = try container.decode(Int.self, forKey: .pageNo)
        data = try container.decodeIfPresent(T.self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(total, forKey: .total)
        try container.encode(pageNo, forKey: .pageNo)
        try container.encodeIfPresent(data, forKey: .data)
    }
}
