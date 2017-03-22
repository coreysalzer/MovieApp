//
//  MoviesViewController.swift
//  CoreySalzer-Lab4
//
//  Created by Corey Salzer on 3/2/17.
//  Copyright © 2017 Corey Salzer. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var moviesCollectionView: UICollectionView!

    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var titleNavigationItem: UINavigationItem!
    
    var movies:[Movie]!
    var theImageCache: [UIImage]!
    var selectedType:String = "movie"
    let types:[String] = ["movie", "series", "episode"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.movies = []
        self.theImageCache = []
        setupDelegatesAndDataSources()
        loadMovies()
        picker.delegate = self
        picker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.moviesCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = types[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell

        cell.backgroundView = UIImageView(image: theImageCache[indexPath.row])

        if movies.count > indexPath.row {
            cell.titleLabel.text! = movies[indexPath.row].title
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailViewSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "DetailViewSegue" {
            let destination = segue.destination as? DetailViewController
            let movieIndex = sender as! Int
            destination!.movie = movies[movieIndex]
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (self.movieSearchBar.text! != "") {
            loadMovies()
        }
    }
    
    private func setupDelegatesAndDataSources() {
        self.moviesCollectionView.dataSource = self
        self.moviesCollectionView.delegate = self
        self.movieSearchBar.delegate = self
    }
    
    private func loadMovies() {
        let activityView = UIActivityIndicatorView(frame: CGRect(x: self.movieSearchBar.bounds.minX, y: self.movieSearchBar.bounds.midY + self.movieSearchBar.bounds.height, width: self.movieSearchBar.bounds.width, height: self.movieSearchBar.bounds.height))
        activityView.activityIndicatorViewStyle = .gray
        activityView.startAnimating()
        self.view.addSubview(activityView)
        self.view.bringSubview(toFront: activityView)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if (self.movieSearchBar.text! == "") {
                self.fetchMovies(title: "A")
            }
            else {
                self.fetchMovies(title: self.movieSearchBar.text!)
            }
            
            self.cacheImages()
            
            DispatchQueue.main.async {
                self.moviesCollectionView.reloadData()
                activityView.removeFromSuperview()
            }
        }
    }
    
    private func fetchMovies(title: String) {
        self.movies.removeAll()
        self.theImageCache.removeAll()
        let urlTitle = title.replacingOccurrences(of: " ", with: "+")
        for pageNumber in 1 ... 3 {
            let json = getJSON("http://www.omdbapi.com/?s=" + urlTitle + "&page=" + String(pageNumber) + "&type=" + selectedType)
            for result in json["Search"].arrayValue {
                let title = result["Title"].stringValue
                let id = result["imdbID"].stringValue
                let year = result["Year"].stringValue
                let type = result["Type"].stringValue
                let imageUrl = result["Poster"].stringValue
                if !self.movies.contains(where: { $0.id == id }) {
                    movies.append(Movie(title: title, id: id, year: year, type: type, imageUrl: imageUrl))
                }
            }
        }
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
    
    private func cacheImages() {
        for movie in movies {
            if movie.imageUrl == "N/A" {
                theImageCache.append(UIImage(named: "silver_question_mark_poster-rad9c3496ce744cfa9e0fbf6343bf30ee_j3w_8byvr_324.jpg")!)
                continue
            }
            let url = URL(string: movie.imageUrl)
            let data = try? Data(contentsOf: url!)
            if data == nil {
                theImageCache.append(UIImage(named: "silver_question_mark_poster-rad9c3496ce744cfa9e0fbf6343bf30ee_j3w_8byvr_324.jpg")!)
                continue
            }
            let image = UIImage(data: data!)!
            theImageCache.append(image)
        }
    }
}

