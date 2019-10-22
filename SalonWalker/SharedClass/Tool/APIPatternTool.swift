//
//  APIPatternTool.swift
//  SalonWalker
//
//  Created by Daniel on 2018/6/11.
//  Copyright © 2018年 skywind. All rights reserved.
//

import Foundation

struct APIPatternTool {
    
    static let S004 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "lang": [
            {
                 "slId": 1,
                 "langCode": "zh",
                 "langName": "繁體中文(Traditional Chinese)"
            },
            {
                 "slId": 2,
                 "langCode": "cn",
                 "langName": "簡體中文(Simplfied Chinese)"
            },
            {
                 "slId": 3,
                 "langCode": "en",
                 "langName": "英文(English)"
            }
        ]
    }
}
"""
    
    static let S005 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "city": [
            {
                "areaRangCode": "A",
                "cityName": "台北市",
                "area": [
                  {
                    "zcId": 1,
                    "areaName": "中正區",
                    "zipCode": 100
                  },
                  {
                    "zcId": 2,
                    "areaName": "大同區",
                    "zipCode": 103
                  }
                ]
            },
            {
                "areaRangCode": "A",
                "cityName": "基隆市",
                "area": [
                  {
                    "zcId": 13,
                    "areaName": "仁愛區",
                    "zipCode": 200
                  },
                  {
                    "zcId": 14,
                    "areaName": "信義區",
                    "zipCode": 201
                  }
                ]
            },
            {
                "areaRangCode": "A",
                "cityName": "新北市",
                "area": [
                  {
                    "zcId": 13,
                    "areaName": "仁愛區",
                    "zipCode": 200
                  },
                  {
                    "zcId": 14,
                    "areaName": "信義區",
                    "zipCode": 201
                  }
                ]
            },
            {
                "areaRangCode": "A",
                "cityName": "新北市",
                "area": [
                  {
                    "zcId": 13,
                    "areaName": "仁愛區",
                    "zipCode": 200
                  },
                  {
                    "zcId": 14,
                    "areaName": "信義區",
                    "zipCode": 201
                  }
                ]
            },
            {
                "areaRangCode": "A",
                "cityName": "新北市",
                "area": [
                  {
                    "zcId": 13,
                    "areaName": "仁愛區",
                    "zipCode": 200
                  },
                  {
                    "zcId": 14,
                    "areaName": "信義區",
                    "zipCode": 201
                  }
                ]
            },
            {
                "areaRangCode": "A",
                "cityName": "新北市",
                "area": [
                  {
                    "zcId": 13,
                    "areaName": "仁愛區",
                    "zipCode": 200
                  },
                  {
                    "zcId": 14,
                    "areaName": "信義區",
                    "zipCode": 201
                  }
                ]
            },
            {
                "areaRangCode": "A",
                "cityName": "新北市",
                "area": [
                  {
                    "zcId": 13,
                    "areaName": "仁愛區",
                    "zipCode": 200
                  },
                  {
                    "zcId": 14,
                    "areaName": "信義區",
                    "zipCode": 201
                  }
                ]
            },
            {
                "areaRangCode": "A",
                "cityName": "新北市",
                "area": [
                  {
                    "zcId": 13,
                    "areaName": "仁愛區",
                    "zipCode": 200
                  },
                  {
                    "zcId": 14,
                    "areaName": "信義區",
                    "zipCode": 201
                  }
                ]
            }
        ]
    }
}
"""
    
    static let M005 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "mId": 1,
        "email": "test@test.com",
        "internationalPrefix": "886",
        "phone": "0900123456",
        "nickName": "AB",
        "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
        "cautionTotal": 1,
        "missTotal": 0,
        "slId": 1
    }
}
"""
   
    static let H001 = """
{
   "syscode": 200,
   "sysmsg": "",
   "data": {
        "type1":
        {
            "seArticlesId": 1,
            "title": "精選文章1精選文章1精選文章1精選文章1精選文章1精選文章1精選文章1精選文章1",
            "titleColor": "#000000",
            "frame": "circle",
            "imgUrl": "http://letsfilm.org/wp-content/uploads/2018/06/nacho-rochon-423005-unsplash.jpg",
            "startTime": "2018-04-02 15:45:23"
        },
        "type2":
        {
            "seArticlesId": 2,
            "title": "精選文章2精選文章2精選文章2精選文章2精選文章2精選文章2精選文章2",
            "titleColor": "#000000",
            "frame": "rectangle",
            "imgUrl": "https://i0.wp.com/img.hojenjen.com/uploads/2017/10/1506964794-4efdd2f969559e8b1c92e99f32ded48e.jpg?resize=1801%2C1200",
            "startTime": "2018-04-02 15:45:23"
        },
        "type3":
        {
            "seArticlesId": 3,
            "title": "精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3精選文章3",
            "titleColor": "#000000",
            "frame": "circle",
            "imgUrl": "https://www.fotobeginner.com/wp-content/uploads/2015/01/186-748x499.jpg",
            "startTime": "2018-04-02 15:45:23"
        },
       "TIPS": [
           {
               "seArticlesId": 4,
               "title": "精選文章1",
               "titleColor": "#000000",
               "imgUrl": "https://www.fotobeginner.com/wp-content/uploads/2015/01/186-748x499.jpg",
               "startTime": "2018-04-02 15:45:23"
          },
          {
               "seArticlesId": 5,
               "title": "精選文章2",
               "titleColor": "#000000",
               "imgUrl": "https://www.fotobeginner.com/wp-content/uploads/2013/08/31-645x429.jpg",
               "startTime": "2018-04-02 15:45:50"
          },
          {
               "seArticlesId": 6,
               "title": "精選文章3",
               "titleColor": "#000000",
               "imgUrl": "http://pic.pimg.tw/sofunjean/45cb60905b9f1fbd2224b09ba862a70f.jpg",
               "startTime": "2018-04-02 15:46:50"
          }
       ],
        "TOOLS": [
           {
               "seArticlesId": 7,
               "title": "精選文章1",
               "titleColor": "#000000",
               "imgUrl": "https://s.zimedia.com.tw/s/WswRY9-1",
               "startTime": "2018-04-02 15:45:23"
          },
          {
               "seArticlesId": 8,
               "title": "精選文章2",
               "titleColor": "#000000",
               "imgUrl": "https://www.bomb01.com/upload/news/original/69afe7831cbfca2a89765a0f0c536f12.jpg",
               "startTime": "2018-04-02 15:45:50"
          },
          {
               "seArticlesId": 9,
               "title": "精選文章3",
               "titleColor": "#000000",
               "imgUrl": "http://www.xinhuanet.com//photo/2014-05/21/126528288_14006401287761n.jpg",
               "startTime": "2018-04-02 15:46:50"
          }
       ]
   }
}
"""
    
    static let H007 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "meta": {
              "count": 10,
              "page": 1,
              "pMax": 30,
              "totalPage": 1
        },
        "designerList": [
            {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
                "distance": 1,
                "lat": 25.052430766638268,
                "lng": 121.55223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/b0d629d3b3d14cc6a7f3c908ce51a131/b0d629d3b3d14cc6a7f3c908ce51a131.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
                "distance": 1,
                "lat": 25.072430766638268,
                "lng": 121.53223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/b0d629d3b3d14cc6a7f3c908ce51a131/b0d629d3b3d14cc6a7f3c908ce51a131.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
                "distance": 1,
                "lat": 25.055430766638268,
                "lng": 121.51223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/b0d629d3b3d14cc6a7f3c908ce51a131/b0d629d3b3d14cc6a7f3c908ce51a131.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
                "distance": 1,
                "lat": 25.015430766638268,
                "lng": 121.50223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/b0d629d3b3d14cc6a7f3c908ce51a131/b0d629d3b3d14cc6a7f3c908ce51a131.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
                "distance": 1,
                "lat": 25.075430766638268,
                "lng": 121.52223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/b0d629d3b3d14cc6a7f3c908ce51a131/b0d629d3b3d14cc6a7f3c908ce51a131.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
                "distance": 1,
                "lat": 25.051430766638268,
                "lng": 121.58223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/b0d629d3b3d14cc6a7f3c908ce51a131/b0d629d3b3d14cc6a7f3c908ce51a131.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg",
                "distance": 1,
                "lat": 25.057430766638268,
                "lng": 121.54223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/b0d629d3b3d14cc6a7f3c908ce51a131/b0d629d3b3d14cc6a7f3c908ce51a131.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/8b255e4d06e744aabbf13c1f757bcf9d/8b255e4d06e744aabbf13c1f757bcf9d.jpg",
                "distance": 1,
                "lat": 25.062430766638268,
                "lng": 121.56223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/4b6e080b8dd94df487cdf05afc27a2ae/4b6e080b8dd94df487cdf05afc27a2ae.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/8b255e4d06e744aabbf13c1f757bcf9d/8b255e4d06e744aabbf13c1f757bcf9d.jpg",
                "distance": 1,
                "lat": 25.042430766638268,
                "lng": 121.54223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/4b6e080b8dd94df487cdf05afc27a2ae/4b6e080b8dd94df487cdf05afc27a2ae.jpg"
           },
           {
                "ouId": 2,
                "dId": 1,
                "isRes": true,
                "isTop": true,
                "isFav": true,
                "nickName": "ABC",
                "headerImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/8b255e4d06e744aabbf13c1f757bcf9d/8b255e4d06e744aabbf13c1f757bcf9d.jpg",
                "distance": 1,
                "lat": 25.058430766638268,
                "lng": 121.54223191940268,
                "experience": 1,
                "licenseName": "丙級女子美髮技術士證照",
                "serviceItem": "剪髮",
                "servicePrice": 700,
                "evaluationAve": 4.3,
                "evaluationTotal": 1100,
                "coverImgUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserCoverImg/4b6e080b8dd94df487cdf05afc27a2ae/4b6e080b8dd94df487cdf05afc27a2ae.jpg"
           }
        ]
    }
}
"""
    
    static let H010 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "ouType": "Designer"
    }
}
"""
    
    static let H011 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "meta": {
              "count": 20,
              "page": 1,
              "pMax": 30,
              "totalPage": 1
        },
        "providerList": [
            {
                "ouId": 3,
                "pId": 2,
                "isFav": true,
                "nickName": "ABC",
                "distance": 1,
                "lat": 24.2201031,
                "lng": 120.9558744,
                "city": "台北市",
                "area": "中正區",
                "svcHoursPrices": {
                     "workdayPrices": 1700,
                     "holidayPrices": 1000
                },
                "svcTimesPrices": {
                     "workdayPrices": 700,
                     "holidayPrices": 1000
                },
                "svcLeasePrices": {
                     "prices": 2300
                },
                "evaluationAve": 4.3,
                "evaluationTotal": 1153,
                "coverImgUrl": "http://[DomainName]/Upload/OperatingUserCoverImg/cd5cbcc9c7ed41bd8baf5161322e4a44/ea02f30055a74ca788568521167f571e.jpeg"
           },
            {
                "ouId": 3,
                "pId": 3,
                "isFav": true,
                "nickName": "ABC",
                "distance": 1,
                "lat": 24.2201031,
                "lng": 120.9558744,
                "city": "台北市",
                "area": "中正區",
                "svcTimesPrices": {
                     "workdayPrices": 700,
                     "holidayPrices": 1000
                },
                "svcLeasePrices": {
                     "prices": 2300
                },
                "evaluationAve": 4.3,
                "evaluationTotal": 1153,
                "coverImgUrl": "http://[DomainName]/Upload/OperatingUserCoverImg/cd5cbcc9c7ed41bd8baf5161322e4a44/ea02f30055a74ca788568521167f571e.jpeg"
           },
            {
                "ouId": 3,
                "pId": 4,
                "isFav": true,
                "nickName": "ABC",
                "distance": 1,
                "lat": 24.2201031,
                "lng": 120.9558744,
                "city": "台北市",
                "area": "中正區",
                "svcLeasePrices": {
                     "prices": 2300
                },
                "evaluationAve": 4.3,
                "evaluationTotal": 1153,
                "coverImgUrl": "http://[DomainName]/Upload/OperatingUserCoverImg/cd5cbcc9c7ed41bd8baf5161322e4a44/ea02f30055a74ca788568521167f571e.jpeg"
           },
            {
                "ouId": 3,
                "pId": 5,
                "isFav": true,
                "nickName": "ABC",
                "distance": 1,
                "lat": 24.2201031,
                "lng": 120.9558744,
                "city": "台北市",
                "area": "中正區",
                
                "svcTimesPrices": {
                     "workdayPrices": 700,
                     "holidayPrices": 1000
                },
                "svcLeasePrices": {
                     "prices": 2300
                },
                "evaluationAve": 4.3,
                "evaluationTotal": 1153,
                "coverImgUrl": "http://[DomainName]/Upload/OperatingUserCoverImg/cd5cbcc9c7ed41bd8baf5161322e4a44/ea02f30055a74ca788568521167f571e.jpeg"
           },
            {
                "ouId": 3,
                "pId": 6,
                "isFav": true,
                "nickName": "ABC",
                "distance": 1,
                "lat": 24.2201031,
                "lng": 120.9558744,
                "city": "台北市",
                "area": "中正區",
                "evaluationAve": 4.3,
                "evaluationTotal": 1153,
                "coverImgUrl": "http://[DomainName]/Upload/OperatingUserCoverImg/cd5cbcc9c7ed41bd8baf5161322e4a44/ea02f30055a74ca788568521167f571e.jpeg"
           }
        ]
    }
}
"""
    
    static let O011 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "ouType": "Designer",
        "msg": "修改成功！"
    }
}
"""
    
    static let O014 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "ouType": "Designer"
    }
}
"""
    
    static let O017 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 1,
        "smsAmount": 2,
        "msg": "發送成功！",
        "actTime": "2018-03-29 11:23:06"
    }
}
"""
    
    
    static let SH001 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "openHour":[
           {
            "weekDay": 0,
            "from": "11:00",
            "end": "20:00"
           },
           {
            "weekDay": 2,
            "from": "10:00",
            "end": "22:00"
           },
           {
            "weekDay": 3,
            "from": "10:00",
            "end": "22:00"
           },
           {
            "weekDay": 4,
            "from": "10:00",
            "end": "22:00"
           },
           {
            "weekDay": 5,
            "from": "10:00",
            "end": "22:00"
           },
           {
            "weekDay": 6,
            "from": "11:00",
            "end": "20:00"
           }
       ]
    }
}
"""
    
    static let DS001 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "itemId": "5b03eae343aa1204b4af48eb",
        "ouId": 2,
        "svcCategory": [
                {
            "sfciiId": 10,
            "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMq9LnzQE3XLnUMl7-qpQHMco8ASoJQB1L75meGJHHP8ES7ZBpuA",
            "type": "one",
            "name": "剪髮",
            "price": null,
            "hours": 0,
            "svcClass": null
            },
            {
            "sfciiId": 10,
            "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMq9LnzQE3XLnUMl7-qpQHMco8ASoJQB1L75meGJHHP8ES7ZBpuA",
            "name": "染髮",
            "type": "one",
            "price": 0,
            "hours": 0,
            "svcClass": [
              {
                  "open": true,
                  "name": "全染",
                  "price": 0,
                  "hours": 0,
                  "svcItems": [
                    {
                        "name": "短髮",
                        "price": null,
                        "hours": 0
                    },
                    {
                        "name": "中長髮",
                        "price": null,
                        "hours": 0
                    }
                  ],
                 "svcProduct": [
                      {
                          "dsciId": 3,
                          "brand": "品牌A",
                          "product": "產品3",
                          "imgUrl": "http://www.idealez.com/tmresources/store/600473/%E8%83%9C%E8%82%BD_200X200.jpg"
                      },
                      {
                          "dsciId": 4,
                          "brand": "品牌A",
                          "product": "產品4",
                          "imgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
                     }
                  ]
               },
                {
                  "open": false,
                  "name": "設計染",
                  "price": 0,
                  "hours": 0,
                  "svcItems": [
                    {
                        "name": "短髮",
                        "price": null,
                        "hours": 0
                    },
                    {
                        "name": "中長髮",
                        "price": null,
                        "hours": 0
                    },
                    {
                        "name": "長髮",
                        "price": null,
                        "hours": 0
                    },
                    {
                        "name": "特長髮",
                        "price": null,
                        "hours": 0
                    }
                  ],
                 "svcProduct": [
                      {
                          "dsciId": 3,
                          "brand": "品牌A",
                          "product": "產品3",
                          "imgUrl": "http://www.idealez.com/tmresources/store/600473/%E8%83%9C%E8%82%BD_200X200.jpg"
                      },
                      {
                          "dsciId": 4,
                          "brand": "品牌A",
                          "product": "產品4",
                          "imgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
                     }
                  ]
               },
                {
                  "open": true,
                  "name": "補染髮根",
                  "price": null,
                  "hours": 0,
                  "svcItems": null,
                 "svcProduct": [
                      {
                          "dsciId": 3,
                          "brand": "品牌A",
                          "product": "產品3",
                          "imgUrl": "http://www.idealez.com/tmresources/store/600473/%E8%83%9C%E8%82%BD_200X200.jpg"
                      },
                      {
                          "dsciId": 4,
                          "brand": "品牌A",
                          "product": "產品4",
                          "imgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
                     }
                  ]
               }
             ]
            },
            {
            "sfciiId": 10,
            "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMq9LnzQE3XLnUMl7-qpQHMco8ASoJQB1L75meGJHHP8ES7ZBpuA",
            "name": "頭皮養護",
            "type": "one",
            "price": 0,
            "hours": 0,
            "svcClass": [
              {
                  "open": false,
                  "name": "頭皮養護",
                  "price": null,
                  "hours": 0,
                  "svcItems": null,
                  "svcProduct": null
               },
                {
                  "open": false,
                  "name": "頭皮淨化",
                  "price": null,
                  "hours": 0,
                  "svcItems": null,
                  "svcProduct": null
               },
                {
                  "open": false,
                  "name": "頭皮平衡",
                  "price": null,
                  "hours": 0,
                  "svcItems": null,
                  "svcProduct": null
               }
             ]
            }
        ]
    }
}
"""
    
    static let DS004 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "meta": {
              "count": 50,
              "page": 1,
              "pMax": 30,
              "totalPage": 2
        },
        "svcPlace": [
            {
                "pId": 2,
                "nickName": "AB",
                "cityName": "台北市",
                "areaName": "中正區",
                "address": "民權東路三段37號2F",
                "headerImgUrl": "http://[DomainName]/Upload/OperatingUserHeaderImg/cd5cbcc9c7ed41bd8baf5161322e4a44/cd5cbcc9c7ed41bd8baf5161322e4a44.jpeg"
           },
           {
                "pId": 5,
                "nickName": "AC",
                "cityName": "台北市",
                "areaName": "中正區",
                "address": "忠孝東路四段96-2號",
                "headerImgUrl": "http://[DomainName]/Upload/OperatingUserHeaderImg/cd5cbcc9c7ed41bd8baf5161322e4a44/cd5cbcc9c7ed41bd8baf5161322e4a44.jpeg"
           }
       ]
    }
}
"""
    
    static let DS005 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "meta": {
              "count": 1,
              "page": 1,
              "pMax": 1,
              "totalPage": 1
        },
        "svcPlace":[
            {
                "pId": 1,
                "nickName": "AA",
                "cityName": "台北市",
                "areaName": "中正區",
                "address": "民權東路三段37號",
                "headerImgUrl": "http://[DomainName]/Upload/OperatingUserHeaderImg/cd5cbcc9c7ed41bd8baf5161322e4a44/cd5cbcc9c7ed41bd8baf5161322e4a44.jpeg"
           }
       ]
    }
}
"""
    
    static let D005 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
      "pId": 1,
      "msg": "送出檢舉"
    }
}
"""
    
    static let DS006 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "msg": "新增成功！"
    }
}
"""
    
    static let DS007 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "msg": "刪除成功！"
    }
}
"""
 
    static let PS001 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
      "itemId": "5b053ca243aa1204b4af48f1",
      "ouId": 3,
      "svcHours": {
        "open": false,
        "svcHoursPrices": [
            {
                "weekDay": 0,
                "prices": 300
            },
            {
                "weekDay": 1,
                "prices": 150
            }
        ]
      },
      "svcTimes":{
        "open": true,
        "svcTimesPrices": [
            {
                "weekDay": 0,
                "prices": 500
           },
           {
                "weekDay": 1,
                "prices": 200
           }
        ]
      },
      "svcLongLease": {
        "open": false,
        "svcLongLeasePrices": [
            {
                "startDay": "2018-04-01",
                "endDay": "2018-04-30",
                "prices": 2000
           },
           {
                "startDay": "2018-04-15",
                "endDay": "2018-04-30",
                "prices": 1500
           }
        ]
      }
    }
}

"""
    
    static let TS001 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "ouType": "Designer",
        "bankCode": "008",
        "bankName": "玉山銀行",
        "bankBranch": "045678",
        "bankNum": "989877695687"
    }
}
"""
    
    static let TS002 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "msg": "修改成功！"
    }
}
"""
    static let TS003 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "bank": [
            {
                "bankCode": "004",
                "bankName": "臺灣銀行"
            },
            {
                "bankCode": "008",
                "bankName": "玉山銀行"
            }
        ]
    }
}
"""
    static let C001 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId": 2,
        "meta": {
              "count": 1,
              "page": 1,
              "pMax": 30,
              "totalPage": 3
        },
        "customerList": [
         {
            "mId": 1,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMq9LnzQE3XLnUMl7-qpQHMco8ASoJQB1L75meGJHHP8ES7ZBpuA"
         },
         {
            "mId": 2,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         },
         {
            "mId": 3,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         },
         {
            "mId": 4,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         },
         {
            "mId": 5,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         },
         {
            "mId": 6,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         },
         {
            "mId": 7,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         },
         {
            "mId": 8,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         },
         {
            "mId": 9,
            "nickName": "測試用",
            "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
         }
       ]
    }
}
"""
    
    static let C003 = """
    {
    "syscode": 200,
    "sysmsg": "",
    "data": {
      "ouId": 2,
      "mId": 1,
      "nickName": "AA",
      "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku",
      "hairType": 3,
      "scalp": 59
    }
}
"""
    
    static let C005 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
      "ouId": 2,
      "meta": {
              "count": 1,
              "page": 1,
              "pMax": 30,
              "totalPage": 1
      },
      "svcHistory":[
        {
           "mId": 1,
           "moId": 1,
           "orderTime":"2018/04/23",
           "svcContent": {
             "photoImgUrl": ["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku","https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMq9LnzQE3XLnUMl7-qpQHMco8ASoJQB1L75meGJHHP8ES7ZBpuA","https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMq9LnzQE3XLnUMl7-qpQHMco8ASoJQB1L75meGJHHP8ES7ZBpuA"],
             "hairStyle": {
                 "sex": "m",
                 "growth": 80,
                 "style": 2
             },
             "svcCategory": [
              {
                 "name": "染髮",
                 "price": 0,
                 "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku",
                 "svcClass": [
                 {
                   "name": "全染",
                   "price": 0,
                   "svcItems": [
                    {
                     "name": "長髮",
                     "price": 2300
                    }
                   ]
                 }
                ]
              },
              {
                 "name": "護髮",
                 "price": 0,
                 "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku",
                 "svcClass": [
                 {
                   "name": "深層保濕護髮",
                   "price": 0,
                   "svcItems": [
                    {
                     "name": "長髮",
                     "price": 5000
                    }
                   ]
                 }
                ]
              },
              {
                 "name": "頭皮養護",
                 "price": 0,
                 "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku",
                 "svcClass": [
                 {
                   "name": "頭皮淨化",
                   "price": 2000,
                   "svcItems": null
                 },
                 {
                   "name": "頭皮平衡",
                   "price": 2500,
                   "svcItems": null
                 }
                ]
              }
            ]
           }
        },
        {
           "mId": 1,
           "moId": 2,
           "orderTime":"2018/06/12",
           "svcContent": {
             "photoImgUrl": ["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"],
             "hairStyle": {
                 "sex": "f",
                 "growth": 65,
                 "style": 4
             },
             "svcCategory": [
              {
                 "name": "染髮",
                 "price": 0,
                 "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku",
                 "svcClass": [
                 {
                   "name": "全染",
                   "price": 0,
                   "svcItems": [
                    {
                     "name": "長髮",
                     "price": 2300
                    }
                   ]
                 }
                ]
              },
              {
                 "name": "護髮",
                 "price": 0,
                 "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku",
                 "svcClass": [
                 {
                   "name": "深層保濕護髮",
                   "price": 0,
                   "svcItems": [
                    {
                     "name": "長髮",
                     "price": 5000
                    }
                   ]
                 }
                ]
              },
              {
                 "name": "頭皮養護",
                 "price": 0,
                 "iconUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku",
                 "svcClass": [
                 {
                   "name": "頭皮淨化",
                   "price": 2000,
                   "svcItems": null
                 },
                 {
                   "name": "頭皮平衡",
                   "price": 2500,
                   "svcItems": null
                 }
                ]
              }
            ]
           }
        }
      ]
    }
}
"""
    
    static let C006 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
      "ouId": 2,
      "meta": {
        "count": 3,
        "page": 1,
        "pMax": 30,
        "totalPage": 2
      },
      "avgPrices": {
        "one": 1433,
        "month": 2150,
        "year": 4300
      },
      "svcPayHistory":[
        {
           "mId": 1,
           "orderTime": "2018/04/24",
           "payTotal": 1500
        },
        {
           "mId": 1,
           "orderTime": "2018/05/12",
           "payTotal": 800
        },
        {
           "mId": 1,
           "orderTime": "2018/05/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2018/06/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2018/07/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2018/08/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2018/09/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2018/10/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2018/11/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2018/12/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2019/01/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2019/02/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2019/03/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2019/04/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2019/05/31",
           "payTotal": 2000
        },
        {
           "mId": 1,
           "orderTime": "2019/05/31",
           "payTotal": 2000
        }
      ]
    }
}
"""
    static let OD001 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "mId": 2,
        "calendar": [
             {
                 "date": "2018-08-01",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://www.stockfeel.com.tw/wp-content/uploads/2015/09/design%E8%A8%AD%E8%A8%88%E5%B8%AB.jpg",
                     "isTop": false,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-02",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "http://www.wesleydandy.com/wp-content/uploads/2018/06/%E7%B0%A1%E5%B8%83%E4%B8%81%E9%BA%BB%E8%B1%86%E6%97%A520180529_180605_0001.jpg",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-07",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://www.icustomforu.com/wp-content/uploads/2018/04/%E5%A4%A7%E9%A0%AD.jpg",
                     "isTop": false,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  },
                  {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "http://www.mottimes.com/image/character/1420140331174531.jpg",
                     "isTop": false,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  },
                  {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-09",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://www.haircitymm.com/files/designer/designer-ann.png",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-14",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmr9ZS2bqjIR-x3SLATioLm9xbaNXXgFIwVDmDBC3HrVmNsWy6",
                     "isTop": false,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  },
                  {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-15",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-16",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-17",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-20",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-21",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-22",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-23",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-24",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-27",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-28",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-29",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             },
             {
                 "date": "2018-08-30",
                 "order": [
                 {
                     "orderTime": "2018-05-21 15:00:00",
                     "moId": 1,
                     "nickName": "設計師BBB",
                     "headerImgUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZAfIvJ32v9QHU9K906MrLLip61Pt1NW42PJTQNO52qP34Re_V",
                     "isTop": true,
                     "cityName": "台北市",
                     "areaName": "中正區",
                     "orderStatus": 2,
                     "orderStatusName": "已付訂金(已確定)"
                  }
                ]
             }
        ]
    }
}
"""
    
    static let OD003 = """
    {
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "mId": 2,
        "orderList": [
             {
                 "moId": 22,
                 "orderNo": "A1234567892018052401",
                 "nickName": "AAAA",
                 "headerImgUrl": "http://headerImgUrl......",
                 "isTop": true,
                 "cityName": "台北市",
                 "areaName": "中山區",
                 "langName": "中文",
                 "placeName": "魔法部屋-市府店",
                 "deposit": 300,
                 "finalPayment": 600,
                 "payTime": "2018-05-24 15:00:00",
                 "finishTime": "",
                 "orderStatus": 1,
                 "orderStatusName": "已付訂金",
                 "evaluateStatus": {
                    "statusName":"給評價",
                    "evaluation": null
                 }
             },
             {
                 "moId": 22,
                 "orderNo": "A1234567892018052401",
                 "nickName": "AAAA",
                 "headerImgUrl": "http://headerImgUrl......",
                 "isTop": true,
                 "cityName": "台中市",
                 "areaName": "北屯區",
                 "langName": "中文",
                 "placeName": "台中文創",
                 "deposit": 500,
                 "finalPayment": 1700,
                 "payTime": "2018-05-24 15:00:00",
                 "finishTime": "2018-06-24 17:00:00",
                 "orderStatus": 4,
                 "orderStatusName": "已完成",
                 "evaluateStatus": {
                    "statusName":"已給評價",
                    "evaluation": {
                        "point": 3,
                        "comment":"顆顆顆顆"
                    }
                 }
             },
             {
                 "moId": 22,
                 "orderNo": "A1234567892018052401",
                 "nickName": "AAAA",
                 "headerImgUrl": "http://headerImgUrl......",
                 "isTop": true,
                 "cityName": "台中市",
                 "areaName": "北屯區",
                 "langName": "中文",
                 "placeName": "台中文創",
                 "deposit": 500,
                 "finalPayment": 1700,
                 "payTime": "2018-05-24 15:00:00",
                 "finishTime": "2018-06-24 17:00:00",
                 "orderStatus": 4,
                 "orderStatusName": "已完成",
                 "evaluateStatus": {
                    "statusName":"給評價",
                    "evaluation": null
                 }
             }
        ]
    }
}
"""
    
    static let W001 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId":2,
        "meta": {
        "count": 3,
        "page": 1,
        "pMax": 30,
        "totalPage": 1
       },
        "photoList": [
            {
                "dwpId": 1,
                "description": "作品1",
                "photoUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg"
            },
            {
                "dwpId": 2,
                "description": "作品2",
                "photoUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/8b255e4d06e744aabbf13c1f757bcf9d/8b255e4d06e744aabbf13c1f757bcf9d.jpg"
            }
        ]
    }
}
"""
    static let W002 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId":2,
        "meta": {
        "count": 3,
        "page": 1,
        "pMax": 30,
        "totalPage": 1
       },
        "videoList": [
            {
                "dwvId": 1,
                "description": "作品1",
                "videoUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/0c75800dd9254495aef2f6bbc7546d62/0c75800dd9254495aef2f6bbc7546d62.jpg"
            },
            {
                "dwvId": 2,
                "description": "作品2",
                "videoUrl": "http://salonwalker-tst.skywind.com.tw:8025/Upload/OperatingUserHeaderImg/8b255e4d06e744aabbf13c1f757bcf9d/8b255e4d06e744aabbf13c1f757bcf9d.jpg"
            }
        ]
    }
}
"""
    
    static let W003 = """
{
    "syscode": 200,
    "sysmsg": "",
    "data": {
        "ouId":2,
        "meta": {
            "count": 3,
            "page": 1,
            "pMax": 30,
            "totalPage": 1
        },
        "albumsList": [
        {
            "dwaId": 1,
            "name": "大相簿",
            "description": "作品1",
            "coverUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Ke0gY8xwzq1Jlcym7nl2TyeWJQIhhJO78avAsmmcEcOWHUku"
            },
        {
            "dwaId": 2,
            "name": "相簿2",
            "description": "作品2",
            "coverUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMq9LnzQE3XLnUMl7-qpQHMco8ASoJQB1L75meGJHHP8ES7ZBpuA"
            }
        ]
    }
}
"""
}
