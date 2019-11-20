//
//  FreshTests.swift
//  FreshTests
//
//

import XCTest
@testable import Fresh
import SwiftX
import FBusiness

class FreshTests: XCTestCase {
    
    class User: Codable {
        var name: String = ""
        var address: String = ""
        var age: Int = 0
        
        var child: User?
        var children: [User]?
        
    }
    
    let jsonString1 = "{\"name\":\"wangcong\", \"address\":\"成都\", \"age\": 1, \"child\": {\"name\":\"你好\", \"address\":\"成都\", \"age\": 1, \"child\": {\"name\":\"你好好\", \"address\":\"成都\", \"age\": 1}}}"
    let jsonString = "{\"msg\":\"操作成功\",\"code\":200,\"response\":[{\"subs\":[{\"catelogName\":\"河南苹果\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog4.png\",\"catelogId\":\"10101\",\"pcatelogId\":\"101\"},{\"catelogName\":\"富士苹果\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog1.png\",\"catelogId\":\"10102\",\"pcatelogId\":\"101\"},{\"catelogName\":\"桃子\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog2.png\",\"catelogId\":\"10103\",\"pcatelogId\":\"101\"}],\"catelogName\":\"水果\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog1.png\",\"catelogId\":\"101\",\"pcatelogId\":\"0\"},{\"subs\":[{\"catelogName\":\"核桃\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog3.png\",\"catelogId\":\"10201\",\"pcatelogId\":\"102\"},{\"catelogName\":\"花生\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog4.png\",\"catelogId\":\"10202\",\"pcatelogId\":\"102\"},{\"catelogName\":\"板栗\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog1.png\",\"catelogId\":\"10203\",\"pcatelogId\":\"102\"}],\"catelogName\":\"坚果\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog2.png\",\"catelogId\":\"102\",\"pcatelogId\":\"0\"},{\"subs\":[{\"catelogName\":\"大白菜\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog2.png\",\"catelogId\":\"10301\",\"pcatelogId\":\"103\"},{\"catelogName\":\"莲花白\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog3.png\",\"catelogId\":\"10302\",\"pcatelogId\":\"103\"},{\"catelogName\":\"西红柿\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog4.png\",\"catelogId\":\"10303\",\"pcatelogId\":\"103\"}],\"catelogName\":\"蔬菜\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog3.png\",\"catelogId\":\"103\",\"pcatelogId\":\"0\"},{\"subs\":[{\"catelogName\":\"牛肉\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog1.png\",\"catelogId\":\"10401\",\"pcatelogId\":\"104\"},{\"catelogName\":\"猪肉\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog2.png\",\"catelogId\":\"10402\",\"pcatelogId\":\"104\"},{\"catelogName\":\"羊肉\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog3.png\",\"catelogId\":\"10403\",\"pcatelogId\":\"104\"}],\"catelogName\":\"鲜肉\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog4.png\",\"catelogId\":\"104\",\"pcatelogId\":\"0\"},{\"subs\":[{\"catelogName\":\"鲫鱼\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog4.png\",\"catelogId\":\"10501\",\"pcatelogId\":\"105\"},{\"catelogName\":\"鲈鱼\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog1.png\",\"catelogId\":\"10502\",\"pcatelogId\":\"105\"},{\"catelogName\":\"鲶鱼\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog2.png\",\"catelogId\":\"10503\",\"pcatelogId\":\"105\"}],\"catelogName\":\"河鲜\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog1.png\",\"catelogId\":\"105\",\"pcatelogId\":\"0\"},{\"subs\":[{\"catelogName\":\"带鱼\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog3.png\",\"catelogId\":\"10601\",\"pcatelogId\":\"106\"},{\"catelogName\":\"海虾\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog4.png\",\"catelogId\":\"10602\",\"pcatelogId\":\"106\"},{\"catelogName\":\"海带\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog1.png\",\"catelogId\":\"10603\",\"pcatelogId\":\"106\"}],\"catelogName\":\"海鲜\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog2.png\",\"catelogId\":\"106\",\"pcatelogId\":\"0\"},{\"subs\":[{\"catelogName\":\"野木耳\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog2.png\",\"catelogId\":\"10701\",\"pcatelogId\":\"107\"},{\"catelogName\":\"鹿茸\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog3.png\",\"catelogId\":\"10702\",\"pcatelogId\":\"107\"},{\"catelogName\":\"灵芝\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog4.png\",\"catelogId\":\"10703\",\"pcatelogId\":\"107\"}],\"catelogName\":\"山珍\",\"catelogThumbUrl\":\"https://freshmore.oss-cn-shenzhen.aliyuncs.com/catelog/catelog3.png\",\"catelogId\":\"107\",\"pcatelogId\":\"0\"}]}"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let gchild = try JSONDecoder.decode([CategoryModel].self, from: jsonString, forKeyPath: "response")
        print("fuck  testExample  \(gchild.count)")
        XCTAssertNotEqual(0, gchild.count)
    }

}
