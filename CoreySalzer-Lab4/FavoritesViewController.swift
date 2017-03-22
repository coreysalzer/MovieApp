//
//  FavoritesViewController.swift
//  CoreySalzer-Lab4
//
//  Created by Corey Salzer on 3/2/17.
//  Copyright © 2017 Corey Salzer. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    var movieTitles:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.favoritesTableView.dataSource = self
        self.favoritesTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            var favorites = UserDefaults.standard.array(forKey: "favorites") as? [String]
            if favorites == nil {
                favorites! = []
            }
            self.movieTitles = favorites!
            DispatchQueue.main.async {
                self.favoritesTableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        myCell.textLabel?.text = self.movieTitles[indexPath.row]
        return myCell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.movieTitles.remove(at: indexPath.row)
            self.favoritesTableView.deleteRows(at: [indexPath], with: .automatic)
            
            var favorites = UserDefaults.standard.array(forKey: "favorites") as! [String]
            favorites.remove(at: indexPath.row)
            UserDefaults.standard.set(favorites, forKey:"favorites")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FavoritesViewSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "FavoritesViewSegue" {
            let destination = segue.destination as? DetailViewController
            let movieIndex = sender as! Int
            destination!.movie = fetchMovieWithTitle(title: movieTitles[movieIndex])
        }
    }

    @IBAction func clearAllButtonPressed(_ sender: Any) {
        self.movieTitles.removeAll()
        favoritesTableView.reloadData()
        UserDefaults.standard.set([], forKey:"favorites")
    }
    
    private func fetchMovieWithTitle(title: String) -> Movie {
        let urlTitle = title.replacingOccurrences(of: " ", with: "+")
        let json = getJSON("http://www.omdbapi.com/?t=" + urlTitle)
        let title = json["Title"].stringValue
        let id = json["imdbID"].stringValue
        let year = json["Year"].stringValue
        let type = json["Type"].stringValue
        let imageUrl = json["Poster"].stringValue
        return Movie(title: title, id: id, year: year, type: type, imageUrl: imageUrl)
    }
    
    private func getJSON(_ url: String) -> JSON {
        if let url = URL(string: url){
            if let data = try? Data(contentsOf: url) {
                let json = JSON(data: data)
                return json
            } else {
                return JSON.null
            }
        } else {
            return JSON.null
        }
    }
}
