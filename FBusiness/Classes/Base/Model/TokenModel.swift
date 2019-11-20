//
//  TokenModel.swift
//  FBusiness
//
//


public class TokenModel: Codable {
    public var userId: String = ""
    public var token: String = ""
    public var expiredTime: TimeInterval = 0
    public var userType: String? = UserModel.UserType.unknown.rawValue
}
