//
//  Movie.swift
//  CoreySalzer-Lab4
//
//  Created by Corey Salzer on 3/2/17.
//  Copyright © 2017 Corey Salzer. All rights reserved.
//

import UIKit

struct Movie {
    let title:String
    let id:String
    let year:String
    let type:String
    let imageUrl:String
    var rated:String?
    var released:String?
    var runtime:String?
    var genre:String?
    var director:String?
    var writer:String?
    var actors:String?
    var plot:String?
    var language:String?
    var country:String?
    var awards:String?
    var metascore:String?
    var imdbRating:String?
    var imdbVotes:String?
    
    init(title: String, id: String, year: String, type: String, imageUrl: String) {
        self.title = title
        self.id = id
        self.year = year
        self.type = type
        self.imageUrl = imageUrl
    }
}
