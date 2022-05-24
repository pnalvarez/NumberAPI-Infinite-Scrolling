//
//  ViewController.swift
//  NumberApiPrefetchDemo
//
//  Created by Pedro Alvarez on 14/05/22.
//

import UIKit

class ViewController: UIViewController {
    private var numbers: [NumberModel] = [] {
        didSet {
            numbers.sort(by: {
                $0.number! < $1.number!
            })
            tableView.reloadData()
        }
    }
    
    private var totalNumbers = 10 {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var tasks: [URLSessionDataTask] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.register(UINib(nibName: TableViewCell.defaultIdentifier,
                                 bundle: nil), forCellReuseIdentifier: TableViewCell.defaultIdentifier)
        initialFetch()
    }
    
    private func initialFetch() {
        (0..<10).forEach({
            fetchNumberData($0)
        })
    }
    
    private func fetchNumberData(_ number: Int) {
        let endpoint = "http://numbersapi.com/\(number)?json"
        guard let url = URL(string: endpoint) else { return }
        guard !tasks.contains(where: { $0.originalRequest?.url == url }) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data else { return }
            do {
                let number = try JSONDecoder().decode(NumberModel.self,
                                                      from: data)
                DispatchQueue.main.async {
                    self.numbers.append(number)
                }
            }
            catch {
                
            }
        }
        task.resume()
        tasks.append(task)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalNumbers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < numbers.count else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.defaultIdentifier,
                                                 for: indexPath) as! TableViewCell
        cell.label.text = numbers[indexPath.row].text
        return cell
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let filtered = indexPaths.filter({ $0.row >= totalNumbers - 1})
        if filtered.count > 0 {
            totalNumbers += 1
        }
        filtered.forEach({
            self.fetchNumberData($0.row)
        })
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach({
            guard let url = URL(string: "http://numbersapi.com/\($0)?json") else { return
            }
            guard let taskIndex = tasks.firstIndex(where: { $0.originalRequest?.url == url }) else {
                return
            }
            totalNumbers -= 1
            self.tasks[taskIndex].cancel()
            self.tasks.remove(at: taskIndex)
        })
    }
}

