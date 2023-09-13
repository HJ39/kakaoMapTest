//
//  SelectViewController.swift
//  kakaoMapTest
//
//  Created by 정호진 on 2023/09/13.
//

import Foundation
import UIKit

final class SelectViewController: UIViewController{
    
    /// MARK: 기능 리스트
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.title = "카카오맵 기능 목록"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectTableViewCell.self, forCellReuseIdentifier: SelectTableViewCell.identifier)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

extension SelectViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return List.viewControllers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectTableViewCell.identifier, for: indexPath) as? SelectTableViewCell else { return UITableViewCell() }
        cell.inputData(text: List.viewControllersName[indexPath.row])
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let nextPage = List.viewControllers[indexPath.row]
        navigationController?.pushViewController(nextPage, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.safeAreaLayoutGuide.layoutFrame.height/10
    }
}

final class SelectTableViewCell: UITableViewCell{
    static let identifier = "SelectTableViewCell"
    
    /// MARK: 선택할 목록 제목
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// MARK: add UI
    private func addUI(){
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: super.topAnchor),
            title.leadingAnchor.constraint(equalTo: super.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: super.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: super.bottomAnchor)
        ])
    }
    
    /// input Data
    func inputData(text: String){
        title.text = text
    }
}
