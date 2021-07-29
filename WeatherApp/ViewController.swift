//
//  ViewController.swift
//  WeatherApp
//  Created by 김모경 on 2021/07/28.

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }


}

//데이터 소스
extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1    //현재 날씨 표시 => 셀 하나만 표시하면 됨
        case 1:         //예보 데이터
            return 0
        default:
            return 0
        }
        
    }
    
    //셀을 리턴하는 코드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
            //-> cell을 SummaryTableViewCell으로 타입캐스팅함
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
