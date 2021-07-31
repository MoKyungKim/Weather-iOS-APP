//
//  ViewController.swift
//  WeatherApp
//  Created by 김모경 on 2021/07/28.

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    var topInset = CGFloat(0.0)
    //첫번재 셀의 높이를 가져와야함
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if topInset == 0.0{
            let firstIndexPath = IndexPath(row: 0, section: 0)
            if let cell = listTableView.cellForRow(at: firstIndexPath){ //첫번째 셀을 가져옴
                topInset = listTableView.frame.height - cell.frame.height   //위쪽 여백 높이
                
                //값 넣기
                var inset = listTableView.contentInset
                inset.top = topInset
                listTableView.contentInset = inset  //위쪽에 여백 추가됨
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //배경 색 설정
        listTableView.backgroundColor = .clear
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
        
        //고정된 임시좌표 사용할 시
//        let location = CLLocation(latitude: 37.498206, longitude: 127.02761)
//        WeatherDataSource.shared.fetch(location: location){
//            self.listTableView.reloadData()
//        }
        
        LocationManager.shared.updateLocation()

        NotificationCenter.default.addObserver(forName: WeatherDataSource.weatherInfoDidUpdate, object: nil, queue: .main){ (noti) in
            self.listTableView.reloadData()
            self.locationLabel.text = LocationManager.shared.currentLocationTitle
    
            //35.130134, 126.890895 우리 집
            //37.498206 127.02761 강남역
        }
        
    }

}

//데이터 소스
extension ViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0:
            return 1    //현재 날씨 표시 => 셀 하나만 표시하면 됨
        case 1:         //예보 데이터
            return WeatherDataSource.shared.forecastList.count  //예보의 수만큼 셀이 표시됨
            //return 0
        default:
            return 0
        }
        
    }
    
    //셀을 리턴하는 코드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
            //-> cell을 SummaryTableViewCell으로 타입캐스팅함
            
            if let weather = WeatherDataSource.shared.summary?.weather.first, let main = WeatherDataSource.shared.summary?.main{
                //weather: 현재날씨, 아이콘의 이름이 저장 / main: 기온 저장되어있음
                //두 가지 모두 바인딩
                
                //데이터를 채움
                cell.weatherImageView.image = UIImage(named: weather.icon)
                cell.statusLabel.text = weather.description
                cell.minMaxLabel.text = "최고 \(main.temp_max.temperatureString)  최소 \(main.temp_min.temperatureString)"
                cell.currentTemperatureLabel.text = "\(main.temp.temperatureString)"
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
        
        //표시할 데이터를 상수에 바인딩해서 저장
        let target = WeatherDataSource.shared.forecastList[indexPath.row]
        cell.dateLabel.text = target.date.dateString
        cell.timeLabel.text = target.date.timeStirng
        cell.weatherImageView.image = UIImage(named: target.icon)
        cell.statusLabel.text = target.weather
        cell.temperatureLabel.text = target.temperature.temperatureString
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
}
