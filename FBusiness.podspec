
Pod::Spec.new do |s|

  s.name         = "FBusiness"
  s.version      = "0.0.1"
  s.summary      = "其他业务."

  s.description  = <<-DESC
                    基础包Base：提供基础的Base Mode、View、VModel、HTTP基础业务功能
                    DESC

  s.homepage     = "http://gitee.com/FBusiness"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "wangcong" => "wangcccong@foxmail.com" }
  s.source       = { :git => "http://gitee.com/FBusiness.git", :tag => s.version.to_s }

  s.ios.deployment_target = "10.0"
  
  s.default_subspecs = 'Base'
  
  s.dependency 'RxCocoa'
  s.dependency 'SnapKit'
  s.dependency 'MJRefresh'
  
  
  # ----------------------- Core ---------------------
  s.subspec 'Core' do |ss|
    ss.source_files = 'FBusiness/Classes/*.h'
    ss.public_header_files = 'Fbusiness/Classes/*.h'
  end

  # ----------------------- Base ---------------------
  s.subspec 'Base' do |ss|

    ss.source_files = 'FBusiness/Classes/Base/*.swift'
    ss.resources = ['FBusiness/Assets/Base/*.png']

    ss.subspec 'Utilities' do |sss|
      sss.source_files = 'FBusiness/Classes/Base/Utilities/*.swift'

      sss.frameworks = 'Foundation'
    end

    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/Base/View/**/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'Segmentio'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
      sss.dependency 'SwiftX/Globals'
      sss.dependency 'SwiftX/ThirdParty/Kingfisher'
      sss.dependency 'SwiftX/ThirdParty/Toaster'
      sss.dependency 'SwiftX/ThirdParty/Realm'
    end

    ss.subspec 'Model' do |sss|
      sss.source_files = 'FBusiness/Classes/Base/Model/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
    end

    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/Base/VModel/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
    end

    ss.subspec 'Http' do |sss|
      sss.source_files = 'FBusiness/Classes/Base/Http/*.swift'

      sss.frameworks = 'Foundation'
      sss.dependency 'SwiftX/JSON'
      sss.dependency 'SwiftX/NetworkRx'
      sss.dependency 'FBusiness/Base/Utilities'
    end

#    ss.dependency 'FBusiness/Core'
  end
  
  # ************************  FreshClient  *********************
  
  
  # ----------------------- Config ---------------------
  s.subspec 'Config' do |ss|
    
    ss.source_files = 'FBusiness/Classes/Config/*.{swift,h,m,mm}'
    ss.public_header_files = 'FBusiness/Classes/Config/*.h'

    ss.dependency 'SwiftX/AppVersion'
    ss.dependency 'SwiftX/OpenSDK/Baidu/Location'
    ss.dependency 'SwiftX/OpenSDK/Baidu/Map'
    ss.dependency 'SwiftX/OpenSDK/Alipay'
    ss.dependency 'SwiftX/OpenSDK/WeChat'
    ss.dependency 'SwiftX/OpenSDK/QQ'
    ss.dependency 'SwiftX/OpenSDK/Weibo'
    ss.dependency 'SwiftX/OpenSDK/JPush'
  end
  

  # ----------------------- Common  -------------------
  s.subspec 'Common' do |ss|

    ss.source_files = 'FBusiness/Classes/Common/*.swift'
    ss.resources = ['FBusiness/Assets/Common/*.png']
    
    ss.subspec 'Splash' do |sss|
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Splash/View/**/*.swift'
        ssss.resources = ['FBusiness/Classes/Common/Splash/View/**/*.{storyboard,xib}']
        
        ssss.frameworks = 'UIKit', 'Foundation'
        ssss.dependency 'SwiftX/Extensions'
        ssss.dependency 'SwiftX/View'
      end
    end
    
    ss.subspec 'HouseKeeping' do |sss|
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/HouseKeeping/View/**/*.swift'
        ssss.resources = ['FBusiness/Classes/Common/HouseKeeping/View/**/*.{storyboard,xib}']
        
        ssss.frameworks = 'UIKit', 'Foundation'
        ssss.dependency 'SwiftX/Extensions'
        ssss.dependency 'SwiftX/View'
      end
      
      sss.subspec 'VModel' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/HouseKeeping/VModel/*.swift'
        
        ssss.frameworks = 'UIKit', 'Foundation'
      end
    end
    
    ss.subspec 'Message' do |sss|
        sss.subspec 'View' do |ssss|
            ssss.source_files = 'FBusiness/Classes/Common/Message/View/**/*.swift'
            ssss.resources = ['FBusiness/Classes/Common/Message/View/**/*.{storyboard,xib}']
            
            ssss.frameworks = 'UIKit', 'Foundation'
            ssss.dependency 'SwiftX/Extensions'
            ssss.dependency 'SwiftX/View'
        end
        
        sss.subspec 'VModel' do |ssss|
            ssss.source_files = 'FBusiness/Classes/Common/Message/VModel/*.swift'
            
            ssss.frameworks = 'UIKit', 'Foundation'
        end
    end
    
    ss.subspec 'Address' do |sss|
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Address/View/**/*.swift'
        ssss.resources = ['FBusiness/Classes/Common/Address/View/**/*.{storyboard,xib}']
        
        ssss.frameworks = 'UIKit', 'Foundation'
        ssss.dependency 'SwiftX/Extensions'
        ssss.dependency 'SwiftX/View'
      end
      
      sss.subspec 'VModel' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Address/VModel/*.swift'
        
        ssss.frameworks = 'UIKit', 'Foundation'
      end
    end

    ss.subspec 'Order' do |sss|
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Order/View/**/*.swift'
        ssss.resources = ['FBusiness/Classes/Common/Order/View/**/*.{storyboard,xib}']

        ssss.frameworks = 'UIKit', 'Foundation'
        ssss.dependency 'SwiftX/Extensions'
        ssss.dependency 'SwiftX/View'
      end
 
      sss.subspec 'VModel' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Order/VModel/*.swift'
 
        ssss.frameworks = 'UIKit', 'Foundation'
      end
    end

    ss.subspec 'Goods' do |sss|

      sss.resources = ['FBusiness/Assets/Goods/*.{png}']

      sss.subspec 'View' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Goods/View/**/*.swift'
        ssss.resources = ['FBusiness/Classes/Common/Goods/View/**/*.{storyboard,xib}']

        ssss.frameworks = 'UIKit', 'Foundation'
        ssss.dependency 'SwiftX/Extensions'
        ssss.dependency 'SwiftX/View'
      end
 
      sss.subspec 'VModel' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Goods/VModel/*.swift'
 
        ssss.frameworks = 'UIKit', 'Foundation'
     end
    end

    ss.subspec 'Search' do |sss|

      sss.resources = ['FBusiness/Assets/Search/*.png']

      sss.subspec 'View' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Search/View/**/*.swift'
        ssss.resources = ['FBusiness/Classes/Common/Search/View/**/*.{storyboard,xib}']

        ssss.frameworks = 'UIKit', 'Foundation'
        ssss.dependency 'SwiftX/Extensions'
        ssss.dependency 'SwiftX/View'
      end
      
      sss.subspec 'VModel' do |ssss|
        ssss.source_files = 'FBusiness/Classes/Common/Search/VModel/*.swift'
 
        ssss.frameworks = 'UIKit', 'Foundation'
      end
 
    end

    ss.dependency 'SnapKit'
    ss.dependency 'Kingfisher'

  end

  # ----------------------- Home ---------------------
  s.subspec 'Home' do |ss|

    ss.source_files = 'FBusiness/Classes/Home/*.swift'
    ss.resources = ['FBusiness/Assets/Home/*.png']

    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/Home/View/**/*.swift'
      sss.resources = ['FBusiness/Classes/Home/View/**/*.{storyboard,xib}']

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
      sss.dependency 'SnapKit'
      sss.dependency 'Kingfisher'
    end

    ss.subspec 'Model' do |sss|
      sss.source_files = 'FBusiness/Classes/Home/Model/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
    end

    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/Home/VModel/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
    end

    ss.dependency 'FBusiness/Common'
  end

  # ----------------------- Category ---------------------
  s.subspec 'Category' do |ss|

    ss.source_files = 'FBusiness/Classes/Category/*.swift'

    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/Category/View/**/*.swift'
      sss.resources = ['FBusiness/Classes/Category/View/**/*.{storyboard,xib}']

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
      sss.dependency 'SwiftX/Cache'
	  sss.dependency 'SnapKit'
	  sss.dependency 'Kingfisher'
    end

    ss.subspec 'Model' do |sss|
      sss.source_files = 'FBusiness/Classes/Category/Model/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
    end

    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/Category/VModel/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
    end

    ss.dependency 'FBusiness/Common'
  end

  # ----------------------- Car ---------------------
  s.subspec 'Car' do |ss|

    ss.source_files = 'FBusiness/Classes/Car/*.swift'
    ss.resources = ['FBusiness/Assets/Car/*.png']

    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/Car/View/**/*.swift'
      sss.resources = ['FBusiness/Classes/Car/View/**/*.{storyboard,xib}']

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
    end

    ss.subspec 'Model' do |sss|
      sss.source_files = 'FBusiness/Classes/Car/Model/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
    end

    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/Car/VModel/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
    end

    ss.dependency 'FBusiness/Common'
  end

  # ----------------------- Mine ---------------------
  s.subspec 'Mine' do |ss|

    ss.source_files = 'FBusiness/Classes/Mine/*.swift'
    ss.resources = ['FBusiness/Assets/Mine/*.png']

    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/Mine/View/**/*.swift'
      sss.resources = ['FBusiness/Classes/Mine/View/**/*.{storyboard,xib}']

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
    end

    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/Mine/VModel/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
    end

    ss.dependency 'FBusiness/Common'
  end

  # ----------------------- Login ---------------------
  s.subspec 'Login' do |ss|

    ss.resources = ['FBusiness/Assets/Login/*.png']
    ss.source_files = 'FBusiness/Classes/Login/*.swift'

    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/Login/View/**/*.swift'
      sss.resources = ['FBusiness/Classes/Login/View/**/*.{storyboard,xib}']

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
    end

    ss.subspec 'Model' do |sss|
      sss.source_files = 'FBusiness/Classes/Login/Model/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
    end

    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/Login/VModel/*.swift'

      sss.frameworks = 'UIKit', 'Foundation'
    end

  end
  
  
  # ************************  FreshDelivery  *********************
  
  # ----------------------- DConfig ---------------------
  s.subspec 'DConfig' do |ss|
    
    ss.source_files = 'FBusiness/Classes/DConfig/*.swift'

    ss.dependency 'SwiftX/OpenSDK/Baidu/Location'
    ss.dependency 'SwiftX/OpenSDK/Baidu/Map'
  end
  
  # ----------------------- DLogin ---------------------
  s.subspec 'DLogin' do |ss|
    
    ss.resources = ['FBusiness/Assets/DLogin/*.png']
    ss.source_files = 'FBusiness/Classes/DLogin/*.swift'
    
    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/DLogin/View/**/*.swift'
      sss.resources = ['FBusiness/Classes/DLogin/View/**/*.{storyboard,xib}']
      
      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
    end
    
    ss.subspec 'Model' do |sss|
      sss.source_files = 'FBusiness/Classes/DLogin/Model/*.swift'
      
      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
    end
    
    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/DLogin/VModel/*.swift'
      
      sss.frameworks = 'UIKit', 'Foundation'
    end
    
  end
  
  # ----------------------- DHome ---------------------
  s.subspec 'DHome' do |ss|
    
    ss.source_files = 'FBusiness/Classes/DHome/*.swift'
    ss.resources = ['FBusiness/Assets/DHome/*.png']
    
    ss.subspec 'View' do |sss|
      sss.source_files = 'FBusiness/Classes/DHome/View/**/*.swift'
      sss.resources = ['FBusiness/Classes/DHome/View/**/*.{storyboard,xib}']
      
      sss.frameworks = 'UIKit', 'Foundation'
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
      sss.dependency 'SnapKit'
      sss.dependency 'Kingfisher'
    end
    
    ss.subspec 'Model' do |sss|
      sss.source_files = 'FBusiness/Classes/DHome/Model/*.swift'
      
      sss.frameworks = 'UIKit', 'Foundation'
    end
    
    ss.subspec 'VModel' do |sss|
      sss.source_files = 'FBusiness/Classes/DHome/VModel/*.swift'
      
      sss.frameworks = 'UIKit', 'Foundation'
    end
    
    ss.dependency 'FBusiness/Common/Goods'
  end
  
end
