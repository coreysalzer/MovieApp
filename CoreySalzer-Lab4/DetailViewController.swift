//
//  DetailViewController.swift
//  CoreySalzer-Lab4
//
//  Created by Corey Salzer on 3/2/17.
//  Copyright © 2017 Corey Salzer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var actorsLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var movie:Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setUpFavoritesButton()
        fetchMovie()
        loadDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToFavorites(_ sender: Any) {
        var favorites = UserDefaults.standard.array(forKey: "favorites") as? [String]
        if favorites == nil {
            favorites! = []
        }
        favorites!.append(movie.title)
        UserDefaults.standard.set(favorites!, forKey:"favorites")
        setViewForIsFavorite()
    }
    
    private func setUpFavoritesButton() {
        favoritesButton.setTitle("Favorited", for: .disabled)
        favoritesButton.setTitle("Add to Favorites", for: .normal)
        favoritesButton.setTitleColor(.black, for: .disabled)
    }
    
    private func fetchMovie() {
        let json = getJSON("http://www.omdbapi.com/?i=" + self.movie.id)
        self.movie.rated = json["Rated"].stringValue
        self.movie.released = json["Released"].stringValue
        self.movie.runtime = json["Runtime"].stringValue
        self.movie.genre = json["Genre"].stringValue
        self.movie.director = json["Director"].stringValue
        self.movie.writer = json["Writer"].stringValue
        self.movie.actors = json["Actors"].stringValue
        self.movie.plot = json["Plot"].stringValue
        self.movie.language = json["Language"].stringValue
        self.movie.country = json["Country"].stringValue
        self.movie.awards = json["Awards"].stringValue
        self.movie.metascore = json["Metascore"].stringValue
        self.movie.imdbRating = json["imdbRating"].stringValue
        self.movie.imdbVotes = json["imdbVotes"].stringValue
    }
    
    private func loadDetails() {
        self.navigationItem.title = movie.title
        releasedLabel.text = "Released: " + movie.released!
        scoreLabel.text = "Score: " + movie.metascore!
        if movie.metascore! != "N/A" {
            scoreLabel.text = scoreLabel.text! + "/100"
        }
        ratingLabel.text = "Rating: " + movie.rated!
        genreLabel.text = "Genre: " + movie.genre!
        actorsLabel.text = "Actors: " + movie.actors!
        plotLabel.text = movie.plot!
        if movie.imageUrl == "N/A" {
            movieImageView.image = UIImage(named: "silver_question_mark_poster-rad9c3496ce744cfa9e0fbf6343bf30ee_j3w_8byvr_324.jpg")
            return
        }
        let url = URL(string: movie.imageUrl)
        let data = try? Data(contentsOf: url!)
        if data == nil {
            movieImageView.image = UIImage(named: "silver_question_mark_poster-rad9c3496ce744cfa9e0fbf6343bf30ee_j3w_8byvr_324.jpg")
            return
        }
        let image = UIImage(data: data!)
        movieImageView.image = image
        
        let favorites = UserDefaults.standard.array(forKey: "favorites") as? [String]
        if favorites != nil && favorites!.contains(movie.title) {
            setViewForIsFavorite()
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
    
    private func setViewForIsFavorite() {
        self.favoritesButton.isEnabled = false
        let starImageView = UIImageView(image: UIImage(named: "top_rated"))
        starImageView.frame = CGRect(x: self.favoritesButton.bounds.minX - starImageView.bounds.width, y: self.favoritesButton.bounds.minY, width: starImageView.bounds.width, height: starImageView.bounds.height)
        self.favoritesButton.addSubview(starImageView)
        self.favoritesButton.setNeedsLayout()

    }
    
}
